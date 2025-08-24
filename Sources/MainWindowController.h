#import <Cocoa/Cocoa.h>

@interface MainWindowController : NSWindowController {
    IBOutlet NSOutlineView *sidebarOutlineView;
    IBOutlet NSTableView *chatTableView;
    IBOutlet NSSplitView *splitView;
    
    NSMutableArray *sidebarItems;
    NSMutableArray *chatMessages;
}

- (id)init;
- (void)setupWindow;
- (void)setupSidebar;
- (void)setupChatTable;

@end