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
