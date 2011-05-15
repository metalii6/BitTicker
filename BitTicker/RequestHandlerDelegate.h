//
//  RequestHandlerDelegate.h
//  Bitcoin Trader
//
//  Created by Matt Stith on 4/30/11.
//  Copyright 2011 Insomnia Addict. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RequestHandlerDelegate <NSObject>

-(void)request:(NSInteger)tag didFinishWithData:(NSData*)data;
-(void)request:(NSInteger)tag didFailWithError:(NSError*)error;
@end
