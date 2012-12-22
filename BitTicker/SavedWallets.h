//
//  SavedAmounts.h
//  BitTicker
//
//  Created by Tristan Hume on 2012-12-06.
//  Copyright (c) 2012 none. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SavedWallets : NSObject <NSTableViewDataSource,NSTableViewDelegate> {
  NSMutableArray *wallets;
  double exchangeRate;
  NSNumberFormatter *currencyFormatter;
}

- (id)initWithCurrencyFormatter:(NSNumberFormatter *)formatter;
- (void)addWallet:(NSString *)wallet withAmount:(NSNumber *)amount;
- (void)deleteWalletAtIndex:(NSUInteger)wallet;
- (void)writeData;
- (void)readData;
@end
