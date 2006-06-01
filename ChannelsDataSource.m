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


#import "ChannelsDataSource.h"


@implementation ChannelsDataSource


- (id)initWithAudioSystem:(AudioSystem*)newAudioSystem
{
    [newAudioSystem retain];
    
    audioSystem = newAudioSystem;
    
    return self;
}


- (void)dealloc
{
    [audioSystem release];
    [super dealloc];
}


- (int)numberOfRowsInTableView:(NSTableView*)tableView
{
    return 16;
}


- (id)tableView:(NSTableView*)tableView objectValueForTableColumn:(NSTableColumn*)column row:(int)rowIndex
{
    if ([[column identifier] isEqualToString:@"channel"]) {
        return [NSString stringWithFormat:@"%d", rowIndex+1];
    }
    else {
        return [audioSystem nameOfInstrument:[audioSystem currentInstrumentOnChannel:rowIndex]];
    }
}


@end
