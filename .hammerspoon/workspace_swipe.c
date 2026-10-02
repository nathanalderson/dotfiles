#include <ApplicationServices/ApplicationServices.h>
#include <errno.h>
#include <float.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum
{
    gesture = 29,
    dockControl = 30,
    gestureHIDType = 110,
    gestureScrollY = 119,
    gestureSwipeMotion = 123,
    gestureSwipeVelocityX = 129,
    gestureSwipeVelocityY = 130,
    gesturePhase = 132,
    scrollGestureFlagBits = 135,
    gestureZoomDeltaX = 139,
    dockSwipe = 23,
    horizontalMotion = 1,
    phaseBegan = 1,
    phaseChanged = 2,
    phaseEnded = 4,
};

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
    float progress = direction > 0 ? FLT_TRUE_MIN : -FLT_TRUE_MIN;
    int32_t directionBits;
    memcpy(&directionBits, &progress, sizeof(directionBits));

    CGEventSetType(swipe, dockControl);
    CGEventSetFlags(swipe, 0);
    CGEventSetIntegerValueField(swipe, gestureHIDType, dockSwipe);
    CGEventSetIntegerValueField(swipe, gestureSwipeMotion, horizontalMotion);
    CGEventSetIntegerValueField(swipe, gesturePhase, phase);
    CGEventSetIntegerValueField(swipe, scrollGestureFlagBits, directionBits);
    CGEventSetDoubleValueField(swipe, gestureScrollY, 0.0);
    CGEventSetDoubleValueField(swipe, gestureZoomDeltaX, FLT_TRUE_MIN);
    CGEventSetDoubleValueField(swipe, gestureSwipeVelocityX,
                               phase == phaseEnded ? direction * velocity : 0.0);
    CGEventSetDoubleValueField(swipe, gestureSwipeVelocityY, 0.0);
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
    if (!appendSwipe(events, phaseBegan, direction, velocity) || !appendSwipe(events, phaseChanged, direction, velocity) || !appendSwipe(events, phaseEnded, direction, velocity))
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