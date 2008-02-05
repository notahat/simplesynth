#import <Foundation/Foundation.h>

#include <CoreServices/CoreServices.h>
#include <CoreAudio/CoreAudio.h>
#include <AudioUnit/AudioUnit.h>
#include <AudioToolbox/AUGraph.h>
#include <CoreMIDI/MIDIServices.h>

#import <PYMIDI/PYMIDI.h>


typedef struct {
    unsigned char bankSelectMSB;
    unsigned char bankSelectLSB;
    unsigned char programChange;
} MIDIInstrument;


/*!
    @class		AudioSystem
        This class handles all the hard work of controlling the audio
        and MIDI components of the system.
*/
@interface AudioSystem : NSObject {
    // Audio related
    AUGraph graph;
    AUNode synthNode;
    AUNode filterNode;
    AUNode outputNode;
    MusicDeviceInstrumentID channelInstrument[16];
    
    // MIDI related
    PYMIDIEndpoint*	currentMIDIEndpoint;
}

- (id)init;

// Audio related
- (void)setUpAudio;
- (BOOL)openFile:(NSString*)filename;
- (void)restoreAppleSounds;

- (UInt32)instrumentCount;
- (MusicDeviceInstrumentID)instrumentIDAtIndex:(UInt32)index;
- (NSString*)nameOfInstrument:(MusicDeviceInstrumentID)instrumentID;
+ (MIDIInstrument)instrumentIDToInstrument:(MusicDeviceInstrumentID)instrumentID;
+ (MusicDeviceInstrumentID)instrumentToInstrumentID:(MIDIInstrument)instrument;
- (MusicDeviceInstrumentID)currentInstrumentOnChannel:(int)channel;
- (void)setInstrument:(MusicDeviceInstrumentID)instrumentID forChannel:(int)channel;

- (float)getFilterCutoffMin;
- (float)getFilterCutoffMax;
- (float)getFilterCutoff;
- (void)setFilterCutoff:(float)value;
- (float)getCPULoad;

// MIDI related
- (void)setUpMIDI;
- (PYMIDIEndpoint*)midiInput;
- (void)setMIDIInput:(PYMIDIEndpoint*)endpoint;
- (void)processMIDIPacketList:(const MIDIPacketList*)packets sender:(id)sender;
- (void)handleMIDIMessage:(Byte*)message ofSize:(int)size;

@end
