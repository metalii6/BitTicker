/*
 BitTicker is Copyright 2012 Stephen Oliver
 http://github.com/infincia
 
*/

#import <Foundation/Foundation.h>

#import "SavedWallets.h"


@class StatusItemView;

@interface Dropdown : NSObject {
	NSMenu *trayMenu;
	
	NSMutableDictionary *_viewDict;
	StatusItemView *statusItemView;
	NSStatusItem *_statusItem;
	
	NSNumberFormatter *currencyFormatter;
	NSNumberFormatter *volumeFormatter;
	
	NSNumber *_tickerValue;
	
  SavedWallets *saved;
}
- (IBAction)addSavedAmount:(id)sender;
- (IBAction)deleteSavedAmount:(id)sender;

@property (copy) NSNumber *tickerValue;

@property (strong) NSString *high;
@property (strong) NSString *low;
@property (strong) NSString *vol;
@property (strong) NSString *buy;
@property (strong) NSString *sell;
@property (strong) NSString *last;

@property (strong) IBOutlet NSView *dropdownView;
@property (weak) IBOutlet NSTableView *savedTable;
@property (weak) IBOutlet NSTextField *addSavedField;
@property (weak) IBOutlet NSTextField *addWalletField;

@end
