#import "ChatConversation.h"

@implementation ChatMessage

@synthesize text, sender, timestamp;

- (id)initWithText:(NSString *)messageText sender:(NSString *)messageSender {
    self = [super init];
    if (self) {
        self.text = messageText;
        self.sender = messageSender;
        self.timestamp = [NSDate date];
    }
    return self;
}

- (void)dealloc {
    [text release];
    [sender release];
    [timestamp release];
    [super dealloc];
}

- (NSString *)description {
    if ([sender isEqualToString:@"User"]) {
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

#pragma mark - NSTableView DataSource

- (int)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [messages count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
    if (row < [messages count]) {
        ChatMessage *message = [messages objectAtIndex:row];
        return [message description];
    }
    return nil;
}

@end