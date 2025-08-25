#import "ChatConversation.h"

@implementation ChatMessage

@synthesize text, sender, timestamp, isSpinner;

- (id)initWithText:(NSString *)messageText sender:(NSString *)messageSender {
    self = [super init];
    if (self) {
        self.text = messageText;
        self.sender = messageSender;
        self.timestamp = [NSDate date];
        self.isSpinner = NO;
        animationTimer = nil;
        animationState = 0;
    }
    return self;
}

- (id)initSpinnerMessageWithSender:(NSString *)messageSender {
    self = [super init];
    if (self) {
        self.text = @"";
        self.sender = messageSender;
        self.timestamp = [NSDate date];
        self.isSpinner = YES;
        animationTimer = nil;
        animationState = 0;
    }
    return self;
}

- (void)dealloc {
    [self stopSpinnerAnimation];
    [text release];
    [sender release];
    [timestamp release];
    [super dealloc];
}

- (void)startSpinnerAnimation:(NSTableView *)tableView row:(NSInteger)row {
    if (!isSpinner || animationTimer) return;
    
    // Create timer that fires every 0.5 seconds for smooth animation
    animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                      target:self
                                                    selector:@selector(animateSpinner:)
                                                    userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             tableView, @"tableView",
                                                             [NSNumber numberWithInteger:row], @"row",
                                                             nil]
                                                     repeats:YES];
    [animationTimer retain];
}

- (void)stopSpinnerAnimation {
    if (animationTimer) {
        [animationTimer invalidate];
        [animationTimer release];
        animationTimer = nil;
    }
    animationState = 0;
}

- (void)animateSpinner:(NSTimer *)timer {
    NSDictionary *userInfo = [timer userInfo];
    NSTableView *tableView = [userInfo objectForKey:@"tableView"];
    NSInteger row = [[userInfo objectForKey:@"row"] integerValue];
    
    // Cycle through animation states (0, 1, 2, 3)
    animationState = (animationState + 1) % 4;
    
    // Update the text property with current spinner state
    [text release];
    text = [[self currentSpinnerText] retain];
    
    // Refresh the table view row
    if (tableView && row >= 0) {
        [tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row]
                             columnIndexes:[NSIndexSet indexSetWithIndex:0]];
    }
}

- (NSString *)currentSpinnerText {
    if (!isSpinner) return text;
    
    switch (animationState) {
        case 0: return @"";
        case 1: return @"•";
        case 2: return @"••";
        case 3: return @"•••";
        default: return @"";
    }
}

- (NSString *)description {
    if (isSpinner) {
        return [self currentSpinnerText];
    } else if ([sender isEqualToString:@"User"]) {
        return text;
    } else {
        return [NSString stringWithFormat:@"%@: %@", sender, text];
    }
}

@end

@implementation ChatConversation

- (id)initWithFrame:(NSRect)frame {
    self = [super init];
    if (self) {
        messages = [[NSMutableArray alloc] init];
        
        // Create scroll view for chat messages
        NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:frame];
        [scrollView setHasVerticalScroller:YES];
        [scrollView setBorderType:NSNoBorder];
        [scrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
        
        // Create table view for chat messages
        tableView = [[NSTableView alloc] initWithFrame:[[scrollView contentView] bounds]];
        [tableView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
        [tableView setDataSource:self];
        [tableView setDelegate:self];
        [tableView setHeaderView:nil]; // Hide header
        
        // Add column to table view
        NSTableColumn *messageColumn = [[NSTableColumn alloc] initWithIdentifier:@"MessageColumn"];
        [messageColumn setWidth:frame.size.width - 20];
        [tableView addTableColumn:messageColumn];
        [messageColumn release];
        
        [scrollView setDocumentView:tableView];
        
        // Add welcome messages
        [self addMessage:@"Welcome to ChatGPT Classic!" fromSender:@"System"];
        [self addMessage:@"This is a legacy macOS application built with Bazel." fromSender:@"System"];
        [self addMessage:@"Compatible with macOS 10.4 Tiger and later." fromSender:@"System"];
        
        // Store the scroll view as our main view
        mainView = [scrollView retain];
    }
    return self;
}

- (void)dealloc {
    // Stop any active spinner animations before dealloc
    [self removeSpinnerMessages];
    [messages release];
    [tableView release];
    [mainView release];
    [super dealloc];
}

- (NSView *)view {
    return mainView;
}

- (void)addMessage:(NSString *)text fromSender:(NSString *)sender {
    ChatMessage *message = [[ChatMessage alloc] initWithText:text sender:sender];
    [self addMessage:message];
    [message release];
}

- (void)addMessage:(ChatMessage *)message {
    [messages addObject:message];
    [tableView reloadData];
    [self scrollToBottom];
}

- (void)clearMessages {
    [messages removeAllObjects];
    [tableView reloadData];
}

- (NSArray *)messages {
    return [[messages copy] autorelease];
}

- (void)scrollToBottom {
    if ([messages count] > 0) {
        [tableView scrollRowToVisible:[messages count] - 1];
    }
}

- (ChatMessage *)addSpinnerMessage:(NSString *)sender {
    // Remove any existing spinner messages first
    [self removeSpinnerMessages];
    
    // Create and add new spinner message
    ChatMessage *spinnerMessage = [[ChatMessage alloc] initSpinnerMessageWithSender:sender];
    [messages addObject:spinnerMessage];
    [tableView reloadData];
    [self scrollToBottom];
    
    // Start the animation
    NSInteger row = [messages count] - 1;
    [spinnerMessage startSpinnerAnimation:tableView row:row];
    
    return [spinnerMessage autorelease];
}

- (void)removeSpinnerMessages {
    // Find and remove all spinner messages
    NSMutableArray *spinnersToRemove = [[NSMutableArray alloc] init];
    
    for (ChatMessage *message in messages) {
        if ([message isSpinner]) {
            [message stopSpinnerAnimation];
            [spinnersToRemove addObject:message];
        }
    }
    
    for (ChatMessage *spinner in spinnersToRemove) {
        [messages removeObject:spinner];
    }
    
    [spinnersToRemove release];
    
    if ([spinnersToRemove count] > 0) {
        [tableView reloadData];
    }
}

#pragma mark - NSTableView DataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [messages count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (row < [messages count]) {
        ChatMessage *message = [messages objectAtIndex:row];
        return [message description];
    }
    return nil;
}

@end