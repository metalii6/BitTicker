//
//  SavedAmounts.m
//  BitTicker
//
//  Created by Tristan Hume on 2012-12-06.
//  Copyright (c) 2012 none. All rights reserved.
//

#import "SavedWallets.h"

#define kPrefsFile @"~/Library/Preferences/BitTicker Wallets.plist"

@implementation SavedWallets

- (id)initWithCurrencyFormatter:(NSNumberFormatter *)formatter
{
    self = [super init];
    if (self) {
      currencyFormatter = formatter;
      [self readData];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTicker:) name:@"MtGox-Ticker" object:nil];
    }
    return self;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  return [wallets count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)column row:(NSInteger)rowIndex {
  NSDictionary *dict = [wallets objectAtIndex:rowIndex];
  if ([column.identifier isEqualToString:@"amount"]) {
    NSNumber *amount = [dict objectForKey:@"amount"];
    return [NSString stringWithFormat:@"%.2f BTC",[amount doubleValue]];
  } else if ([column.identifier isEqualToString:@"wallet"]) {
    return [dict objectForKey:@"name"];
  } else if ([column.identifier isEqualToString:@"value"]) {
    NSNumber *amount = [dict objectForKey:@"amount"];
    double dollarValue = [amount doubleValue] * exchangeRate;
    NSNumber *valueNum = [NSNumber numberWithDouble:dollarValue];
    return [currencyFormatter stringFromNumber:valueNum];
  }
  return @"";
}

- (void)addWallet:(NSString *)wallet withAmount:(NSNumber *)amount {
  NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          wallet,@"name", amount, @"amount", nil];
  [wallets addObject:dict];
}

- (void)deleteWalletAtIndex:(NSUInteger)wallet {
  [wallets removeObjectAtIndex:wallet];
}

- (void)writeData {
  [wallets writeToFile:[kPrefsFile stringByExpandingTildeInPath] atomically:YES];
}

- (void)readData {
  wallets = [[NSMutableArray alloc] initWithContentsOfFile:[kPrefsFile stringByExpandingTildeInPath]];
  if (wallets == nil) {
    wallets = [[NSMutableArray alloc] initWithCapacity:4];
  }
}

-(void)didReceiveTicker:(NSNotification *)notification {
	NSAssert([NSThread currentThread] == [NSThread mainThread],@"Not running on main thread!");
	NSDictionary *ticker = [[notification object] objectForKey:@"ticker"];
  
  exchangeRate = [[ticker objectForKey:@"last"] doubleValue];
}

@end
