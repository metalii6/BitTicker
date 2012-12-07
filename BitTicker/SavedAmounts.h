//
//  SavedAmounts.h
//  BitTicker
//
//  Created by Tristan Hume on 2012-12-06.
//  Copyright (c) 2012 none. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SavedAmounts : NSObject <NSTableViewDataSource> {
  NSMutableArray *amounts;
  NSNumber *exchangeRate;
  NSNumberFormatter *currencyFormatter;
}

- (id)initWithCurrencyFormatter:(NSNumberFormatter *)formatter;
- (void)addAmount: (NSNumber *)amount;
- (void)writeData;
- (void)readData;
@end
