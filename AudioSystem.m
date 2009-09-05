#import "AudioSystem.h"
#import "NSStringFSSpec.h"


@implementation AudioSystem


- (id)init
{
    [self setUpAudio];
    [self setUpMIDI];
    
    return self;
}


- (void)setUpAudio;
{
    ComponentDescription	description;
    AudioUnit				synthUnit;
    UInt32					usesReverb;
    int						i;
    
    // Create the graph
    NewAUGraph (&graph);
    
    // Open the DLS Synth
    description.componentType           = kAudioUnitType_MusicDevice;
    description.componentSubType        = kAudioUnitSubType_DLSSynth;
    description.componentManufacturer   = kAudioUnitManufacturer_Apple;
    description.componentFlags			= 0;
    description.componentFlagsMask		= 0;
    AUGraphNewNode (graph, &description, 0, NULL, &synthNode);
    
    for (i = 0; i < 16; i++) channelInstrument[i] = 0;

    // Open the filter
    description.componentType           = kAudioUnitType_Effect;
    description.componentSubType        = kAudioUnitSubType_LowPassFilter;
    description.componentManufacturer   = kAudioUnitManufacturer_Apple;
    description.componentFlags			= 0;
    description.componentFlagsMask		= 0;
    AUGraphNewNode (graph, &description, 0, NULL, &filterNode);

    // Open the output device
    description.componentType           = kAudioUnitType_Output;
    description.componentSubType        = kAudioUnitSubType_DefaultOutput;
    description.componentManufacturer   = kAudioUnitManufacturer_Apple;
    description.componentFlags			= 0;
    description.componentFlagsMask		= 0;
    AUGraphNewNode (graph, &description, 0, NULL, &outputNode);

    // Connect the devices up
    AUGraphConnectNodeInput (graph, synthNode, 1, filterNode, 0);
    AUGraphConnectNodeInput (graph, filterNode, 0, outputNode, 0);
    AUGraphUpdate (graph, NULL);
    
    // Open and initialize the audio units
    AUGraphOpen (graph);
    AUGraphInitialize (graph);

    // Turn off the reverb on the synth
    AUGraphGetNodeInfo (graph, synthNode, NULL, NULL, NULL, &synthUnit);
    usesReverb = 0;
    AudioUnitSetProperty (
        synthUnit,
        kMusicDeviceProperty_UsesInternalReverb, kAudioUnitScope_Global,
        0,
        &usesReverb, sizeof (usesReverb)
    );

    // Start playing
   AUGraphStart (graph);
}


// This takes the file and attempts to load it into the synth unit
- (BOOL)openFile:(NSString*)filename
{
    FSSpec		fsSpec;
    AudioUnit	synthUnit;
    OSStatus	error;
    int			i;
    
    if (![filename makeFSSpec:&fsSpec]) return NO;

	AUGraphStop(graph);
	
    AUGraphGetNodeInfo (graph, synthNode, NULL, NULL, NULL, &synthUnit);
    error = AudioUnitSetProperty (
        synthUnit,
        kMusicDeviceProperty_SoundBankFSSpec, kAudioUnitScope_Global,
        0,
        &fsSpec, sizeof (fsSpec)
    );
	
	AUGraphStart(graph);
	
    if (error) return NO;

    for (i = 0; i < 16; i++) channelInstrument[i] = 0;
    
    return YES;
}


// This restores the built-in Apple sounds. The only way to do this is to
// remove the synth node and make a new one.
- (void)restoreAppleSounds
{
    ComponentDescription	description;
    AudioUnit				synthUnit;
    UInt32					usesReverb;
    int						i;

    AUGraphStop(graph);
    AUGraphRemoveNode(graph, synthNode);

    // Open the DLS Synth
    description.componentType			= kAudioUnitComponentType;
    description.componentSubType		= kAudioUnitSubType_MusicDevice;
    description.componentManufacturer	= kAudioUnitID_DLSSynth;
    description.componentFlags			= 0;
    description.componentFlagsMask		= 0;
    AUGraphNewNode (graph, &description, 0, NULL, &synthNode);
    
    for (i = 0; i < 16; i++) channelInstrument[i] = 0;

    // Connect the devices up
    AUGraphConnectNodeInput (graph, synthNode, 1, filterNode, 0);
    AUGraphConnectNodeInput (graph, filterNode, 0, outputNode, 0);
    AUGraphUpdate (graph, NULL);

    // Turn off the reverb on the synth
    AUGraphGetNodeInfo (graph, synthNode, NULL, NULL, NULL, &synthUnit);
    usesReverb = 0;
    AudioUnitSetProperty (
        synthUnit,
        kMusicDeviceProperty_UsesInternalReverb, kAudioUnitScope_Global,
        0,
        &usesReverb, sizeof (usesReverb)
    );

    AUGraphStart(graph);
}


- (UInt32)instrumentCount
{
    OSErr		result;
    AudioUnit		synthUnit;
    UInt32		count;
    UInt32		size = sizeof (count);

    result = AUGraphGetNodeInfo (graph, synthNode, NULL, NULL, NULL, &synthUnit);
    
    result = AudioUnitGetProperty (
        synthUnit, kMusicDeviceProperty_InstrumentCount,
        kAudioUnitScope_Global, 0,
        (void*)&count, &size
    );
    
    if (result == noErr)
        return count;
    else
        return 0;
}


- (MusicDeviceInstrumentID)instrumentIDAtIndex:(UInt32)index
{
    OSErr 						result;
    AudioUnit					synthUnit;
    MusicDeviceInstrumentID 	instrumentID;
    UInt32						size = sizeof (instrumentID);

    result = AUGraphGetNodeInfo (graph, synthNode, NULL, NULL, NULL, &synthUnit);
    
    result = AudioUnitGetProperty (
        synthUnit, kMusicDeviceProperty_InstrumentNumber,
        kAudioUnitScope_Global, index, &instrumentID, &size
    );
    
    if (result == noErr)
        return instrumentID;
    else
        return 0;
}


- (NSString*)nameOfInstrument:(MusicDeviceInstrumentID)instrumentID
{
    OSErr				result;
    AudioUnit			synthUnit;
    char				name[256];
    UInt32				size = sizeof (name);
   
    AUGraphGetNodeInfo (graph, synthNode, NULL, NULL, NULL, &synthUnit);

    result = AudioUnitGetProperty (
        synthUnit, kMusicDeviceProperty_InstrumentName,
        kAudioUnitScope_Global, instrumentID, &name, &size
    );

    if (result == noErr)
        return [NSString stringWithCString:name];
    else
        return @"";
}


+ (MIDIInstrument)instrumentIDToInstrument:(MusicDeviceInstrumentID)instrumentID
{
    MIDIInstrument instrument;
    
    instrument.bankSelectMSB = (instrumentID >> 16) & 0x7F;
    instrument.bankSelectLSB = (instrumentID >> 8)  & 0x7F;
    instrument.programChange = instrumentID         & 0x7F;
    
    return instrument;
}


+ (MusicDeviceInstrumentID)instrumentToInstrumentID:(MIDIInstrument)instrument
{
    MusicDeviceInstrumentID instrumentID;
    
    instrumentID =
        (instrument.bankSelectMSB << 16) |
        (instrument.bankSelectLSB << 8)  |
        instrument.programChange;
        
    return instrumentID;
}


- (MusicDeviceInstrumentID)currentInstrumentOnChannel:(int)channel
{
    return channelInstrument[channel];
}


- (void)setInstrument:(MusicDeviceInstrumentID)instrumentID forChannel:(int)channel
{
    AudioUnit		synthUnit;
    MIDIInstrument	instrument;
    
    AUGraphGetNodeInfo (graph, synthNode, NULL, NULL, NULL, &synthUnit);
    
    instrument = [AudioSystem instrumentIDToInstrument:instrumentID];
    MusicDeviceMIDIEvent (synthUnit, 0xB0 | channel, 0x00, instrument.bankSelectMSB, 0);
    MusicDeviceMIDIEvent (synthUnit, 0xB0 | channel, 0x20, instrument.bankSelectLSB, 0);
    MusicDeviceMIDIEvent (synthUnit, 0xC0 | channel, instrument.programChange, 0, 0);
        
    channelInstrument[channel] = instrumentID;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"instrumentChanged" object:self];
}


- (float)getFilterCutoffMin
{
    AudioUnit						filterUnit;
    struct AudioUnitParameterInfo	info;
    UInt32							size = sizeof (info);
    
    AUGraphGetNodeInfo (graph, filterNode, NULL, NULL, NULL, &filterUnit);
    
    AudioUnitGetProperty (
        filterUnit, kAudioUnitProperty_ParameterInfo,
        kAudioUnitScope_Global, 0, (void*)&info, &size
    );
    
    return info.minValue;
}

- (float)getFilterCutoffMax
{
    AudioUnit						filterUnit;
    struct AudioUnitParameterInfo	info;
    UInt32							size = sizeof (info);
   
    AUGraphGetNodeInfo (graph, filterNode, NULL, NULL, NULL, &filterUnit);
    
    AudioUnitGetProperty (
        filterUnit, kAudioUnitProperty_ParameterInfo,
        kAudioUnitScope_Global, 0, (void*)&info, &size
    );
    
    return info.maxValue;
}

- (float)getFilterCutoff
{
    AudioUnit filterUnit;
    float value;

    AUGraphGetNodeInfo (graph, filterNode, NULL, NULL, NULL, &filterUnit);

    AudioUnitGetParameter (filterUnit, 0, kAudioUnitScope_Global, 0, &value);
    
    return value;
}

- (void)setFilterCutoff:(float)value
{
    AudioUnit filterUnit;

    AUGraphGetNodeInfo (graph, filterNode, NULL, NULL, NULL, &filterUnit);

    AudioUnitSetParameter (filterUnit, 0, kAudioUnitScope_Global, 0, value, 0);
}


- (float)getCPULoad
{
    float load;
    AUGraphGetCPULoad (graph, &load);
    return load;
}


- (void)setUpMIDI
{
    currentMIDIEndpoint = nil;
}


- (PYMIDIEndpoint*)midiInput
{
    return currentMIDIEndpoint;
}


- (void)setMIDIInput:(PYMIDIEndpoint*)endpoint
{
    [currentMIDIEndpoint removeReceiver:self];
    [currentMIDIEndpoint autorelease];
    currentMIDIEndpoint = [endpoint retain];
    [currentMIDIEndpoint addReceiver:self];
}


// Called whenever MIDI data arrives
- (void)processMIDIPacketList:(const MIDIPacketList*)packets sender:(id)sender
{
    int						i, j;
    const MIDIPacket*		packet;
    Byte					message[256];
    int						messageSize = 0;
    
    
    // Step through each packet
    packet = packets->packet;
    for (i = 0; i < packets->numPackets; i++) {
        for (j = 0; j < packet->length; j++) {
            if (packet->data[j] >= 0xF8) continue;				// skip over real-time data
            
            // Hand off the packet for processing when the next one starts
            if ((packet->data[j] & 0x80) != 0 && messageSize > 0) {
                [self handleMIDIMessage:message ofSize:messageSize];
                messageSize = 0;
            }
            
            message[messageSize++] = packet->data[j];			// push the data into the message
        }
        
        packet = MIDIPacketNext (packet);
    }
    
    if (messageSize > 0)
        [self handleMIDIMessage:message ofSize:messageSize];
}


- (void)handleMIDIMessage:(Byte*)message ofSize:(int)size
{
    AudioUnit		synthUnit;
    BOOL			instrumentChanged = NO;
    // int				i;
    // NSMutableString* text;
    
    AUGraphGetNodeInfo (graph, synthNode, NULL, NULL, NULL, &synthUnit);
    
    // Pass the packet to the DLSSynth device
    MusicDeviceMIDIEvent (synthUnit, message[0], message[1], message[2], 0);
         
    // Intercept and handle MIDI program change events
    if ((message[0] & 0xF0) == 0xC0) {
        int channel = message[0] & 0x0F;
        MIDIInstrument instrument = [AudioSystem instrumentIDToInstrument:channelInstrument[channel]];
        instrument.programChange = message[1];
        channelInstrument[channel] = [AudioSystem instrumentToInstrumentID:instrument];
        
        instrumentChanged = YES;
    }
        
    // Intercept and handle MIDI bank select events
    else if ((message[0] & 0xF0) == 0xB0) {
        int channel = message[0] & 0x0F;
        
        if (message[1] == 0x00) {
            MIDIInstrument instrument = [AudioSystem instrumentIDToInstrument:channelInstrument[channel]];
            instrument.bankSelectMSB = message[2];
            channelInstrument[channel] = [AudioSystem instrumentToInstrumentID:instrument];

            instrumentChanged = YES;
        }
        else if (message[1] == 0x20) {
            MIDIInstrument instrument = [AudioSystem instrumentIDToInstrument:channelInstrument[channel]];
            instrument.bankSelectLSB = message[2];
            channelInstrument[channel] = [AudioSystem instrumentToInstrumentID:instrument];

            instrumentChanged = YES;
        }
    }
        
    if (instrumentChanged)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"instrumentChanged" object:self];
        
    // This is a bit of code that will dump out raw MIDI data as it comes in.
    // I've left it here inside the comment as a debugging aid.
    /*
    text = [[NSMutableString alloc] init];
    for (i = 0; i < size; i++) {
        [text appendFormat:@"%02x ", (int)message[0]];
    }
    CFShow (text);
    [text release];
    */
}


@end