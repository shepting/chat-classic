#import <Cocoa/Cocoa.h>

@interface ChatMessage : NSObject {
    NSString *text;
    NSString *sender;
    NSDate *timestamp;
    BOOL isSpinner;
    NSTimer *animationTimer;
    int animationState;
}

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *sender;
@property (nonatomic, retain) NSDate *timestamp;
@property (nonatomic, assign) BOOL isSpinner;

- (id)initWithText:(NSString *)text sender:(NSString *)sender;
- (id)initSpinnerMessageWithSender:(NSString *)sender;
- (void)startSpinnerAnimation:(NSTableView *)tableView row:(NSInteger)row;
- (void)stopSpinnerAnimation;
- (NSString *)currentSpinnerText;

@end

@interface ChatConversation : NSObject {
    NSTableView *tableView;
    NSMutableArray *messages;
    NSScrollView *mainView;
}

- (id)initWithFrame:(NSRect)frame;
- (NSView *)view;
- (void)addMessage:(NSString *)text fromSender:(NSString *)sender;
- (void)addMessage:(ChatMessage *)message;
- (void)clearMessages;
- (NSArray *)messages;
- (void)scrollToBottom;
- (ChatMessage *)addSpinnerMessage:(NSString *)sender;
- (void)removeSpinnerMessages;

@end