#import <Cocoa/Cocoa.h>

@class MainWindowController;

@interface App : NSObject {
    id mainWindowController;  // Use id to avoid import dependency
}

+ (App *)sharedApp;
- (void)initialize;
- (void)showMainWindow;
- (id)mainWindowController;

@end