#import <Cocoa/Cocoa.h>

@protocol HistoryTableDelegate;

@interface HistoryTable : NSObject {
    NSOutlineView *outlineView;
    NSMutableArray *conversations;
    id<HistoryTableDelegate> delegate;
}

- (id)initWithFrame:(NSRect)frame;
- (NSView *)view;
- (void)setDelegate:(id<HistoryTableDelegate>)delegate;
- (void)addConversation:(NSString *)title;
- (void)selectConversationAtIndex:(NSInteger)index;
- (NSInteger)selectedConversationIndex;

@end

@protocol HistoryTableDelegate <NSObject>
@optional
- (void)historyTable:(HistoryTable *)historyTable didSelectConversationAtIndex:(NSInteger)index;
- (void)historyTableDidRequestNewConversation:(HistoryTable *)historyTable;
@end