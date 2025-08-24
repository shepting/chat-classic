#import <Cocoa/Cocoa.h>
#import <Security/Security.h>

@interface Settings : NSObject {
    NSWindow *settingsWindow;
    NSTextField *apiKeyField;
    NSButton *saveButton;
    NSButton *cancelButton;
}

+ (Settings *)sharedSettings;
- (void)showSettingsWindow;
- (void)hideSettingsWindow;
- (NSString *)getAPIKey;
- (BOOL)setAPIKey:(NSString *)apiKey;
- (void)setupWindow;
- (IBAction)saveButtonClicked:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;

@end