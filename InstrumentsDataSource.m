#import "InstrumentsDataSource.h"


@implementation InstrumentsDataSource


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
    return [audioSystem instrumentCount];
}


- (id)tableView:(NSTableView*)tableView objectValueForTableColumn:(NSTableColumn*)column row:(int)rowIndex
{
    MusicDeviceInstrumentID instrumentID = [audioSystem instrumentIDAtIndex:rowIndex];
    NSString* text = @"";
    
    if ([[column identifier] isEqualToString:@"name"]) {
        text = [audioSystem nameOfInstrument:instrumentID];
    }
    
    return text;
}


@end
