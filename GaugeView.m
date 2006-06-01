/*
    This software is distributed under the terms of Pete's Public License version 1.0, a
    copy of which is included with this software in the file "License.html".  A copy can
    also be obtained from http://pete.yandell.com/software/license/ppl-1_0.html
    
    If you did not receive a copy of the license with this software, please notify the
    author by sending e-mail to pete@yandell.com
    
    The current version of this software can be found at http://pete.yandell.com/software
     
    Copyright (c) 2002-2004 Peter Yandell.  All Rights Reserved.
    
    $Id$
*/


#import "GaugeView.h"


@implementation GaugeView


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        value = 0.0;
    }
    
    return self;
}


- (void)drawRect:(NSRect)frameRect
{
    NSRect contentRect = NSInsetRect (frameRect, 3.0, 3.0);
    
    contentRect.size.width *= value;
    [[NSColor knobColor] set];
    NSRectFill (contentRect);
    
    [[NSColor controlShadowColor] set];
    NSFrameRect (frameRect);
    
}


- (void)setFloatValue:(float)newValue
{
    value = newValue;
    [self setNeedsDisplay:YES];
}


- (float)getFloatValue
{
    return value;
}


@end
