#import "NSStringFSSpec.h"


@implementation NSString(Carbon_Additions)

- (bool)makeFSSpec:(FSSpec*)specPtr
{
	OSStatus	status;
	FSRef		fsref;
    
    status = FSPathMakeRef ((const UInt8*)[self fileSystemRepresentation], &fsref, NULL);
    if (status != noErr) return false;
    
    status = FSGetCatalogInfo (&fsref, kFSCatInfoNone, NULL, NULL, specPtr, NULL);
	if (status != noErr) return false;
    
 	return true;
 }

@end

