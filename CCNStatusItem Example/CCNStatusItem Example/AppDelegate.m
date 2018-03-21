//
//  Created by Frank Gregor on 28.12.14.
//  Copyright (c) 2014 cocoa:naut. All rights reserved.
//

#import "AppDelegate.h"
#import "CCNStatusItem.h"
#import "CCNStatusItemWindowConfiguration.h"
#import "ContentViewController.h"


@interface AppDelegate ()
@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSButton *appearsDisabledCheckbox;
@property (weak) IBOutlet NSButton *disableCheckbox;
@property (weak) IBOutlet NSButton *proximityDetectionCheckbox;
@property (weak) IBOutlet NSButton *dragAndDropCheckbox;
@property (weak) IBOutlet NSButton *extendedDragAndDropCheckbox;
@property (weak) IBOutlet NSButton *pinPopoverCheckbox;
@property (weak) IBOutlet NSSlider *proximityDragZoneDistanceSlider;
@property (weak) IBOutlet NSTextField *currentpProximityDragZoneDistanceTextField;
@property (weak) IBOutlet NSMatrix *presentationTransitionRadios;

@property (assign) BOOL proximityDetectionEnabled;
@property (readwrite, assign) NSInteger proximitySliderValue;

@property NSView *customItemView;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // configure the status item
    CCNStatusItem *sharedItem = [CCNStatusItem sharedInstance];
    sharedItem.windowConfiguration.presentationTransition = CCNPresentationTransitionSlideAndFade;
    sharedItem.proximityDragDetectionHandler = [self proximityDragDetectionHandler];

    
    // Uncomment this to get a status item with an image.
    [self presentStatusItemWithImage];
    
    // Uncomment this to get a status item with a custom view.
//    [self presentStatusItemWithCustomView];
    
    
    // restore GUI elements
    // (this is an excerpt from the example app)
    self.proximitySliderValue = sharedItem.proximityDragZoneDistance;
    self.appearsDisabledCheckbox.state = (sharedItem.appearsDisabled ? NSOnState : NSOffState);
    self.disableCheckbox.state = (sharedItem.enabled ? NSOffState : NSOnState);
    [self.presentationTransitionRadios selectCellAtRow:(NSInteger)sharedItem.windowConfiguration.presentationTransition column:0];
}

- (void)presentStatusItemWithImage {
    CCNStatusItem *sharedItem = [CCNStatusItem sharedInstance];
    [sharedItem presentStatusItemWithImage:[NSImage imageNamed:@"statusbar-icon"]
                     contentViewController:[ContentViewController viewController]
                               dropHandler:nil];
}

- (void)presentStatusItemWithCustomView {
    NSImageView *imageView = [[NSImageView alloc] init];
    imageView.image = [NSImage imageNamed:@"statusbar-icon"];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    NSTextField *textField = [[NSTextField alloc] init];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSCenterTextAlignment;
    paragraphStyle.minimumLineHeight = 19;
    
    NSDictionary *attributes = @{ NSFontAttributeName: [NSFont boldSystemFontOfSize:14.0], NSParagraphStyleAttributeName: paragraphStyle };
    textField.attributedStringValue = [[NSAttributedString alloc] initWithString:@"CCNStatusItem" attributes:attributes];
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    textField.backgroundColor = [NSColor clearColor];
    textField.bordered = NO;
    textField.editable = NO;
    textField.selectable = NO;
    
    // FIXME: I have absolutely no idea why the heck the width of that calculated rect is shorter than the given attributed string!
    NSRect textFieldRect = [textField.attributedStringValue boundingRectWithSize:NSMakeSize(CGFLOAT_MAX, [NSStatusBar systemStatusBar].thickness)
                                                                         options:NSStringDrawingUsesLineFragmentOrigin];
    
    CGFloat imageWidth = imageView.image.size.width;
    CGFloat textFieldWidth = textFieldRect.size.width;
    CGFloat systemStatusBarHeight = [NSStatusBar systemStatusBar].thickness;
    NSInteger padding = 2;
    CGFloat customItemViewWidth = padding + imageWidth + ceilf(NSWidth(textFieldRect)) + padding;
    
    
    self.customItemView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, customItemViewWidth, systemStatusBarHeight)];
    [self.customItemView addSubview:imageView];
    [self.customItemView addSubview:textField];
    
    NSDictionary *views = @{
        @"imageView": imageView,
        @"textField": textField,
    };
    NSDictionary *metrics = @{
        @"imageWidth": @(imageWidth),
        @"systemStatusBarHeight": @(systemStatusBarHeight),
        @"textFieldWidth": @(textFieldWidth),
        @"padding": @(padding),
    };
    [self.customItemView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(padding)-[imageView(imageWidth)][textField(textFieldWidth)]-(padding)-|" options:0 metrics:metrics views:views]];
    [self.customItemView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView(systemStatusBarHeight)]|" options:0 metrics:metrics views:views]];
    [self.customItemView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textField(systemStatusBarHeight)]|" options:0 metrics:metrics views:views]];
    
    CCNStatusItem *sharedItem = [CCNStatusItem sharedInstance];
    [sharedItem presentStatusItemWithView:self.customItemView
                    contentViewController:[ContentViewController viewController]];
}

- (CCNStatusItemProximityDragDetectionHandler)proximityDragDetectionHandler {
    return ^(CCNStatusItem *item, NSPoint eventLocation, CCNStatusItemProximityDragStatus dragStatus) {
        switch (dragStatus) {
            case CCNProximityDragStatusEntered:
                [item showStatusItemWindow];
                break;

            case CCNProximityDragStatusExited:
                [item dismissStatusItemWindow];
                break;
        }
    };
}

- (IBAction)appearsDisabledCheckboxAction:(id)sender {
    [CCNStatusItem sharedInstance].appearsDisabled = (self.appearsDisabledCheckbox.state == NSOnState);
}

- (IBAction)disableCheckboxAction:(id)sender {
    [CCNStatusItem sharedInstance].enabled = (self.disableCheckbox.state == NSOffState);
}

- (IBAction)proximityDetectionCheckboxAction:(NSButton *)proximityDetectionCheckbox {
    CCNStatusItem *sharedItem = [CCNStatusItem sharedInstance];
    sharedItem.proximityDragDetectionEnabled = (proximityDetectionCheckbox.state == NSOnState);
}

- (IBAction)dragAndDropCheckboxAction:(NSButton *)dragAndDropCheckbox {
    CCNStatusItem *sharedItem = [CCNStatusItem sharedInstance];
    if (dragAndDropCheckbox.state == NSOnState) {

        self.extendedDragAndDropCheckbox.state = NSOffState;
        sharedItem.extendedDropHandler  = nil;

        sharedItem.dropTypes = @[NSFilenamesPboardType];
        sharedItem.dropHandler = ^(CCNStatusItem *sharedItem, NSString *pasteboardType, NSArray *droppedObjects) {
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"Dropped Objects";
            __block NSMutableString *objects = [NSMutableString new];
            [droppedObjects enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
                [objects appendFormat:@"%@. %@\n\n", @(idx+1), path];
            }];
            alert.informativeText = objects;
            [alert runModal];
        };
    }
    else {
        sharedItem.dropHandler = nil;
    }
}

- (IBAction)extendedDragAndDropCheckboxAction:(NSButton *)extendedDragAndDropCheckbox {
    CCNStatusItem *sharedItem = [CCNStatusItem sharedInstance];
    if (extendedDragAndDropCheckbox.state == NSOnState) {

        self.dragAndDropCheckbox.state = NSOffState;
        sharedItem.dropHandler = nil;
        sharedItem.dropTypes = @[NSFilenamesPboardType,
                                     NSURLPboardType,
                                     NSTIFFPboardType,
                                     (NSString *)kUTTypeImage,
                                     (NSString *)kUTTypeVCard
                                     ];

        sharedItem.extendedDropHandler = ^BOOL(CCNStatusItem *sharedItem, NSArray<NSPasteboardItem *> *pasteboardItems) {
            BOOL didAcceptDrop = YES;

            NSUInteger itemNumber = 0;
            __block NSMutableString *objectInfo = [NSMutableString new];

            for (NSPasteboardItem *oneItem in pasteboardItems)
            {

                [objectInfo appendFormat:@"%@.", @(itemNumber++)];
                NSArray<NSPasteboardType> *types =  oneItem.types;

                [types enumerateObjectsUsingBlock:^(NSString *type, NSUInteger idx, BOOL *stop) {
                    [objectInfo appendFormat:@"\t%@\n", type];
                }];

                [objectInfo appendFormat:@"\n"];
            }

            NSTimeInterval delayInSeconds = .5;
            dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(delay, dispatch_get_main_queue(), ^{

                 NSAlert *alert = [[NSAlert alloc] init];
                alert.messageText = @"Dropped Objects";
                alert.informativeText = objectInfo;
                [alert runModal];
            });

            return didAcceptDrop;
        };

     }
    else
    {
        sharedItem.extendedDropHandler  = nil;

    }

}

- (IBAction)pinPopoverCheckboxAction:(NSButton *)pinPopoverCheckbox {
    CCNStatusItem *sharedItem = [CCNStatusItem sharedInstance];
    sharedItem.windowConfiguration.pinned = (pinPopoverCheckbox.state == NSOnState);
}

- (IBAction)proximityDragZoneDistanceSliderAction:(NSSlider *)proximityDragZoneDistanceSlider {
    CCNStatusItem *sharedItem = [CCNStatusItem sharedInstance];
    sharedItem.proximityDragZoneDistance = self.proximitySliderValue;
}

- (IBAction)presentationTransitionRadiosAction:(NSMatrix *)presentationTransitionRadios {
    CCNStatusItem *sharedItem = [CCNStatusItem sharedInstance];
    sharedItem.windowConfiguration.presentationTransition = (CCNPresentationTransition)presentationTransitionRadios.selectedRow;
}

@end
