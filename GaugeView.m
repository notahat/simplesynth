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
    [[NSColor whiteColor] set];
    NSRectFill (frameRect);

    [[NSColor controlShadowColor] set];
    NSFrameRect (frameRect);
    
    NSRect contentRect = NSInsetRect (frameRect, 3.0, 3.0);    
    contentRect.size.width *= value;
    [[NSColor knobColor] set];
    NSRectFill (contentRect);
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
