#include <CoreFoundation/CoreFoundation.h>
#include <dlfcn.h>
#include <errno.h>
#include <mach-o/dyld.h>
#include <mach-o/loader.h>
#include <mach-o/nlist.h>
#include <objc/message.h>
#include <objc/runtime.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

// Moves one window to another Space with the bridged SkyLight operation that works on
// current macOS, following https://github.com/gechr/WhichSpace (MIT). Usage: workspace_move WINDOW SPACE
#define BRIDGED_SYMBOL \
    "__ZL54SLSPerformAsynchronousBridgedWindowManagementOperationP47SLSAsynchronousBridgedWindowManagementOperation"
#define BRIDGED_CLASS "SLSBridgedMoveWindowsToManagedSpaceOperation"
#define BRIDGED_INIT "initWithWindows:spaceID:"

extern unsigned char NSApplicationLoad(void);

typedef int64_t (*PerformFunc)(void *);
typedef CFArrayRef (*CopySpacesFunc)(int cid, int selector, CFArrayRef windowIDs);

static int spaceMembership(CopySpacesFunc copySpaces, int cid, uint32_t windowID, uint64_t target, int *hasOther)
{
    int32_t value = (int32_t)windowID;
    CFNumberRef number = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &value);
    CFArrayRef list = CFArrayCreate(kCFAllocatorDefault, (const void **)&number, 1, &kCFTypeArrayCallBacks);
    CFRelease(number);
    // Selector 0x7 returns every Space the window belongs to.
    CFArrayRef spaces = copySpaces(cid, 0x7, list);
    CFRelease(list);
    int hasTarget = 0;
    *hasOther = 0;
    if (spaces == NULL)
    {
        return 0;
    }
    for (CFIndex index = 0; index < CFArrayGetCount(spaces); index++)
    {
        int64_t space = 0;
        CFNumberGetValue(CFArrayGetValueAtIndex(spaces, index), kCFNumberSInt64Type, &space);
        if ((uint64_t)space == target)
        {
            hasTarget = 1;
        }
        else
        {
            *hasOther = 1;
        }
    }
    CFRelease(spaces);
    return hasTarget;
}

// The bridged entry point has internal linkage, so it is only found by walking SkyLight's symbol table.
static void *findLocalSymbol(const char *symbolName)
{
    for (uint32_t image = 0; image < _dyld_image_count(); image++)
    {
        const char *name = _dyld_get_image_name(image);
        size_t length = name ? strlen(name) : 0;
        if (length < 9 || strcmp(name + length - 9, "/SkyLight") != 0)
        {
            continue;
        }
        const struct mach_header_64 *header = (const struct mach_header_64 *)_dyld_get_image_header(image);
        if (header == NULL || header->magic != MH_MAGIC_64)
        {
            return NULL;
        }
        intptr_t slide = _dyld_get_image_vmaddr_slide(image);
        const struct segment_command_64 *linkedit = NULL;
        const struct symtab_command *symtab = NULL;
        const uint8_t *cursor = (const uint8_t *)(header + 1);
        for (uint32_t command = 0; command < header->ncmds; command++)
        {
            const struct load_command *load = (const struct load_command *)cursor;
            if (load->cmd == LC_SEGMENT_64 && strcmp(((const struct segment_command_64 *)load)->segname, SEG_LINKEDIT) == 0)
            {
                linkedit = (const struct segment_command_64 *)load;
            }
            else if (load->cmd == LC_SYMTAB)
            {
                symtab = (const struct symtab_command *)load;
            }
            cursor += load->cmdsize;
        }
        if (linkedit == NULL || symtab == NULL)
        {
            return NULL;
        }
        uintptr_t base = (uintptr_t)(linkedit->vmaddr + slide) - linkedit->fileoff;
        const struct nlist_64 *symbols = (const struct nlist_64 *)(base + symtab->symoff);
        const char *strings = (const char *)(base + symtab->stroff);
        for (uint32_t index = 0; index < symtab->nsyms; index++)
        {
            if (symbols[index].n_value != 0 && symbols[index].n_un.n_strx < symtab->strsize && strcmp(strings + symbols[index].n_un.n_strx, symbolName) == 0)
            {
                return (void *)(symbols[index].n_value + slide);
            }
        }
        return NULL;
    }
    return NULL;
}

int main(int argc, char **argv)
{
    if (argc != 3)
    {
        fprintf(stderr, "usage: workspace_move WINDOW SPACE\n");
        return 2;
    }
    errno = 0;
    unsigned long windowID = strtoul(argv[1], NULL, 10);
    unsigned long long spaceID = strtoull(argv[2], NULL, 10);
    if (errno != 0 || windowID == 0 || windowID > UINT32_MAX || spaceID == 0)
    {
        fprintf(stderr, "invalid window or space\n");
        return 2;
    }

    int (*defaultConnection)(void) = (int (*)(void))dlsym(RTLD_DEFAULT, "_CGSDefaultConnection");
    CopySpacesFunc copySpaces = (CopySpacesFunc)dlsym(RTLD_DEFAULT, "SLSCopySpacesForWindows");
    Class operationClass = objc_getClass(BRIDGED_CLASS);
    PerformFunc perform = (PerformFunc)dlsym(RTLD_DEFAULT, BRIDGED_SYMBOL);
    if (perform == NULL)
    {
        perform = (PerformFunc)findLocalSymbol(BRIDGED_SYMBOL);
    }
    if (defaultConnection == NULL || copySpaces == NULL || operationClass == NULL || perform == NULL || class_getInstanceMethod(operationClass, sel_getUid(BRIDGED_INIT)) == NULL)
    {
        fprintf(stderr, "bridged window move is unavailable on this macOS\n");
        return 1;
    }

    // WindowServer ignores the move from a plain command-line process until AppKit has registered it as an app.
    NSApplicationLoad();
    int cid = defaultConnection();
    int hasOther = 0;
    if (spaceMembership(copySpaces, cid, (uint32_t)windowID, spaceID, &hasOther) && !hasOther)
    {
        return 0;
    }

    int32_t value = (int32_t)windowID;
    CFNumberRef number = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &value);
    CFArrayRef list = CFArrayCreate(kCFAllocatorDefault, (const void **)&number, 1, &kCFTypeArrayCallBacks);
    CFRelease(number);
    id allocated = ((id (*)(Class, SEL))objc_msgSend)(operationClass, sel_getUid("alloc"));
    id operation = allocated == NULL
                       ? NULL
                       : ((id (*)(id, SEL, CFArrayRef, uint64_t))objc_msgSend)(allocated, sel_getUid(BRIDGED_INIT), list, spaceID);
    CFRelease(list);
    if (operation == NULL)
    {
        fprintf(stderr, "could not create window move operation\n");
        return 1;
    }
    perform((void *)operation);
    ((void (*)(id, SEL))objc_msgSend)(operation, sel_getUid("release"));

    // The operation is asynchronous, so success means the window left its old Spaces for the target.
    for (int attempt = 0; attempt < 40; attempt++)
    {
        if (spaceMembership(copySpaces, cid, (uint32_t)windowID, spaceID, &hasOther) && !hasOther)
        {
            return 0;
        }
        usleep(10000);
    }
    fprintf(stderr, "window did not move to the target space\n");
    return 1;
}
