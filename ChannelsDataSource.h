#import <Cocoa/Cocoa.h>
#import "AudioSystem.h"


/*!
    @class		ChannelsDataSource
        This is the NSTableView data source for the table of MIDI channels
        and their current instruments.
*/
@interface ChannelsDataSource : NSObject {
    AudioSystem* audioSystem;
}

- (id)initWithAudioSystem:(AudioSystem*)newAudioSystem;
- (void)dealloc;

- (int)numberOfRowsInTableView:(NSTableView*)tableView;
- (id)tableView:(NSTableView*)tableView objectValueForTableColumn:(NSTableColumn*)column row:(int)rowIndex;

@end
