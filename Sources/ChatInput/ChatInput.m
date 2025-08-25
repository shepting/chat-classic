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
        
        // Make container accept first responder to handle clicks
        [containerView setAcceptsTouchEvents:YES];
        
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
        
        // Ensure text view is editable and selectable
        [textView setEditable:YES];
        [textView setSelectable:YES];
        [textView setFieldEditor:NO];
        [textView setUsesFontPanel:NO];
        [textView setUsesRuler:NO];
        [textView setContinuousSpellCheckingEnabled:NO];
        
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
    // Ensure the text view can accept focus
    [textView setEditable:YES];
    [textView setSelectable:YES];
    [[textView window] makeFirstResponder:textView];
    
    // If placeholder is showing, select all so user can just start typing
    if (isShowingPlaceholder) {
        [textView selectAll:nil];
    }
}

- (void)resetInput {
    // Reset all text view properties to ensure it's editable
    [textView setEditable:YES];
    [textView setSelectable:YES];
    [textView setFieldEditor:NO];
    [textView setString:@""];
    [textView setTextColor:[NSColor blackColor]];
    isShowingPlaceholder = NO;
    [self showPlaceholder];
    [self focusInput];
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

- (BOOL)textShouldBeginEditing:(NSText *)aTextObject {
    // Always allow editing
    return YES;
}

- (BOOL)textView:(NSTextView *)aTextView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString {
    // If we're showing placeholder, clear it when user starts typing
    if (aTextView == textView && isShowingPlaceholder) {
        [self hidePlaceholder];
    }
    return YES;
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