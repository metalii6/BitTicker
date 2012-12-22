/*
 BitTicker is Copyright 2012 Stephen Oliver
 http://github.com/infincia
 
*/

#import "Dropdown.h"
#import "StatusItemView.h"

@implementation Dropdown

@synthesize tickerValue = _tickerValue;



@synthesize high;
@synthesize low;
@synthesize vol;
@synthesize buy;
@synthesize sell;
@synthesize last;
@synthesize dropdownView;



- (id)init
{
    self = [super init];

    volumeFormatter = [[NSNumberFormatter alloc] init];
    volumeFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    volumeFormatter.hasThousandSeparators = YES;

    currencyFormatter = [[NSNumberFormatter alloc] init];
    currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    currencyFormatter.currencyCode = @""; // TODO: Base on market currency
    currencyFormatter.localizesFormat = NO;
    currencyFormatter.currencySymbol = @"$";
    currencyFormatter.thousandSeparator = @","; // TODO: Base on local seperator for currency
    currencyFormatter.alwaysShowsDecimalSeparator = YES;
    currencyFormatter.hasThousandSeparators = YES;
    currencyFormatter.minimumFractionDigits = 2; // TODO: Configurable
  
    saved = [[SavedWallets alloc] initWithCurrencyFormatter:currencyFormatter];
    return self;
}

-(void)awakeFromNib {
	NSLog(@"Awake from nib in dropdown");
	_statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
	statusItemView = [[StatusItemView alloc] init];
	statusItemView.statusItem = _statusItem;
  statusItemView.dropdown = self;
	[statusItemView setToolTip:@"BitTicker"];
		
	[_statusItem setView:statusItemView];
		
	trayMenu = [[NSMenu alloc] initWithTitle:@"Ticker"];
	[statusItemView setMenu:trayMenu];
  	NSMenuItem *menuItem  = [[NSMenuItem alloc] init];
	[menuItem setView:self.dropdownView];
	[trayMenu addItem:menuItem];

  [self.savedTable setDataSource:saved];
  [self.savedTable setDelegate:saved];
  [self.addWalletField becomeFirstResponder];
	    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTicker:) name:@"MtGox-Ticker" object:nil];

}

-(void)didReceiveTicker:(NSNotification *)notification {
	NSAssert([NSThread currentThread] == [NSThread mainThread],@"Not running on main thread!");
	NSLog(@"Dropdown got ticker");
	NSDictionary *ticker = [[notification object] objectForKey:@"ticker"];
		
	self.high = [currencyFormatter stringFromNumber:[ticker objectForKey:@"high"]];
	self.low = [currencyFormatter stringFromNumber:[ticker objectForKey:@"low"]];
	self.buy = [currencyFormatter stringFromNumber:[ticker objectForKey:@"buy"]];
	self.sell = [currencyFormatter stringFromNumber:[ticker objectForKey:@"sell"]];
	self.last = [currencyFormatter stringFromNumber:[ticker objectForKey:@"last"]];
	self.vol = [volumeFormatter stringFromNumber:[ticker objectForKey:@"vol"]];    

}

- (IBAction)addSavedAmount:(id)sender {
  NSLog(@"Adding Saved Amount");
  [self.dropdownView becomeFirstResponder];
  NSString *amountValue = [self.addSavedField stringValue];
  NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
  [f setNumberStyle:NSNumberFormatterDecimalStyle];
  NSNumber *amountNum = [f numberFromString:amountValue];
  if (amountNum == nil) {
    NSLog(@"%@ is not a valid number.",amountValue);
    return; // text was not number
  }
  
  [saved addWallet:[self.addWalletField stringValue] withAmount:amountNum];
  [saved writeData];
  [self.addWalletField setStringValue:@""];
  [self.addSavedField setStringValue:@""];
  [self.addWalletField becomeFirstResponder];
  [self.savedTable reloadData];
  NSLog(@"Added Saved Amount %@",amountNum);
}

- (IBAction)deleteSavedAmount:(id)sender {
  NSInteger selected = [self.savedTable selectedRow];
  if (selected < 0) {
    return;
  }
  [saved deleteWalletAtIndex:(NSUInteger)selected];
  [self.savedTable reloadData];
  [saved writeData];
}
@end
