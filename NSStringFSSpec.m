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

