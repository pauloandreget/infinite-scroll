//
//  Connect.h
//  InfiniteScroll
//
//  Created by Paulo Rodrigues on 2/24/14.
//  Copyright (c) 2014 Riabox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Connect : NSObject <NSURLConnectionDelegate>

@property id delegate;
@property SEL successSelector;
@property SEL errorSelector;

- (id)initWithDelegate:(id)object onSuccess:(SEL)success onError:(SEL)error;
- (void)requestPage:(int)page;

@end
