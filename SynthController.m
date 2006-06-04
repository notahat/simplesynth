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


#import "SynthController.h"

#import <PYMIDI/PYMIDI.h>

#import "InstrumentsDataSource.h"
#import "ChannelsDataSource.h"


@implementation SynthController


- (void)awakeFromNib
{
    ChannelsDataSource* channelsDataSource;
    InstrumentsDataSource* instrumentsDataSource;
    NSPoint origin;
    
    audioSystem = [[AudioSystem alloc] init];
    
    virtualDestination = [[PYMIDIVirtualDestination alloc] initWithName:@"SimpleSynth virtual input"];
    
    [self buildMIDIInputPopUp];
    [[NSNotificationCenter defaultCenter]
        addObserver:self selector:@selector(midiSetupChanged:)
        name:@"PYMIDISetupChanged" object:nil
    ];

    // This alloc/init pair is split over 2 lines to stop silly compiler warnings.
    channelsDataSource = [ChannelsDataSource alloc];
    channelsDataSource = [channelsDataSource initWithAudioSystem:audioSystem];
    [channelsTable setDataSource:channelsDataSource];
    [[NSNotificationCenter defaultCenter]
        addObserver:self selector:@selector(audioSystemInstrumentChanged:)
        name:@"instrumentChanged" object:audioSystem
    ];
        
    // The following hardcoded values should really be dynamically pulled from the
    // AudioSystem, but the values you get when doing that make the slider very
    // lop-sided.  I'd also have to set the slider labels dynamically.
    [cutoffSlider setMinValue:10.0];
    [cutoffSlider setMaxValue:12000.0];
    [audioSystem setFilterCutoff:12000.0];
    [cutoffSlider setFloatValue:[audioSystem getFilterCutoff]];
    
    instrumentsDataSource = [[InstrumentsDataSource alloc] initWithAudioSystem:audioSystem];
    [instrumentsTable setDataSource:instrumentsDataSource];
    [[NSNotificationCenter defaultCenter]
        addObserver:self selector:@selector(instrumentsTableSelectionChanged:)
        name:@"NSTableViewSelectionDidChangeNotification" object:instrumentsTable
    ];
    [self updateMIDIDetails];
    // We must delay opening the drawer until the window is visible
    [instrumentsDrawer performSelector:@selector(open) withObject:nil afterDelay:0];
   
    if (![mainWindow setFrameUsingName:@"MainWindowFrame"]) {
        // Center our window, taking the width of the drawer into account.
        [mainWindow center];
        origin = [mainWindow frame].origin;
        origin = NSMakePoint (origin.x - [instrumentsDrawer contentSize].width/2.0, origin.y);
        [mainWindow setFrameOrigin:origin];
    }
    [mainWindow setFrameAutosaveName:@"MainWindowFrame"];

    uiUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateUI:) userInfo:nil repeats:YES];
    [uiUpdateTimer retain];
}


- (void)updateUI:(NSTimer*)timer
{
    [self updateCPULoadGuage];
}


- (void)buildMIDIInputPopUp
{
    PYMIDIManager*	manager = [PYMIDIManager sharedInstance];
    NSArray*		sources;
    NSEnumerator*	enumerator;
    PYMIDIEndpoint*	input;

    [midiInputPopup removeAllItems];
    
    sources = [manager realSources];
    enumerator = [sources objectEnumerator];
    while (input = [enumerator nextObject]) {
        [midiInputPopup addItemWithTitle:[input displayName]];
        [[midiInputPopup lastItem] setRepresentedObject:input];
    }
    
    if ([sources count] > 0) {
        [[midiInputPopup menu] addItem:[NSMenuItem separatorItem]];
    }
    
    [midiInputPopup addItemWithTitle:[virtualDestination name]];
    [[midiInputPopup lastItem] setRepresentedObject:virtualDestination];
    
    if ([audioSystem midiInput] == nil) {
        if ([sources count] > 0)
            [audioSystem setMIDIInput:[sources objectAtIndex:0]];
        else
            [audioSystem setMIDIInput:virtualDestination];
    }
    
    [midiInputPopup selectItemAtIndex:[midiInputPopup indexOfItemWithRepresentedObject:[audioSystem midiInput]]];
}



// This is called when the user selects a new MIDI input from the popup
- (IBAction)midiInputChanged:(id)sender
{
    [audioSystem setMIDIInput:[[midiInputPopup selectedItem] representedObject]];
}


- (void)midiSetupChanged:(NSNotification*)notification
{
    [self buildMIDIInputPopUp];
}


// This is called when the user pressed the "Open..." button or chooses "Open..." from
// the file menu.
// I couldn't make NSApplication do this for me, so this displays an OpenPanel and calls
// application:opeFile: for any files chosen.
- (IBAction)openDocument:(id)sender
{
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    NSMutableArray* fileTypes;
    NSArray* fileNames;
    int i;
    
    // Note that there should be some way to get these from the Info.plist
    fileTypes = [NSMutableArray arrayWithCapacity:4];
    [fileTypes addObject:@"sf2"];
    [fileTypes addObject:@"SF2"];
    [fileTypes addObject:@"dls"];
    [fileTypes addObject:@"DLS"];
    
    [openPanel runModalForTypes:fileTypes];
    
    fileNames = [openPanel filenames];
    for (i = 0; i < [fileNames count]; i++) {
        [self application:[NSApplication sharedApplication] openFile:[fileNames objectAtIndex:i]];
    }
}


- (IBAction)restoreAppleSounds:(id)sender
{
    [audioSystem restoreAppleSounds];
    [soundSetTextField setStringValue:@"Apple DLS Sound Set"];
    [channelsTable reloadData];
    [instrumentsTable reloadData];
    [self updateMIDIDetails];
}


// This is called to open a particular file, either by the openDocument method
// or by NSApplication when files are dragged-and-dropped on the app.
- (BOOL)application:(NSApplication*)theApplication openFile:(NSString*)filename
{
    if ([audioSystem openFile:filename]) {
        // Display the filename in our window
        [soundSetTextField setStringValue:[filename lastPathComponent]];
        [channelsTable reloadData];
        [instrumentsTable reloadData];
        [self updateMIDIDetails];

        // Add the file to the recent documents menu
        [[NSDocumentController sharedDocumentController]
            noteNewRecentDocumentURL:[NSURL fileURLWithPath:filename]
        ];
        
        return YES;
    }
    else {
        [self displayOpenFailedAlert:filename];
        
        return NO;
	}
}


- (void)displayOpenFailedAlert:(NSString*)fileName
{
    NSRunAlertPanel (
        [NSString
            stringWithFormat:NSLocalizedString (@"The file \"%@\" could not be opened.", @""),
                                [fileName lastPathComponent]
        ],
        NSLocalizedString (@"The file is in a format that SimpleSynth does not understand.", @""),
        NSLocalizedString (@"OK", @""), nil, nil
    );
}


- (void)audioSystemInstrumentChanged:(NSNotification*)notification
{
    [channelsTable reloadData];
}


- (void)instrumentsTableSelectionChanged:(NSNotification*)notification
{
    int channel = [channelsTable selectedRow];
    int instrumentIndex = [instrumentsTable selectedRow];
    MusicDeviceInstrumentID instrumentID = [audioSystem instrumentIDAtIndex:instrumentIndex];
    
    [self updateMIDIDetails];
    
    [audioSystem setInstrument:instrumentID forChannel:channel];
}


- (void)updateMIDIDetails
{
    int instrumentIndex = [instrumentsTable selectedRow];
    MusicDeviceInstrumentID instrumentID = [audioSystem instrumentIDAtIndex:instrumentIndex];
    MIDIInstrument instrument = [AudioSystem instrumentIDToInstrument:instrumentID];
    
    [programNumberField setIntValue:instrument.programChange + 1];
    [bankSelectMSBField setIntValue:instrument.bankSelectMSB];
    [bankSelectLSBField setIntValue:instrument.bankSelectLSB];
}


// This is called when the user moves the filter cutoff slider
- (IBAction)cutoffSliderChanged:(id)sender
{
    [audioSystem setFilterCutoff:[cutoffSlider floatValue]];
}


- (void)updateCPULoadGuage
{
    float load = [audioSystem getCPULoad];
    
    [cpuLoadGuage setFloatValue:load];
}


- (IBAction)displayLicense:(id)sender
{
    [[NSWorkspace sharedWorkspace]
        openFile:[[NSBundle mainBundle] pathForResource:@"License" ofType:@"html"]
    ];
}


- (IBAction)visitWebSite:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://notahat.com/simplesynth/"]];
}


- (IBAction)sendFeedback:(id)sender
{
    NSString* name = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    name = [[name componentsSeparatedByString:@" "] componentsJoinedByString:@"%20"];

    NSString* version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	version = [[version componentsSeparatedByString:@" "] componentsJoinedByString:@"%20"];
   
    [[NSWorkspace sharedWorkspace] openURL:[NSURL
        URLWithString:[NSString
            stringWithFormat:@"mailto:help@notahat.com?subject=%@%%20%@", name, version
        ]
    ]];
}


@end