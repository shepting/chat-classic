#import "MainWindowController.h"
#import "App.h"

@implementation MainWindowController

- (id)init {
    NSRect contentRect = NSMakeRect(100, 100, 800, 600);
    NSWindow *window = [[NSWindow alloc] 
        initWithContentRect:contentRect
        styleMask:(NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask)
        backing:NSBackingStoreBuffered
        defer:NO];
    
    self = [super initWithWindow:window];
    if (self) {
        [window setTitle:@"ChatGPT Classic"];
        [window setMinSize:NSMakeSize(600, 400)];
        
        [self setupWindow];
        [self setupModules];
        [self setupToolbar];
        [window release];
    }
    return self;
}

- (void)dealloc {
    [historyTable release];
    [chatConversation release];
    [chatInput release];
    [splitView release];
    [toolbarView release];
    [currentStreamingResponse release];
    [super dealloc];
}

- (void)setupWindow {
    NSWindow *window = [self window];
    NSView *contentView = [window contentView];
    NSRect contentBounds = [contentView bounds];
    
    // Create split view
    splitView = [[NSSplitView alloc] initWithFrame:contentBounds];
    [splitView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    [splitView setVertical:YES];
    [contentView addSubview:splitView];
    
    // Set split view proportions
    [splitView setPosition:200 ofDividerAtIndex:0];
}

- (void)setupModules {
    NSWindow *window = [self window];
    NSView *contentView = [window contentView];
    NSRect contentBounds = [contentView bounds];
    
    // Setup sidebar (HistoryTable)
    NSRect sidebarFrame = NSMakeRect(0, 0, 200, contentBounds.size.height);
    historyTable = [[HistoryTable alloc] initWithFrame:sidebarFrame];
    [historyTable setDelegate:self];
    [splitView addSubview:[historyTable view]];
    
    // Create main container view for chat area (right side)
    NSRect chatContainerFrame = NSMakeRect(0, 0, contentBounds.size.width - 200, contentBounds.size.height);
    NSView *chatContainer = [[NSView alloc] initWithFrame:chatContainerFrame];
    [chatContainer setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    
    NSRect containerBounds = [chatContainer bounds];
    
    // Toolbar at top (50px height)
    NSRect toolbarFrame = NSMakeRect(0, containerBounds.size.height - 50, 
                                    containerBounds.size.width, 50);
    toolbarView = [[NSView alloc] initWithFrame:toolbarFrame];
    [toolbarView setAutoresizingMask:(NSViewWidthSizable | NSViewMinYMargin)];
    [toolbarView setWantsLayer:YES];
    [[toolbarView layer] setBackgroundColor:[[NSColor colorWithCalibratedRed:0.98 green:0.98 blue:0.98 alpha:1.0] CGColor]];
    [chatContainer addSubview:toolbarView];
    
    // Chat input at bottom (80px height for multi-line)
    NSRect inputFrame = NSMakeRect(0, 0, containerBounds.size.width, 80);
    chatInput = [[ChatInput alloc] initWithFrame:inputFrame];
    [chatInput setDelegate:self];
    [chatContainer addSubview:[chatInput view]];
    
    // Chat conversation in the middle
    NSRect chatFrame = NSMakeRect(0, 80, containerBounds.size.width, 
                                 containerBounds.size.height - 130); // 50 for toolbar + 80 for input
    chatConversation = [[ChatConversation alloc] initWithFrame:chatFrame];
    [chatContainer addSubview:[chatConversation view]];
    
    [splitView addSubview:chatContainer];
    [chatContainer release];
    
    // Setup networking
    networking = [Networking sharedNetworking];
    [networking setDelegate:self];
    
    // Initialize streaming variables
    currentStreamingResponse = nil;
    isCurrentlyStreaming = NO;
}

- (void)setupToolbar {
    if (!toolbarView) return;
    
    // Title label
    NSRect titleFrame = NSMakeRect(20, 15, 200, 20);
    NSTextField *titleLabel = [[NSTextField alloc] initWithFrame:titleFrame];
    [titleLabel setStringValue:@"ChatGPT 5"];
    [titleLabel setEditable:NO];
    [titleLabel setBordered:NO];
    [titleLabel setBackgroundColor:[NSColor clearColor]];
    [titleLabel setFont:[NSFont boldSystemFontOfSize:16]];
    [toolbarView addSubview:titleLabel];
    [titleLabel release];
}

#pragma mark - HistoryTableDelegate

- (void)historyTable:(HistoryTable *)historyTable didSelectConversationAtIndex:(NSInteger)index {
    // Handle conversation selection
    // For now, just clear the current conversation when switching
    [chatConversation clearMessages];
    
    if (index == 0) {
        // "New Conversation" selected
        [chatConversation addMessage:@"New conversation started!" fromSender:@"System"];
    } else {
        // Load a previous conversation (simulated)
        [chatConversation addMessage:[NSString stringWithFormat:@"Loaded conversation %ld", (long)index] fromSender:@"System"];
        [chatConversation addMessage:@"This is a simulated previous conversation." fromSender:@"User"];
        [chatConversation addMessage:@"Yes, this demonstrates loading chat history." fromSender:@"Assistant"];
    }
}

#pragma mark - ChatInputDelegate

- (void)chatInput:(ChatInput *)chatInput didSendMessage:(NSString *)message {
    // Add user message to conversation
    [chatConversation addMessage:message fromSender:@"User"];
    
    // Send message through networking for response
    [networking sendChatMessage:message];
}

- (BOOL)chatInputShouldSendMessage:(ChatInput *)chatInput {
    // Always allow sending for now
    return YES;
}

#pragma mark - NetworkingDelegate

- (void)networking:(Networking *)networking didReceiveChatResponse:(NSString *)response {
    // Add assistant response to conversation (fallback for non-streaming)
    [chatConversation addMessage:response fromSender:@"Assistant"];
}

- (void)networking:(Networking *)networking didStartStreaming:(id)sender {
    isCurrentlyStreaming = YES;
    [currentStreamingResponse release];
    currentStreamingResponse = [[NSString alloc] init];
    
    // Add placeholder message that we'll update as we stream
    [chatConversation addMessage:@"" fromSender:@"Assistant"];
}

- (void)networking:(Networking *)networking didReceiveStreamingChunk:(NSString *)chunk {
    if (!isCurrentlyStreaming) return;
    
    // Append chunk to current response
    NSString *newResponse = [currentStreamingResponse stringByAppendingString:chunk];
    [currentStreamingResponse release];
    currentStreamingResponse = [newResponse retain];
    
    // Update the last message in the conversation
    NSMutableArray *messages = (NSMutableArray *)[chatConversation messages];
    if ([messages count] > 0) {
        ChatMessage *lastMessage = [messages lastObject];
        if ([[lastMessage sender] isEqualToString:@"Assistant"]) {
            // Update the text of the last assistant message
            [lastMessage setText:currentStreamingResponse];
            // Refresh the table view to show updated content
            // Note: This is a simplified approach; in a real implementation
            // you'd want more efficient updating
            [chatConversation performSelector:@selector(scrollToBottom) withObject:nil afterDelay:0.0];
        }
    }
}

- (void)networking:(Networking *)networking didFinishStreaming:(id)sender {
    isCurrentlyStreaming = NO;
    
    // Add final assistant message to conversation history (for Networking module)
    if (currentStreamingResponse && [currentStreamingResponse length] > 0) {
        NSDictionary *assistantMessage = [NSDictionary dictionaryWithObjectsAndKeys:
                                         @"assistant", @"role",
                                         currentStreamingResponse, @"content",
                                         nil];
        [[networking conversationHistory] addObject:assistantMessage];
    }
}

@end