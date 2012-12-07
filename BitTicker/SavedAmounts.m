//
//  SavedAmounts.m
//  BitTicker
//
//  Created by Tristan Hume on 2012-12-06.
//  Copyright (c) 2012 none. All rights reserved.
//

#import "SavedAmounts.h"

#define kPrefsFile @"~/Library/Preferences/BitTicker Amounts.plist"

@implementation SavedAmounts

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
  return [amounts count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
  return [currencyFormatter stringFromNumber:[amounts objectAtIndex:rowIndex]];
}

- (void)addAmount:(NSNumber *)amount {
  [amounts addObject:amount];
}

- (void)writeData {
  [amounts writeToFile:[kPrefsFile stringByExpandingTildeInPath] atomically:YES];
}

- (void)readData {
  amounts = [[NSMutableArray alloc] initWithContentsOfFile:[kPrefsFile stringByExpandingTildeInPath]];
  if (amounts == nil) {
    amounts = [[NSMutableArray alloc] initWithCapacity:4];
  }
}

-(void)didReceiveTicker:(NSNotification *)notification {
	NSAssert([NSThread currentThread] == [NSThread mainThread],@"Not running on main thread!");
	NSLog(@"Dropdown got ticker");
	NSDictionary *ticker = [[notification object] objectForKey:@"ticker"];
  
  exchangeRate = [ticker objectForKey:@"last"];
}

@end
