#import <AppKit/AppKit.h>


/*!
    @category	NSString(Carbon_Additions)
        Some additions to NSString class to help integrate with Carbon.
*/
@interface NSString(Carbon_Additions)

/*!
    @method 	makeFSSpec:
        Converts the path contained in the string to an old style FSSpec.
    @param		specPtr		a pointer to the FSSpec to be created
    @result 	returns true on success, false on failure
*/
- (bool)makeFSSpec:(FSSpec*)specPtr;

@end