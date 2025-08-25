#import "Settings.h"

static Settings *sharedSettingsInstance = nil;

@implementation Settings

+ (Settings *)sharedSettings {
    if (sharedSettingsInstance == nil) {
        sharedSettingsInstance = [[Settings alloc] init];
    }
    return sharedSettingsInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        settingsWindow = nil;
        apiKeyField = nil;
        saveButton = nil;
        cancelButton = nil;
    }
    return self;
}

- (void)dealloc {
    [settingsWindow release];
    [apiKeyField release];
    [saveButton release];
    [cancelButton release];
    [super dealloc];
}

- (void)setupWindow {
    if (settingsWindow) return;
    
    NSRect windowFrame = NSMakeRect(200, 200, 400, 200);
    settingsWindow = [[NSWindow alloc] 
        initWithContentRect:windowFrame
        styleMask:(NSTitledWindowMask | NSClosableWindowMask)
        backing:NSBackingStoreBuffered
        defer:NO];
    
    [settingsWindow setTitle:@"Settings"];
    [settingsWindow setLevel:NSFloatingWindowLevel];
    
    NSView *contentView = [settingsWindow contentView];
    NSRect contentBounds = [contentView bounds];
    
    // API Key label
    NSRect labelFrame = NSMakeRect(20, contentBounds.size.height - 60, 100, 20);
    NSTextField *apiKeyLabel = [[NSTextField alloc] initWithFrame:labelFrame];
    [apiKeyLabel setStringValue:@"OpenAI API Key:"];
    [apiKeyLabel setEditable:NO];
    [apiKeyLabel setBordered:NO];
    [apiKeyLabel setBackgroundColor:[NSColor clearColor]];
    [contentView addSubview:apiKeyLabel];
    [apiKeyLabel release];
    
    // API Key input field
    NSRect fieldFrame = NSMakeRect(20, contentBounds.size.height - 90, contentBounds.size.width - 40, 22);
    apiKeyField = [[NSTextField alloc] initWithFrame:fieldFrame];
    [apiKeyField setAutoresizingMask:(NSViewWidthSizable)];
    [apiKeyField setPlaceholderString:@"sk-..."];
    
    // Load existing API key
    NSString *existingKey = [self getAPIKey];
    if (existingKey) {
        [apiKeyField setStringValue:existingKey];
    }
    
    [contentView addSubview:apiKeyField];
    
    // Save button
    NSRect saveFrame = NSMakeRect(contentBounds.size.width - 180, 20, 80, 30);
    saveButton = [[NSButton alloc] initWithFrame:saveFrame];
    [saveButton setAutoresizingMask:(NSViewMinXMargin)];
    [saveButton setTitle:@"Save"];
    [saveButton setTarget:self];
    [saveButton setAction:@selector(saveButtonClicked:)];
    [saveButton setBezelStyle:NSRoundedBezelStyle];
    [saveButton setKeyEquivalent:@"\r"];
    [contentView addSubview:saveButton];
    
    // Cancel button
    NSRect cancelFrame = NSMakeRect(contentBounds.size.width - 90, 20, 80, 30);
    cancelButton = [[NSButton alloc] initWithFrame:cancelFrame];
    [cancelButton setAutoresizingMask:(NSViewMinXMargin)];
    [cancelButton setTitle:@"Cancel"];
    [cancelButton setTarget:self];
    [cancelButton setAction:@selector(cancelButtonClicked:)];
    [cancelButton setBezelStyle:NSRoundedBezelStyle];
    [cancelButton setKeyEquivalent:@"\033"]; // Escape key
    [contentView addSubview:cancelButton];
}

- (void)showSettingsWindow {
    [self setupWindow];
    [settingsWindow makeKeyAndOrderFront:nil];
    [settingsWindow center];
}

- (void)hideSettingsWindow {
    if (settingsWindow) {
        [settingsWindow orderOut:nil];
    }
}

- (NSString *)getAPIKey {
    return [[Keychain sharedKeychain] getAPIKeyForService:@"ChatGPTClassic" account:@"OpenAI_API_Key"];
}

- (BOOL)setAPIKey:(NSString *)apiKey {
    return [[Keychain sharedKeychain] setAPIKey:apiKey forService:@"ChatGPTClassic" account:@"OpenAI_API_Key"];
}

- (IBAction)saveButtonClicked:(id)sender {
    NSString *apiKey = [[apiKeyField stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([apiKey length] == 0) {
        NSRunAlertPanel(@"Error", @"Please enter a valid API key.", @"OK", nil, nil);
        return;
    }
    
    if (![apiKey hasPrefix:@"sk-"]) {
        NSRunAlertPanel(@"Warning", @"OpenAI API keys typically start with 'sk-'. Are you sure this is correct?", @"OK", nil, nil);
    }
    
    if ([self setAPIKey:apiKey]) {
        [self hideSettingsWindow];
        NSRunAlertPanel(@"Success", @"API key saved successfully to keychain.", @"OK", nil, nil);
    } else {
        NSRunAlertPanel(@"Error", @"Failed to save API key to keychain.", @"OK", nil, nil);
    }
}

- (IBAction)cancelButtonClicked:(id)sender {
    [self hideSettingsWindow];
}

@end