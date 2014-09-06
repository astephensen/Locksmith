//
//  Locksmith.m
//  Locksmith
//
//  Created by Alan Stephensen on 6/09/2014.
//  Copyright (c) 2014 Alan Stephensen. All rights reserved.
//

#import "Locksmith.h"

#define LocksmithShortcutsArrayKey "shortcuts"
#define BundleIdentifier "io.alan.LocksmithHelper"
#define BundleIdentifierString @BundleIdentifier
#define NotificationIdentifier @"io.alan.Locksmith.prefPaneNotification"

@interface Locksmith () <NSTableViewDataSource, NSTableViewDelegate>
@property (nonatomic, strong) NSMutableArray *shortcuts;
@property (nonatomic, weak) IBOutlet NSTabView *tabView;
@property (nonatomic, weak) IBOutlet NSTableView *tableView;
@property (nonatomic, weak) IBOutlet NSTextField *statusLabel;
@property (nonatomic, weak) IBOutlet NSButton *launchButton;
@property (nonatomic, strong) NSConnection *locksmithPreferencesServerConnection;
@end

@implementation Locksmith

+ (void)initialize
{

}

- (void)mainViewDidLoad
{
    [super mainViewDidLoad];
    
    // Setup table view.
    [self.tableView registerForDraggedTypes:[NSArray arrayWithObject:@"public.text"]];
}

- (void)willSelect
{
    [super willSelect];
    
    // Check if the helper is trusted.
    if (![self isHelperApplicationRunning]) {
        [self.tabView selectTabViewItemAtIndex:2];
    } else {
        [self launchSetup];
    }
}

- (void)didSelect
{
    [super didSelect];
}

#pragma mark - Setup

- (void)launchSetup
{
    [self checkTrusted];
    [self loadShortcuts];
    [self.tableView reloadData];
    [self updateStatus];
}

- (void)checkTrusted
{
    // Connect to the helper application and ask if it is trusted.
    NSConnection *helperConnection = [NSConnection connectionWithRegisteredName:@"LocksmithHelper" host:nil];;
    id remoteObject = [helperConnection rootProxy];
    if ([remoteObject respondsToSelector:NSSelectorFromString(@"isProcessTrusted")]) {
        NSNumber *object = [remoteObject performSelector:NSSelectorFromString(@"isProcessTrusted")];
        BOOL isProcessTrusted = [object boolValue];
        if (!isProcessTrusted) {
            [self.tabView selectTabViewItemAtIndex:0];
        } else {
            [self.tabView selectTabViewItemAtIndex:1];
        }
    }
}

#pragma mark - Methods

- (void)loadShortcuts
{
    CFArrayRef shortcutsArrayRef = CFPreferencesCopyAppValue(CFSTR(LocksmithShortcutsArrayKey), CFSTR(BundleIdentifier));
    if (shortcutsArrayRef != NULL) {
        NSArray *shortcutsArray = (__bridge_transfer NSArray *)(shortcutsArrayRef);
        self.shortcuts = [shortcutsArray mutableCopy];
        NSLog(@"Loaded shortcuts: %@", self.shortcuts);
    } else {
        self.shortcuts = [NSMutableArray array];
    }
}

- (void)saveShortcuts
{
    CFPreferencesSetAppValue(CFSTR(LocksmithShortcutsArrayKey), (__bridge CFPropertyListRef)(self.shortcuts), CFSTR(BundleIdentifier));
    CFPreferencesAppSynchronize(CFSTR(BundleIdentifier));
    
    // Tell helper application the shortcuts have changed.
    NSConnection *helperConnection = [NSConnection connectionWithRegisteredName:@"LocksmithHelper" host:nil];;
    id remoteObject = [helperConnection rootProxy];
    if ([remoteObject respondsToSelector:NSSelectorFromString(@"reloadShortcuts")]) {
        [remoteObject performSelector:NSSelectorFromString(@"reloadShortcuts")];
    }
}

- (void)updateStatus
{
    if ([self isHelperApplicationRunning]) {
        self.launchButton.title = @"Stop Locksmith";
        self.statusLabel.stringValue = @"Locksmith is running.";
    } else {
        self.launchButton.title = @"Start Locksmith";
        self.statusLabel.stringValue = @"Locksmith is not currently running.";
    }
}

#pragma mark - Helper Application Methods

- (BOOL)isHelperApplicationRunning
{
    for (NSRunningApplication *app in [NSWorkspace sharedWorkspace].runningApplications) {
        if ([app.bundleIdentifier isEqualToString:BundleIdentifierString]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)launchHelperApplication
{
    if ([self isHelperApplicationRunning]) {
        NSLog(@"Helper application is already running!");
        return NO;
    }
    
    NSURL *helperURL = [[self bundle] URLForResource:@"LocksmithHelper" withExtension:@"app"];
    NSRunningApplication *runningApplication = [[NSWorkspace sharedWorkspace] launchApplicationAtURL:helperURL options:NSWorkspaceLaunchDefault configuration:nil error:NULL];
    return (runningApplication ? YES : NO);
}

- (BOOL)terminateHelperApplication
{
    for (NSRunningApplication *app in [NSWorkspace sharedWorkspace].runningApplications) {
        if ([app.bundleIdentifier isEqualToString:BundleIdentifierString]) {
            return [app terminate];
        }
    }
    return NO;
}

#pragma mark - Actions

- (IBAction)launchClicked:(id)sender
{
    [self launchHelperApplication];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self launchSetup];
    });
}

- (IBAction)askForTrustClicked:(id)sender
{
    // Connect to the helper application and ask to be authorised.
    NSConnection *helperConnection = [NSConnection connectionWithRegisteredName:@"LocksmithHelper" host:nil];;
    id remoteObject = [helperConnection rootProxy];
    if ([remoteObject respondsToSelector:NSSelectorFromString(@"askForTrust")]) {
        [remoteObject performSelector:NSSelectorFromString(@"askForTrust")];
    }
}

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
    // TODO: All this drag and drop stuff.
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
