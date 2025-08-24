#import <Cocoa/Cocoa.h>

@interface MainWindowController : NSWindowController {
    IBOutlet NSOutlineView *sidebarOutlineView;
    IBOutlet NSTableView *chatTableView;
    IBOutlet NSSplitView *splitView;
    IBOutlet NSView *toolbarView;
    IBOutlet NSTextField *chatInputField;
    IBOutlet NSButton *sendButton;
    
    NSMutableArray *sidebarItems;
    NSMutableArray *chatMessages;
}

- (id)init;
- (void)setupWindow;
- (void)setupSidebar;
- (void)setupChatTable;
- (void)setupToolbar;
- (void)setupChatInput;
- (IBAction)sendMessage:(id)sender;

@end