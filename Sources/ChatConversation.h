#import <Cocoa/Cocoa.h>

@interface ChatMessage : NSObject {
    NSString *text;
    NSString *sender;
    NSDate *timestamp;
}

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *sender;
@property (nonatomic, retain) NSDate *timestamp;

- (id)initWithText:(NSString *)text sender:(NSString *)sender;

@end

@interface ChatConversation : NSObject {
    NSTableView *tableView;
    NSMutableArray *messages;
}

- (id)initWithFrame:(NSRect)frame;
- (NSView *)view;
- (void)addMessage:(NSString *)text fromSender:(NSString *)sender;
- (void)addMessage:(ChatMessage *)message;
- (void)clearMessages;
- (NSArray *)messages;
- (void)scrollToBottom;

@end