#import "MainWindowController.h"

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
        
        sidebarItems = [[NSMutableArray alloc] init];
        chatMessages = [[NSMutableArray alloc] init];
        
        [self setupWindow];
        [self setupToolbar];
        [self setupChatInput];
        [window release];
    }
    return self;
}

- (void)dealloc {
    [sidebarItems release];
    [chatMessages release];
    [sidebarOutlineView release];
    [chatTableView release];
    [splitView release];
    [toolbarView release];
    [chatInputField release];
    [sendButton release];
    [super dealloc];
}

- (void)setupWindow {
    NSWindow *window = [self window];
    NSView *contentView = [window contentView];
    NSRect contentBounds = [contentView bounds];
    
    // Create main container view for chat area (right side)
    NSRect chatContainerFrame = NSMakeRect(200, 0, contentBounds.size.width - 200, contentBounds.size.height);
    NSView *chatContainer = [[NSView alloc] initWithFrame:chatContainerFrame];
    [chatContainer setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    
    // Create split view
    splitView = [[NSSplitView alloc] initWithFrame:contentBounds];
    [splitView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    [splitView setVertical:YES];
    [contentView addSubview:splitView];
    
    [self setupSidebar];
    [self setupChatArea:chatContainer];
    
    [splitView addSubview:chatContainer];
    [chatContainer release];
    
    // Set split view proportions
    [splitView setPosition:200 ofDividerAtIndex:0];
}

- (void)setupChatArea:(NSView *)chatContainer {
    NSRect containerBounds = [chatContainer bounds];
    
    // Toolbar at top (50px height)
    NSRect toolbarFrame = NSMakeRect(0, containerBounds.size.height - 50, 
                                    containerBounds.size.width, 50);
    toolbarView = [[NSView alloc] initWithFrame:toolbarFrame];
    [toolbarView setAutoresizingMask:(NSViewWidthSizable | NSViewMinYMargin)];
    [toolbarView setWantsLayer:YES];
    [[toolbarView layer] setBackgroundColor:[[NSColor colorWithCalibratedRed:0.98 green:0.98 blue:0.98 alpha:1.0] CGColor]];
    [chatContainer addSubview:toolbarView];
    
    // Chat input at bottom (60px height)
    NSRect inputFrame = NSMakeRect(0, 0, containerBounds.size.width, 60);
    NSView *inputContainer = [[NSView alloc] initWithFrame:inputFrame];
    [inputContainer setAutoresizingMask:(NSViewWidthSizable | NSViewMaxYMargin)];
    [inputContainer setWantsLayer:YES];
    [[inputContainer layer] setBackgroundColor:[[NSColor colorWithCalibratedRed:0.98 green:0.98 blue:0.98 alpha:1.0] CGColor]];
    [chatContainer addSubview:inputContainer];
    
    // Chat messages area in the middle
    NSRect chatFrame = NSMakeRect(0, 60, containerBounds.size.width, 
                                 containerBounds.size.height - 110); // 50 for toolbar + 60 for input
    [self setupChatTable:chatFrame inContainer:chatContainer];
    
    // Setup input field in input container
    [self setupInputInContainer:inputContainer];
    
    [inputContainer release];
}

- (void)setupSidebar {
    NSRect sidebarFrame = NSMakeRect(0, 0, 200, 600);
    
    // Create scroll view for sidebar
    NSScrollView *sidebarScrollView = [[NSScrollView alloc] initWithFrame:sidebarFrame];
    [sidebarScrollView setHasVerticalScroller:YES];
    [sidebarScrollView setBorderType:NSBezelBorder];
    [sidebarScrollView setAutoresizingMask:(NSViewHeightSizable | NSViewMaxXMargin)];
    
    // Create outline view for sidebar
    sidebarOutlineView = [[NSOutlineView alloc] initWithFrame:[[sidebarScrollView contentView] bounds]];
    [sidebarOutlineView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    [sidebarOutlineView setDataSource:self];
    [sidebarOutlineView setDelegate:self];
    
    // Add column to outline view
    NSTableColumn *sidebarColumn = [[NSTableColumn alloc] initWithIdentifier:@"SidebarColumn"];
    [[sidebarColumn headerCell] setStringValue:@"Conversations"];
    [sidebarColumn setWidth:180];
    [sidebarOutlineView addTableColumn:sidebarColumn];
    [sidebarColumn release];
    
    [sidebarScrollView setDocumentView:sidebarOutlineView];
    [splitView addSubview:sidebarScrollView];
    [sidebarScrollView release];
    
    // Add some sample items
    [sidebarItems addObject:@"New Conversation"];
    [sidebarItems addObject:@"Previous Chat 1"];
    [sidebarItems addObject:@"Previous Chat 2"];
}

- (void)setupChatTable:(NSRect)chatFrame inContainer:(NSView *)container {
    // Create scroll view for chat table
    NSScrollView *chatScrollView = [[NSScrollView alloc] initWithFrame:chatFrame];
    [chatScrollView setHasVerticalScroller:YES];
    [chatScrollView setBorderType:NSNoBorder];
    [chatScrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    
    // Create table view for chat messages
    chatTableView = [[NSTableView alloc] initWithFrame:[[chatScrollView contentView] bounds]];
    [chatTableView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    [chatTableView setDataSource:self];
    [chatTableView setDelegate:self];
    [chatTableView setHeaderView:nil]; // Hide header
    
    // Add columns to table view
    NSTableColumn *messageColumn = [[NSTableColumn alloc] initWithIdentifier:@"MessageColumn"];
    [messageColumn setWidth:chatFrame.size.width - 20];
    [chatTableView addTableColumn:messageColumn];
    [messageColumn release];
    
    [chatScrollView setDocumentView:chatTableView];
    [container addSubview:chatScrollView];
    [chatScrollView release];
    
    // Add some sample messages
    [chatMessages addObject:@"Welcome to ChatGPT Classic!"];
    [chatMessages addObject:@"This is a legacy macOS application built with Bazel."];
    [chatMessages addObject:@"Compatible with macOS 10.4 Tiger and later."];
}

- (void)setupInputInContainer:(NSView *)inputContainer {
    NSRect containerBounds = [inputContainer bounds];
    
    // Chat input field (with padding)
    NSRect inputFieldFrame = NSMakeRect(20, 15, containerBounds.size.width - 100, 30);
    chatInputField = [[NSTextField alloc] initWithFrame:inputFieldFrame];
    [chatInputField setAutoresizingMask:(NSViewWidthSizable)];
    [chatInputField setTarget:self];
    [chatInputField setAction:@selector(sendMessage:)];
    [[chatInputField cell] setPlaceholderString:@"Ask anything"];
    [inputContainer addSubview:chatInputField];
    
    // Send button
    NSRect buttonFrame = NSMakeRect(containerBounds.size.width - 70, 15, 50, 30);
    sendButton = [[NSButton alloc] initWithFrame:buttonFrame];
    [sendButton setAutoresizingMask:(NSViewMinXMargin)];
    [sendButton setTitle:@"Send"];
    [sendButton setTarget:self];
    [sendButton setAction:@selector(sendMessage:)];
    [inputContainer addSubview:sendButton];
}

- (void)setupToolbar {
    if (!toolbarView) return;
    
    NSRect toolbarBounds = [toolbarView bounds];
    
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

- (void)setupChatInput {
    // This method is called from init but the actual input setup 
    // happens in setupInputInContainer which is called from setupChatArea
}

- (IBAction)sendMessage:(id)sender {
    NSString *message = [chatInputField stringValue];
    if ([message length] > 0) {
        [chatMessages addObject:message];
        [chatTableView reloadData];
        [chatInputField setStringValue:@""];
        
        // Scroll to bottom
        if ([chatMessages count] > 0) {
            [chatTableView scrollRowToVisible:[chatMessages count] - 1];
        }
    }
}

#pragma mark - NSOutlineView DataSource

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (item == nil) {
        return [sidebarItems count];
    }
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
    if (item == nil) {
        return [sidebarItems objectAtIndex:index];
    }
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    return item;
}

#pragma mark - NSTableView DataSource

- (int)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView == chatTableView) {
        return [chatMessages count];
    }
    return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
    if (tableView == chatTableView) {
        return [chatMessages objectAtIndex:row];
    }
    return nil;
}

@end