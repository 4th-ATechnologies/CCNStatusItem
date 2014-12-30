//
//  Created by Frank Gregor on 21/12/14.
//  Copyright (c) 2014 cocoa:naut. All rights reserved.
//

/*
 The MIT License (MIT)
 Copyright © 2014 Frank Gregor, <phranck@cocoanaut.com>
 http://cocoanaut.mit-license.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the “Software”), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */


#import "CCNStatusItemWindowBackgroundView.h"

@interface CCNStatusItemWindowBackgroundView () {
    CALayer *_backgroundLayer;
}
@property (strong) CCNStatusItemWindowDesign *design;
@end

@implementation CCNStatusItemWindowBackgroundView

- (instancetype)initWithFrame:(NSRect)frameRect design:(CCNStatusItemWindowDesign *)design {
    self = [super initWithFrame:frameRect];
    if (self) {
        self.design = design;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    NSRect backgroundRect = NSMakeRect(NSMinX(self.bounds), NSMinY(self.bounds), NSWidth(self.bounds), NSHeight(self.bounds) - self.design.statusItemWindowArrowHeight);

    NSBezierPath *windowPath = [NSBezierPath bezierPath];
    NSBezierPath *arrowPath = [NSBezierPath bezierPath];
    NSBezierPath *backgroundPath = [NSBezierPath bezierPathWithRoundedRect:backgroundRect xRadius:self.design.statusItemWindowCornerRadius yRadius:self.design.statusItemWindowCornerRadius];

    [arrowPath moveToPoint: NSMakePoint(NSMaxX(backgroundRect)/2, NSMaxY(backgroundRect) + self.design.statusItemWindowArrowHeight)];
    [arrowPath lineToPoint: NSMakePoint(NSMaxX(backgroundRect)/2 + self.design.statusItemWindowArrowWidth/2, NSMaxY(backgroundRect))];
    [arrowPath lineToPoint: NSMakePoint(NSMaxX(backgroundRect)/2 - self.design.statusItemWindowArrowWidth/2, NSMaxY(backgroundRect))];
    [arrowPath closePath];

    [arrowPath setLineCapStyle: NSRoundLineCapStyle];
    [arrowPath setLineJoinStyle: NSBevelLineJoinStyle];

    [windowPath appendBezierPath:arrowPath];
    [windowPath appendBezierPath:backgroundPath];

    [self.design.statusItemWindowBackgroundColor setFill];
    [windowPath fill];
}

#pragma mark - Custom Accessors

- (void)setFrame:(NSRect)frame {
    [super setFrame:frame];
    [self setNeedsDisplay:YES];
}

@end
