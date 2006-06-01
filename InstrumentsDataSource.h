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
    @header		InstrumentsDataSource
        $Id$
*/


#import <Cocoa/Cocoa.h>

#import "AudioSystem.h"


/*!
    @class InstrumentsDataSource
        This is the NSTableView data source for the table of instruments in
        our NSDrawer.
*/
@interface InstrumentsDataSource : NSObject {
    AudioSystem* audioSystem;
}

- (id)initWithAudioSystem:(AudioSystem*)newAudioSystem;
- (void)dealloc;

- (int)numberOfRowsInTableView:(NSTableView*)tableView;
- (id)tableView:(NSTableView*)tableView objectValueForTableColumn:(NSTableColumn*)column row:(int)rowIndex;

@end
