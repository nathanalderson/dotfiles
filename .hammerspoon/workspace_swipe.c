#include <ApplicationServices/ApplicationServices.h>
#include <errno.h>
#include <math.h>
#include <mach/mach_time.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum
{
    gesture = 29,
    dockControl = 30,
    gestureHIDType = 110,
    gestureSwipeMotion = 123,
    gestureSwipeProgress = 124,
    gestureSwipePositionX = 125,
    gestureSwipeVelocityX = 129,
    gestureSwipeVelocityY = 130,
    gesturePhase = 132,
    gesturePhaseAlias = 134,
    gestureZoomDeltaY = 138,
    sourceProcessAlias = 169,
    rawIOHIDPayload = 4205,
    dockSwipe = 23,
    horizontalMotion = 1,
    phaseBegan = 1,
    phaseChanged = 2,
    phaseEnded = 4,
};

// macOS 27 payload layout documented by https://github.com/joshuarli/iss (0BSD).
#pragma pack(push, 1)
typedef struct
{
    uint32_t size, type, options;
    uint8_t depth, reserved[3];
} HIDEventBase;

typedef struct
{
    uint64_t timestamp, senderID;
    uint32_t options, attributeLength, eventCount;
} HIDQueueHeader;

typedef struct
{
    HIDEventBase base;
    int32_t x, y, z;
    uint32_t swipeMask;
    uint16_t motion, flavor;
    int32_t progress;
} HIDFluidGesture;

typedef struct
{
    HIDEventBase base;
    int32_t x, y, z;
} HIDVelocity;
#pragma pack(pop)

_Static_assert(sizeof(HIDQueueHeader) == 28, "Unexpected HID queue header layout");
_Static_assert(sizeof(HIDFluidGesture) == 40, "Unexpected HID fluid gesture layout");
_Static_assert(sizeof(HIDVelocity) == 28, "Unexpected HID velocity layout");

static int32_t fixedVelocity(double value)
{
    double fixed = fmax(INT32_MIN, fmin(INT32_MAX, value * 65536.0));
    if (fixed > -1.0 && fixed < 1.0 && value != 0.0)
        return value > 0.0 ? 1 : -1;
    return (int32_t)fixed;
}

static CGEventRef augmentSwipe(CGEventRef swipe, int phase, double direction, double velocity)
{
    CFDataRef serialized = CGEventCreateData(NULL, swipe);
    if (!serialized)
        return NULL;
    const UInt8 *bytes = CFDataGetBytePtr(serialized);
    if (CFDataGetLength(serialized) < 4 || memcmp(bytes, "\0\0\0\2", 4) != 0)
    {
        fprintf(stderr, "Unsupported CGEvent serialization format\n");
        CFRelease(serialized);
        return NULL;
    }

    bool ended = phase == phaseEnded;
    HIDQueueHeader header = {
        .timestamp = CGEventGetTimestamp(swipe),
        .eventCount = ended ? 2 : 1,
    };
    HIDFluidGesture fluid = {
        .base = { .size = sizeof(HIDFluidGesture), .type = 23,
                  .options = (uint32_t)phase << 24 },
        .x = 6553,
        .motion = horizontalMotion,
        .flavor = 3,
        .progress = (int32_t)(-direction * 65536.0),
    };
    HIDVelocity speed = {
        .base = { .size = sizeof(HIDVelocity), .type = 9, .depth = 1 },
        .x = fixedVelocity(-direction * velocity),
    };
    size_t length = sizeof(header) + sizeof(fluid) + (ended ? sizeof(speed) : 0);
    UInt8 field[] = { (UInt8)(length >> 8), (UInt8)length,
                      (UInt8)(rawIOHIDPayload >> 8), (UInt8)rawIOHIDPayload };
    CFMutableDataRef data = CFDataCreateMutableCopy(NULL, 0, serialized);
    CFRelease(serialized);
    if (!data)
        return NULL;
    CFDataAppendBytes(data, field, sizeof(field));
    CFDataAppendBytes(data, (const UInt8 *)&header, sizeof(header));
    CFDataAppendBytes(data, (const UInt8 *)&fluid, sizeof(fluid));
    if (ended)
        CFDataAppendBytes(data, (const UInt8 *)&speed, sizeof(speed));
    CGEventRef augmented = CGEventCreateFromData(NULL, data);
    CFRelease(data);
    return augmented;
}

static bool appendSwipe(CFMutableArrayRef events, int phase, double direction, double velocity)
{
    CGEventRef swipe = CGEventCreate(NULL);
    CGEventRef companion = CGEventCreate(NULL);
    if (!swipe || !companion)
    {
        if (swipe)
            CFRelease(swipe);
        if (companion)
            CFRelease(companion);
        return false;
    }
    CGEventSetType(swipe, dockControl);
    CGEventSetFlags(swipe, 0);
    CGEventSetIntegerValueField(swipe, gestureHIDType, dockSwipe);
    CGEventSetIntegerValueField(swipe, gestureSwipeMotion, horizontalMotion);
    CGEventSetIntegerValueField(swipe, gesturePhase, phase);
    CGEventSetTimestamp(swipe, mach_absolute_time());
    CGEventSetDoubleValueField(swipe, gestureSwipeProgress, -direction);
    CGEventSetDoubleValueField(swipe, gestureSwipePositionX, 0.1);
    CGEventSetIntegerValueField(swipe, gesturePhaseAlias, phase);
    CGEventSetDoubleValueField(swipe, gestureZoomDeltaY, 3.0);
    CGEventSetDoubleValueField(swipe, sourceProcessAlias, (double)mach_absolute_time());
    CGEventSetDoubleValueField(swipe, gestureSwipeVelocityX,
                              phase == phaseEnded ? -direction * velocity : 0.0);
    CGEventSetDoubleValueField(swipe, gestureSwipeVelocityY, 0.0);
    CGEventRef augmented = augmentSwipe(swipe, phase, direction, velocity);
    CFRelease(swipe);
    if (!augmented)
    {
        CFRelease(companion);
        return false;
    }
    swipe = augmented;
    CGEventSetType(companion, gesture);
    CGEventSetFlags(companion, 0);
    CFDataRef swipeData = CGEventCreateData(NULL, swipe);
    CFDataRef companionData = CGEventCreateData(NULL, companion);
    CFRelease(swipe);
    CFRelease(companion);
    if (!swipeData || !companionData)
    {
        if (swipeData)
            CFRelease(swipeData);
        if (companionData)
            CFRelease(companionData);
        return false;
    }
    CFArrayAppendValue(events, swipeData);
    CFArrayAppendValue(events, companionData);
    CFRelease(swipeData);
    CFRelease(companionData);
    return true;
}

int main(int argc, char **argv)
{
    if ((argc != 2 && argc != 3) || (strcmp(argv[1], "left") != 0 && strcmp(argv[1], "right") != 0))
    {
        fprintf(stderr, "Usage: workspace_swipe left|right [velocity]\n");
        return 2;
    }

    double velocity = 400.0;
    if (argc == 3)
    {
        char *end;
        errno = 0;
        velocity = strtod(argv[2], &end);
        if (end == argv[2] || *end != '\0' || errno != 0 || !isfinite(velocity) || velocity <= 0)
        {
            fprintf(stderr, "Velocity must be a positive finite number\n");
            return 2;
        }
    }

    double direction = strcmp(argv[1], "right") == 0 ? 1.0 : -1.0;
    CFMutableArrayRef events = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
    if (!events)
    {
        fprintf(stderr, "Could not allocate workspace swipe events\n");
        return 1;
    }
    if (!appendSwipe(events, phaseBegan, direction, velocity)
        || !appendSwipe(events, phaseChanged, direction, velocity)
        || !appendSwipe(events, phaseEnded, direction, velocity))
    {
        CFRelease(events);
        fprintf(stderr, "Could not serialize workspace swipe events\n");
        return 1;
    }
    CFDataRef output = CFPropertyListCreateData(NULL, events, kCFPropertyListXMLFormat_v1_0,
                                                0, NULL);
    CFRelease(events);
    if (!output)
    {
        fprintf(stderr, "Could not encode workspace swipe events\n");
        return 1;
    }
    size_t length = (size_t)CFDataGetLength(output);
    bool written = fwrite(CFDataGetBytePtr(output), 1, length, stdout) == length;
    CFRelease(output);
    return written ? 0 : 1;
}