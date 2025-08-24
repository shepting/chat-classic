#import <Cocoa/Cocoa.h>

@class MainWindowController;

@interface App : NSObject <NSApplicationDelegate> {
    id mainWindowController;  // Use id to avoid import dependency
}

+ (App *)sharedApp;
- (void)initialize;
- (void)showMainWindow;
- (id)mainWindowController;
- (void)showSettings;

// NSApplicationDelegate methods
- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender;

@end