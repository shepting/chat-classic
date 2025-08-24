#import <Cocoa/Cocoa.h>
#import "HistoryTable.h"
#import "ChatConversation.h"
#import "ChatInput.h"
#import "Networking.h"

@interface MainWindowController : NSWindowController <HistoryTableDelegate, ChatInputDelegate, NetworkingDelegate> {
    IBOutlet NSSplitView *splitView;
    IBOutlet NSView *toolbarView;
    
    HistoryTable *historyTable;
    ChatConversation *chatConversation;
    ChatInput *chatInput;
    Networking *networking;
}

- (id)init;
- (void)setupWindow;
- (void)setupModules;
- (void)setupToolbar;

@end