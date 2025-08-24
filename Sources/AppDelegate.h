#import <Cocoa/Cocoa.h>

@class MainWindowController;

@interface AppDelegate : NSObject {
    MainWindowController *mainWindowController;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender;

@end