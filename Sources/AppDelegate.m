#import "AppDelegate.h"
#import "App.h"

@implementation AppDelegate

- (void)dealloc {
    [mainWindowController release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    App *app = [App sharedApp];
    [app showMainWindow];
    
    // Keep reference to main window controller for compatibility
    mainWindowController = [[app mainWindowController] retain];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end