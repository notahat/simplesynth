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
    @header		SynthController
        $Id$
*/


#import <Cocoa/Cocoa.h>

@class PYMIDIVirtualDestination;

#import "GaugeView.h"
#import "AudioSystem.h"


/*!
    @class		SynthController
        This is the main controller for the application.
*/
@interface SynthController : NSObject
{
    IBOutlet NSWindow*		mainWindow;
    IBOutlet NSPopUpButton* midiInputPopup;
    IBOutlet NSTextField*	soundSetTextField;
    IBOutlet NSTableView*	channelsTable;
    IBOutlet NSDrawer*		instrumentsDrawer;
    IBOutlet NSTableView*	instrumentsTable;
    IBOutlet NSTextField*	programNumberField;
    IBOutlet NSTextField*	bankSelectMSBField;
    IBOutlet NSTextField*	bankSelectLSBField;
    IBOutlet NSSlider*		cutoffSlider;
    IBOutlet GaugeView*		cpuLoadGuage;
    
    NSTimer*					uiUpdateTimer;

    AudioSystem*				audioSystem;
    PYMIDIVirtualDestination*	virtualDestination;
}

- (void)awakeFromNib;

- (void)updateUI:(NSTimer*)timer;

- (void)buildMIDIInputPopUp;
- (IBAction)midiInputChanged:(id)sender;
- (void)midiSetupChanged:(NSNotification*)notification;

- (IBAction)openDocument:(id)sender;
- (IBAction)restoreAppleSounds:(id)sender;
- (BOOL)application:(NSApplication*)theApplication openFile:(NSString*)filename;
- (void)displayOpenFailedAlert:(NSString*)fileName;

- (void)audioSystemInstrumentChanged:(NSNotification*)notification;
- (void)instrumentsTableSelectionChanged:(NSNotification*)notification;
- (void)updateMIDIDetails;

- (IBAction)cutoffSliderChanged:(id)sender;

- (void)updateCPULoadGuage;

- (IBAction)displayLicense:(id)sender;
- (IBAction)visitWebSite:(id)sender;
- (IBAction)sendFeedback:(id)sender;

@end
