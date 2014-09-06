//
//  Locksmith.m
//  Locksmith
//
//  Created by Alan Stephensen on 6/09/2014.
//  Copyright (c) 2014 Alan Stephensen. All rights reserved.
//

#import "Locksmith.h"

#define LocksmithShortcutsArrayKey "shortcuts"

@interface Locksmith () <NSTableViewDataSource, NSTableViewDelegate>
@property (nonatomic, strong) NSMutableArray *shortcuts;
@property (nonatomic, weak) IBOutlet NSTableView *tableView;
@end

@implementation Locksmith

+ (void)initialize
{

}

- (void)mainViewDidLoad
{
    // Setup table view.
    [self.tableView registerForDraggedTypes:[NSArray arrayWithObject:@"public.text"]];
    
    
    // Load saved shortcuts.
    [self loadShortcuts];
    [self.tableView reloadData];
}

#pragma mark - Methods

- (void)loadShortcuts
{
    const char* const appID = [[[NSBundle bundleForClass:[self class]] bundleIdentifier] cStringUsingEncoding:NSASCIIStringEncoding];
    CFStringRef bundleID = CFStringCreateWithCString(kCFAllocatorDefault, appID, kCFStringEncodingASCII);
    
    CFArrayRef shortcutsArrayRef = CFPreferencesCopyAppValue(CFSTR(LocksmithShortcutsArrayKey), bundleID);
    if (shortcutsArrayRef != NULL) {
        NSArray *shortcutsArray = (__bridge_transfer NSArray *)(shortcutsArrayRef);
        self.shortcuts = [shortcutsArray mutableCopy];
        NSLog(@"Loaded shortcuts: %@", self.shortcuts);
    } else {
        self.shortcuts = [NSMutableArray array];
    }
    
    CFRelease(bundleID);
}

- (void)saveShortcuts
{
    const char* const appID = [[[NSBundle bundleForClass:[self class]] bundleIdentifier] cStringUsingEncoding:NSASCIIStringEncoding];
    CFStringRef bundleID = CFStringCreateWithCString(kCFAllocatorDefault, appID, kCFStringEncodingASCII);
    
    CFPreferencesSetAppValue(CFSTR(LocksmithShortcutsArrayKey), (__bridge CFPropertyListRef)(self.shortcuts), bundleID);
    
    CFRelease(bundleID);
}

#pragma mark - Actions

- (IBAction)addClicked:(id)sender
{
    NSDictionary *blankShortcut = @{@"shortcut": @"",
                                    @"replacement": @""};
    [self.shortcuts addObject:blankShortcut];
    [self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:[self.shortcuts count] - 1] withAnimation:NSTableViewAnimationEffectFade];
}

- (IBAction)removeClicked:(id)sender
{
    NSInteger selectedRow = [self.tableView selectedRow];
    if (selectedRow != -1) {
        [self.shortcuts removeObjectAtIndex:selectedRow];
        [self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:selectedRow] withAnimation:NSTableViewAnimationEffectFade];
        [self saveShortcuts];
    }
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.shortcuts count];
}

#pragma mark - Table View Delegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSDictionary *shortcut = self.shortcuts[row];
    
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    if ([tableColumn.identifier isEqualToString:@"shortcut"]) {
        cellView.textField.stringValue = shortcut[@"shortcut"];
    } else if ([tableColumn.identifier isEqualToString:@"replacement"]) {
        cellView.textField.stringValue = shortcut[@"replacement"];
    }
    
    return cellView;
}

#pragma mark Drag and Drop

- (id<NSPasteboardWriting>)tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row
{
    NSPasteboardItem *pasteboardItem = [[NSPasteboardItem alloc] init];
    [pasteboardItem setString:@"Hello" forType:@"public.text"];
    return pasteboardItem;
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
    // Only allow dropping between other items.
    if (dropOperation == NSTableViewDropAbove) {
        return NSDragOperationMove;
    }
    return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation
{
    return YES;
}

#pragma mark - Notifications

- (void)controlTextDidEndEditing:(NSNotification *)notification
{
    NSTextField *textField = notification.object;
    NSInteger rowIndex = [self.tableView rowForView:textField.superview];
    
    NSMutableDictionary *shortcut = [self.shortcuts[rowIndex] mutableCopy];
    if ([textField.identifier isEqualToString:@"shortcutTextField"]) {
        shortcut[@"shortcut"] = textField.stringValue;
    } else if ([textField.identifier isEqualToString:@"replacementTextField"]) {
        shortcut[@"replacement"] = textField.stringValue;
    }
    self.shortcuts[rowIndex] = shortcut;
    
    // Save the shortcuts. This seems a bit overkill, but preference panes can be terminated at any point.
    [self saveShortcuts];
}

@end
