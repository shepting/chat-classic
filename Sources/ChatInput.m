#import "ChatInput.h"

@implementation ChatInput

- (id)initWithFrame:(NSRect)frame {
    self = [super init];
    if (self) {
        isShowingPlaceholder = YES;
        
        // Create container view with background
        containerView = [[NSView alloc] initWithFrame:frame];
        [containerView setAutoresizingMask:(NSViewWidthSizable | NSViewMaxYMargin)];
        [containerView setWantsLayer:YES];
        [[containerView layer] setBackgroundColor:[[NSColor colorWithCalibratedRed:0.98 green:0.98 blue:0.98 alpha:1.0] CGColor]];
        
        NSRect containerBounds = [containerView bounds];
        
        // Create scroll view for multi-line text input
        NSRect scrollFrame = NSMakeRect(20, 20, containerBounds.size.width - 110, 40);
        NSScrollView *inputScrollView = [[NSScrollView alloc] initWithFrame:scrollFrame];
        [inputScrollView setAutoresizingMask:(NSViewWidthSizable)];
        [inputScrollView setHasVerticalScroller:YES];
        [inputScrollView setBorderType:NSBezelBorder];
        [inputScrollView setAutohidesScrollers:YES];
        
        // Chat input text view (multi-line)
        NSRect textFrame = [[inputScrollView contentView] bounds];
        textView = [[NSTextView alloc] initWithFrame:textFrame];
        [textView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
        [textView setRichText:NO];
        [textView setImportsGraphics:NO];
        [textView setFont:[NSFont systemFontOfSize:13]];
        [textView setTextContainerInset:NSMakeSize(5, 5)];
        [textView setDelegate:self];
        
        // Set placeholder text
        [self showPlaceholder];
        
        [inputScrollView setDocumentView:textView];
        [containerView addSubview:inputScrollView];
        [inputScrollView release];
        
        // Send button with Aqua style
        NSRect buttonFrame = NSMakeRect(containerBounds.size.width - 80, 30, 60, 20);
        sendButton = [[NSButton alloc] initWithFrame:buttonFrame];
        [sendButton setAutoresizingMask:(NSViewMinXMargin)];
        [sendButton setTitle:@"Send"];
        [sendButton setTarget:self];
        [sendButton setAction:@selector(sendButtonClicked:)];
        [sendButton setBezelStyle:NSRoundedBezelStyle]; // Aqua style
        [sendButton setKeyEquivalent:@"\r"]; // Enter key equivalent
        [containerView addSubview:sendButton];
    }
    return self;
}

- (void)dealloc {
    [containerView release];
    [textView release];
    [sendButton release];
    [super dealloc];
}

- (NSView *)view {
    return containerView;
}

- (void)setDelegate:(id<ChatInputDelegate>)newDelegate {
    delegate = newDelegate;
}

- (NSString *)currentText {
    if (isShowingPlaceholder) {
        return @"";
    }
    return [textView string];
}

- (void)clearText {
    [self showPlaceholder];
}

- (void)focusInput {
    [[textView window] makeFirstResponder:textView];
}

- (void)showPlaceholder {
    [textView setString:@"Ask anything"];
    [textView setTextColor:[NSColor grayColor]];
    isShowingPlaceholder = YES;
}

- (void)hidePlaceholder {
    if (isShowingPlaceholder) {
        [textView setString:@""];
        [textView setTextColor:[NSColor blackColor]];
        isShowingPlaceholder = NO;
    }
}

- (IBAction)sendButtonClicked:(id)sender {
    [self sendMessage];
}

- (void)sendMessage {
    NSString *message = [[textView string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // Check if we should send (not empty, not placeholder)
    if ([message length] > 0 && !isShowingPlaceholder) {
        BOOL shouldSend = YES;
        
        if (delegate && [delegate respondsToSelector:@selector(chatInputShouldSendMessage:)]) {
            shouldSend = [delegate chatInputShouldSendMessage:self];
        }
        
        if (shouldSend) {
            if (delegate && [delegate respondsToSelector:@selector(chatInput:didSendMessage:)]) {
                [delegate chatInput:self didSendMessage:message];
            }
            [self clearText];
        }
    }
}

#pragma mark - NSTextView Delegate

- (void)textDidBeginEditing:(NSNotification *)notification {
    NSTextView *editingTextView = [notification object];
    if (editingTextView == textView && isShowingPlaceholder) {
        [self hidePlaceholder];
    }
}

- (void)textDidEndEditing:(NSNotification *)notification {
    NSTextView *editingTextView = [notification object];
    if (editingTextView == textView) {
        NSString *currentText = [[textView string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([currentText length] == 0) {
            [self showPlaceholder];
        }
    }
}

- (void)textDidChange:(NSNotification *)notification {
    // Ensure placeholder state is correct
    NSString *currentText = [textView string];
    if ([currentText length] == 0 && !isShowingPlaceholder) {
        // Text was cleared, but we're not showing placeholder - this can happen with undo
        [self showPlaceholder];
    }
}

@end