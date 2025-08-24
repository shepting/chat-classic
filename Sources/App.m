#import "App.h"
#import "MainWindowController.h"

static App *sharedAppInstance = nil;

@implementation App

+ (App *)sharedApp {
    if (sharedAppInstance == nil) {
        sharedAppInstance = [[App alloc] init];
    }
    return sharedAppInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        mainWindowController = nil;
    }
    return self;
}

- (void)dealloc {
    [mainWindowController release];
    [super dealloc];
}

- (void)initialize {
    if (!mainWindowController) {
        mainWindowController = [[MainWindowController alloc] init];
    }
}

- (void)showMainWindow {
    [self initialize];
    [mainWindowController showWindow:nil];
    [[mainWindowController window] makeKeyAndOrderFront:nil];
}

- (MainWindowController *)mainWindowController {
    return mainWindowController;
}

@end