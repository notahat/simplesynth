/*
    This software is distributed under the terms of Pete's Public License version 1.0, a
    copy of which is included with this software in the file "License.html".  A copy can
    also be obtained from http://pete.yandell.com/software/license/ppl-1_0.html
    
    If you did not receive a copy of the license with this software, please notify the
    author by sending e-mail to pete@yandell.com
    
    The current version of this software can be found at http://pete.yandell.com/software
     
    Copyright (c) 2002-2004 Peter Yandell.  All Rights Reserved.
*/


/*!
    @header		NSStringFSSpec
        $Id$
*/


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