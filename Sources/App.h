#import <Cocoa/Cocoa.h>

@class MainWindowController;

@interface App : NSObject {
    MainWindowController *mainWindowController;
}

+ (App *)sharedApp;
- (void)initialize;
- (void)showMainWindow;
- (MainWindowController *)mainWindowController;

@end