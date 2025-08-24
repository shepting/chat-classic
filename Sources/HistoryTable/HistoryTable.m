#import "HistoryTable.h"

@implementation HistoryTable

- (id)initWithFrame:(NSRect)frame {
    self = [super init];
    if (self) {
        conversations = [[NSMutableArray alloc] init];
        
        // Create scroll view for sidebar
        NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:frame];
        [scrollView setHasVerticalScroller:YES];
        [scrollView setBorderType:NSBezelBorder];
        [scrollView setAutoresizingMask:(NSViewHeightSizable | NSViewMaxXMargin)];
        
        // Create outline view for sidebar
        outlineView = [[NSOutlineView alloc] initWithFrame:[[scrollView contentView] bounds]];
        [outlineView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
        [outlineView setDataSource:self];
        [outlineView setDelegate:self];
        
        // Add column to outline view
        NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"ConversationColumn"];
        [[column headerCell] setStringValue:@"Conversations"];
        [column setWidth:frame.size.width - 20];
        [outlineView addTableColumn:column];
        [column release];
        
        [scrollView setDocumentView:outlineView];
        
        // Add default conversations
        [conversations addObject:@"New Conversation"];
        [conversations addObject:@"Previous Chat 1"];
        [conversations addObject:@"Previous Chat 2"];
        
        // Store the scroll view as our main view
        [scrollView retain]; // We'll release this in dealloc
        [self setValue:scrollView forKey:@"mainView"];
        [scrollView release]; // Release our local reference
    }
    return self;
}

- (void)dealloc {
    [conversations release];
    [outlineView release];
    [[self valueForKey:@"mainView"] release];
    [super dealloc];
}

- (NSView *)view {
    return [self valueForKey:@"mainView"];
}

- (void)setDelegate:(id<HistoryTableDelegate>)newDelegate {
    delegate = newDelegate;
}

- (void)addConversation:(NSString *)title {
    [conversations addObject:title];
    [outlineView reloadData];
}

- (void)selectConversationAtIndex:(NSInteger)index {
    if (index >= 0 && index < [conversations count]) {
        [outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    }
}

- (NSInteger)selectedConversationIndex {
    return [outlineView selectedRow];
}

#pragma mark - NSOutlineView DataSource

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (item == nil) {
        return [conversations count];
    }
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
    if (item == nil) {
        return [conversations objectAtIndex:index];
    }
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    return item;
}

#pragma mark - NSOutlineView Delegate

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    NSInteger selectedIndex = [outlineView selectedRow];
    if (delegate && [delegate respondsToSelector:@selector(historyTable:didSelectConversationAtIndex:)]) {
        [delegate historyTable:self didSelectConversationAtIndex:selectedIndex];
    }
}

@end