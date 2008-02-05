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
