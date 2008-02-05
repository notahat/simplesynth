#import <AppKit/AppKit.h>


/*!
    @class		GaugeView
        A simple NSView subclass that implements a horizontal bar chart style gauge.
*/
@interface GaugeView : NSView {
    float	value;
}

- (void)setFloatValue:(float)newValue;
- (float)getFloatValue;

@end
