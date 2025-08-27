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

- (void)showSettings {
    // Use runtime class loading to avoid import dependency
    Class SettingsClass = NSClassFromString(@"Settings");
    if (SettingsClass) {
        id settings = [SettingsClass performSelector:@selector(sharedSettings)];
        [settings performSelector:@selector(showSettingsWindow)];
    }
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    // Create application menu
    NSMenu *mainMenu = [[NSMenu alloc] initWithTitle:@"MainMenu"];
    
    // App menu
    NSMenuItem *appMenuItem = [[NSMenuItem alloc] initWithTitle:@"ChatGPT Classic" action:nil keyEquivalent:@""];
    NSMenu *appMenu = [[NSMenu alloc] initWithTitle:@"ChatGPT Classic"];
    
    [appMenu addItemWithTitle:@"About ChatGPT Classic" action:nil keyEquivalent:@""];
    [appMenu addItem:[NSMenuItem separatorItem]];
    [appMenu addItemWithTitle:@"Settings..." action:@selector(showSettings) keyEquivalent:@","];
    [appMenu addItem:[NSMenuItem separatorItem]];
    [appMenu addItemWithTitle:@"Hide ChatGPT Classic" action:@selector(hide:) keyEquivalent:@"h"];
    [appMenu addItemWithTitle:@"Hide Others" action:@selector(hideOtherApplications:) keyEquivalent:@"h"];
    [appMenu addItemWithTitle:@"Show All" action:@selector(unhideAllApplications:) keyEquivalent:@""];
    [appMenu addItem:[NSMenuItem separatorItem]];
    [appMenu addItemWithTitle:@"Quit ChatGPT Classic" action:@selector(terminate:) keyEquivalent:@"q"];
    
    // Set targets for menu items
    NSArray *appMenuItems = [appMenu itemArray];
    for (NSMenuItem *item in appMenuItems) {
        if ([[item title] isEqualToString:@"Settings..."]) {
            [item setTarget:self];
        } else {
            [item setTarget:NSApp];
        }
    }
    
    [appMenuItem setSubmenu:appMenu];
    [mainMenu addItem:appMenuItem];
    
    // File menu
    NSMenuItem *fileMenuItem = [[NSMenuItem alloc] initWithTitle:@"File" action:nil keyEquivalent:@""];
    NSMenu *fileMenu = [[NSMenu alloc] initWithTitle:@"File"];
    [fileMenu addItemWithTitle:@"New Conversation" action:nil keyEquivalent:@"n"];
    [fileMenuItem setSubmenu:fileMenu];
    [mainMenu addItem:fileMenuItem];
    
    // Edit menu
    NSMenuItem *editMenuItem = [[NSMenuItem alloc] initWithTitle:@"Edit" action:nil keyEquivalent:@""];
    NSMenu *editMenu = [[NSMenu alloc] initWithTitle:@"Edit"];
    [editMenu addItemWithTitle:@"Cut" action:@selector(cut:) keyEquivalent:@"x"];
    [editMenu addItemWithTitle:@"Copy" action:@selector(copy:) keyEquivalent:@"c"];
    [editMenu addItemWithTitle:@"Paste" action:@selector(paste:) keyEquivalent:@"v"];
    [editMenuItem setSubmenu:editMenu];
    [mainMenu addItem:editMenuItem];
    
    [NSApp setMainMenu:mainMenu];
    
    // Release menu objects
    [appMenu release];
    [appMenuItem release];
    [fileMenu release];
    [fileMenuItem release];
    [editMenu release];
    [editMenuItem release];
    [mainMenu release];
    
    // Show main window
    [self showMainWindow];
    
    // Check for screenshot environment variable
    NSString *screenshotEnv = [[[NSProcessInfo processInfo] environment] objectForKey:@"CHAT_CLASSIC_SCREENSHOT"];
    if (screenshotEnv && [screenshotEnv length] > 0) {
        // Take screenshot after a brief delay to ensure window is fully rendered
        [self performSelector:@selector(takeScreenshotAndQuit) withObject:nil afterDelay:0.1];
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end