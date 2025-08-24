#import <Cocoa/Cocoa.h>
#import "App.h"

int main(int argc, char *argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSApplication *app = [NSApplication sharedApplication];
    App *appDelegate = [[App alloc] init];
    [app setDelegate:appDelegate];
    
    [app run];
    
    [appDelegate release];
    [pool release];
    return 0;
}