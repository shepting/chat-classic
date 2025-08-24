#import "AppDelegate.h"
#import "MainWindowController.h"

@implementation AppDelegate

- (void)dealloc {
    [mainWindowController release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    mainWindowController = [[MainWindowController alloc] init];
    [mainWindowController showWindow:nil];
    [[mainWindowController window] makeKeyAndOrderFront:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end