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
    IBOutlet NSSlider*		volumeSlider;
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
- (void)channelsTableSelectionChanged:(NSNotification*)notification;
- (void)instrumentsTableSelectionChanged:(NSNotification*)notification;
- (void)updateInstrumentSelection;
- (void)updateMIDIDetails;

- (IBAction)cutoffSliderChanged:(id)sender;
- (IBAction)volumeSliderChanged:(id)sender;

- (void)updateCPULoadGuage;

- (IBAction)displayLicense:(id)sender;
- (IBAction)visitWebSite:(id)sender;
- (IBAction)sendFeedback:(id)sender;

@end
