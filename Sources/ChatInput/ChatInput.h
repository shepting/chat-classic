#import <Cocoa/Cocoa.h>

@protocol ChatInputDelegate;

@interface ChatInput : NSObject <NSTextViewDelegate> {
    NSView *containerView;
    NSTextView *textView;
    NSButton *sendButton;
    id<ChatInputDelegate> delegate;
    BOOL isShowingPlaceholder;
}

- (id)initWithFrame:(NSRect)frame;
- (NSView *)view;
- (void)setDelegate:(id<ChatInputDelegate>)delegate;
- (NSString *)currentText;
- (void)clearText;
- (void)focusInput;

@end

@protocol ChatInputDelegate <NSObject>
@optional
- (void)chatInput:(ChatInput *)chatInput didSendMessage:(NSString *)message;
- (BOOL)chatInputShouldSendMessage:(ChatInput *)chatInput;
@end