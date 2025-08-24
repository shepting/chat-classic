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
    [super dealloc];
}

- (void)setupWindow {
    NSWindow *window = [self window];
    NSView *contentView = [window contentView];
    
    // Create split view
    splitView = [[NSSplitView alloc] initWithFrame:[contentView bounds]];
    [splitView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    [splitView setVertical:YES];
    [contentView addSubview:splitView];
    
    [self setupSidebar];
    [self setupChatTable];
    
    // Set split view proportions
    [splitView setPosition:200 ofDividerAtIndex:0];
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

- (void)setupChatTable {
    NSRect chatFrame = NSMakeRect(200, 0, 600, 600);
    
    // Create scroll view for chat table
    NSScrollView *chatScrollView = [[NSScrollView alloc] initWithFrame:chatFrame];
    [chatScrollView setHasVerticalScroller:YES];
    [chatScrollView setBorderType:NSBezelBorder];
    [chatScrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    
    // Create table view for chat messages
    chatTableView = [[NSTableView alloc] initWithFrame:[[chatScrollView contentView] bounds]];
    [chatTableView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    [chatTableView setDataSource:self];
    [chatTableView setDelegate:self];
    
    // Add columns to table view
    NSTableColumn *messageColumn = [[NSTableColumn alloc] initWithIdentifier:@"MessageColumn"];
    [[messageColumn headerCell] setStringValue:@"Messages"];
    [messageColumn setWidth:580];
    [chatTableView addTableColumn:messageColumn];
    [messageColumn release];
    
    [chatScrollView setDocumentView:chatTableView];
    [splitView addSubview:chatScrollView];
    [chatScrollView release];
    
    // Add some sample messages
    [chatMessages addObject:@"Welcome to ChatGPT Classic!"];
    [chatMessages addObject:@"This is a legacy macOS application built with Bazel."];
    [chatMessages addObject:@"Compatible with macOS 10.4 Tiger and later."];
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