//
//  MenuController.m
//  BitTicker
//
//  Created by steve on 6/10/11.
//  Copyright 2011 none. All rights reserved.
//

#import "MenuController.h"
#import "Ticker.h"
#import "Wallet.h"
#import "StatusItemView.h"
#import "CustomMenuView.h"
#import "SharedSettings.h"

#import "MtGoxMarketMenuView.h"

#define MENU_VIEW_HEIGHT 105
#define MENU_VIEW_WIDTH 180

@implementation MenuController

@synthesize tickerValue = _tickerValue;
@synthesize currentMenuStop = _currentMenuStop;
@synthesize viewDict = _viewDict;

- (id)init
{
    self = [super init];
    if (self) {	
		self.viewDict = [NSMutableDictionary dictionaryWithCapacity:10];
		sharedSettingManager = [SharedSettings sharedSettingManager];
		currencyFormatter = [[NSNumberFormatter alloc] init];
		currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
		currencyFormatter.currencyCode = @"USD"; // TODO: Base on market currency
		currencyFormatter.thousandSeparator = @","; // TODO: Base on local seperator for currency
		currencyFormatter.alwaysShowsDecimalSeparator = YES;
		currencyFormatter.hasThousandSeparators = YES;
		currencyFormatter.minimumFractionDigits = 4; // TODO: Configurable
		
		
		_statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
		[_statusItem retain];
    
		statusItemView = [[StatusItemView alloc] init];
		statusItemView.statusItem = _statusItem;
		[statusItemView setToolTip:NSLocalizedString(@"BitTicker", @"Status Item Tooltip")];
		
		[_statusItem setView:statusItemView];
		
		trayMenu = [[NSMenu alloc] initWithTitle:@"Ticker"];
		[statusItemView setMenu:trayMenu];
		self.currentMenuStop = 0;
    }
	
    return self;
}

-(void)createMenuForMarket:(BitcoinMarket*)market {
	NSMenuItem *menuItem  = [[NSMenuItem alloc] init];
	NSString *marketClass = NSStringFromClass([market class]);
	
	// NOTE: The next line creates an instance of a CustomMenuView 
	// subclass by looking at the name of the market passed in to 
	// this method. 
	CustomMenuView *menuView = [[NSClassFromString([NSString stringWithFormat:@"%@MenuView",marketClass]) alloc] initWithFrame:CGRectMake(0,self.currentMenuStop,MENU_VIEW_WIDTH,MENU_VIEW_HEIGHT)];
	[menuItem setView:menuView];
	[trayMenu addItem:menuItem];
	[trayMenu addItem:[NSMenuItem separatorItem]];
	[self.viewDict setObject:menuView forKey:NSStringFromClass([market class])]; 
	[menuItem release];
}

-(void)addSelectorItems {
	refreshItem = [trayMenu addItemWithTitle:@"Refresh" 
                                      action:@selector(refreshTicker:) 
                               keyEquivalent:@"r"];
	settingsItem = [trayMenu addItemWithTitle: @"Settings"  
                                    action: @selector (showSettings:)  
                             keyEquivalent: @"s"];
	mainWindowItem = [trayMenu addItemWithTitle: @"Main Window"  
                                    action: @selector (showMainWindow:)  
                             keyEquivalent: @"m"];							 
	aboutItem = [trayMenu addItemWithTitle: @"About"  
                                    action: @selector (showAbout:)  
                             keyEquivalent: @"a"];
	quitItem = [trayMenu addItemWithTitle: @"Quit"  
								   action: @selector (quitProgram:)  
							keyEquivalent: @"q"];
}

- (void)dealloc {	
	[currencyFormatter release];
	[_statusItem release];
    [statusItemView release];
    [trayMenu release];
    [super dealloc];
}

#pragma mark Bitcoin market delegate
// A request failed for some reason, for example the API being down
-(void)bitcoinMarket:(BitcoinMarket*)market requestFailedWithError:(NSError*)error {
    MSLog(@"Error: %@",error);
}

// Request wasn't formatted as expected
-(void)bitcoinMarket:(BitcoinMarket*)market didReceiveInvalidResponse:(NSData*)data {
    MSLog(@"Invalid response: %@",data);
}

-(void)bitcoinMarket:(BitcoinMarket*)market didReceiveTicker:(Ticker*)ticker {
    [statusItemView setTickerValue:ticker.last];
	self.tickerValue = ticker.last;
    MSLog(@"Got mah ticker: %@",ticker);
    
    NSNumberFormatter *volumeFormatter = [[NSNumberFormatter alloc] init];
    volumeFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    volumeFormatter.hasThousandSeparators = YES;
	CustomMenuView *view = [self.viewDict objectForKey:NSStringFromClass( [market class] ) ] ;
	
	
	[view setHigh:[currencyFormatter stringFromNumber:ticker.high]];
	[view setLow:[currencyFormatter stringFromNumber:ticker.low]];
	[view setBuy:[currencyFormatter stringFromNumber:ticker.buy]];
	[view setSell:[currencyFormatter stringFromNumber:ticker.sell]];
	[view setLast:[currencyFormatter stringFromNumber:ticker.last]];
    [view setVol:[volumeFormatter stringFromNumber:ticker.volume]];
    
    [volumeFormatter release];
}

-(void)bitcoinMarket:(BitcoinMarket*)market didReceiveRecentTradesData:(NSArray*)trades {
    
}

-(void)bitcoinMarket:(BitcoinMarket*)market didReceiveWallet:(Wallet*)wallet {
	id view = [self.viewDict objectForKey:NSStringFromClass( [market class] ) ] ;
    double btc = [wallet.btc doubleValue];
    double usd = [wallet.usd doubleValue];
	double last = [self.tickerValue doubleValue];
	
	if (last == 0) {
		//no last yet so cant multiply anyway
	}
	else {
		NSNumber *BTCxRate = [NSNumber numberWithDouble:btc*last];
		[view setBtcusd:[currencyFormatter stringFromNumber:BTCxRate]];
	
		NSNumber *walletUSD = [NSNumber numberWithDouble:[BTCxRate doubleValue] + usd];
		[view setWallet:[currencyFormatter stringFromNumber:walletUSD]];
	}
	[view setBtc:[NSString stringWithFormat:@"%f.04",[wallet.btc floatValue]]];
	[view setUsd:[currencyFormatter stringFromNumber:wallet.usd]];
}

@end
