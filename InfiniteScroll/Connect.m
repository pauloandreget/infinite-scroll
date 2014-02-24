//
//  Connect.m
//  InfiniteScroll
//
//  Created by Paulo Rodrigues on 2/24/14.
//  Copyright (c) 2014 Riabox. All rights reserved.
//

#import "Connect.h"

@interface Connect ()
@property (nonatomic, retain) NSURLConnection *conn;
@property (nonatomic, retain) NSMutableData *dataResponse;
@property (nonatomic, retain) NSHTTPURLResponse *urlResponse;
@end

@implementation Connect

@synthesize delegate, successSelector, errorSelector;

- (id)initWithDelegate:(id)object onSuccess:(SEL)success onError:(SEL)error {
    self = [super init];
    if (self) {
        [self setDelegate:object];
        [self setSuccessSelector:success];
        [self setErrorSelector:error];
    }
    
    return self;
}

- (void)requestPage:(int)page {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.theverge.com/apple/archives/%d", page]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    self.conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (self.conn) {
        self.dataResponse = [NSMutableData data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (delegate && errorSelector) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [delegate performSelector:errorSelector withObject:[error description]];
        #pragma clang diagnostic pop
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    [self setUrlResponse:httpResponse];
    
    [self.dataResponse setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.dataResponse appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if ([self.urlResponse statusCode] == 200) {
        NSLog(@"%@", [self.urlResponse.URL absoluteString]);
        
        NSString *result = [[NSString alloc] initWithBytes:[self.dataResponse bytes] length:[self.dataResponse length] encoding:NSUTF8StringEncoding];
        
        if (delegate && errorSelector) {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [delegate performSelector:successSelector withObject:result];
            #pragma clang diagnostic pop
        }
    } else {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [delegate performSelector:errorSelector withObject:@"Erro na requisição"];
        #pragma clang diagnostic pop
    }
}

@end
