#import "App.h"

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
        // Use runtime class loading to avoid import dependency
        Class MainWindowControllerClass = NSClassFromString(@"MainWindowController");
        mainWindowController = [[MainWindowControllerClass alloc] init];
    }
}

- (void)showMainWindow {
    [self initialize];
    [mainWindowController showWindow:nil];
    [[mainWindowController window] makeKeyAndOrderFront:nil];
}

- (id)mainWindowController {
    return mainWindowController;
}

@end