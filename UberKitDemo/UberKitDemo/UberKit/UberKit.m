//
//  UberKit.m
//  UberKit
//
// Created by Sachin Kesiraju on 8/20/14.
// Copyright (c) 2014 Sachin Kesiraju
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "UberKit.h"

static const NSString *baseURL = @"https://api.uber.com";
static const NSString *serverToken = @"ADD_YOUR_SERVER_TOKEN"; //Add your server token

@interface UberKit (Private)

- (void) performNetworkOperationWithURL: (NSString *) url
                         success:(void (^)(NSDictionary *results))success
                         failure:(void (^)(NSError *error, NSHTTPURLResponse *response))failure;
@end

@implementation UberKit

#pragma mark - Product Types 

- (void) getProductsForLocationWithLatitude:(float)latitude longitude:(float)longitude success:(SuccessHandler)success failure:(FailureHandler)failure
{
    // GET/v1/products
    
    NSString *url = [NSString stringWithFormat:@"%@/v1/products?server_token=%@&latitude=%f&longitude=%f", baseURL, serverToken, latitude, longitude];
    [self performNetworkOperationWithURL:url success:^(NSDictionary *results)
     {
         NSArray *products = [results objectForKey:@"products"];
         NSMutableArray *availableProducts = [[NSMutableArray alloc] init];
         for(int i=0; i<products.count; i++)
         {
             UberProduct *product = [[UberProduct alloc] initWithDictionary:[products objectAtIndex:i]];
             NSLog(@"Product %@", product);
             [availableProducts addObject:product];
         }
         success(availableProducts);
     }
     failure:^(NSError *error, NSHTTPURLResponse *response)
     {
         failure(error, response);
     }];
}

#pragma mark - Price Estimates

- (void) getPriceForTripWithStartLatitude:(float)startLatitude startLongitude:(float)startLongitude endLatitude:(float)endLatitude endLongitude:(float)endLongitude success:(SuccessHandler)success failure:(FailureHandler)failure
{
    // GET /v1/estimates/price
    
    NSString *url = [NSString stringWithFormat:@"%@/v1/estimates/price?server_token=%@&start_latitude=%f&start_longitude=%f&end_latitude=%f&end_longitude=%f", baseURL, serverToken, startLatitude, startLongitude, endLatitude, endLongitude];
    [self performNetworkOperationWithURL:url success:^(NSDictionary *results)
     {
         NSArray *prices = [results objectForKey:@"prices"];
         NSMutableArray *availablePrices = [[NSMutableArray alloc] init];
         for(int i=0; i<prices.count; i++)
         {
             UberPrice *price = [[UberPrice alloc] initWithDictionary:[prices objectAtIndex:i]];
             [availablePrices addObject:price];
         }
         success(availablePrices);
     }
    failure:^(NSError *error, NSHTTPURLResponse *response)
     {
         failure(error, response);
     }];
}

#pragma mark - Time Estimates

- (void) getTimeForProductArrivalWithStartLatitude:(float)startLatitude startLongitude:(float)startLongitude success:(SuccessHandler)success failure:(FailureHandler)failure
{
    //GET /v1/estimates/time
    
    NSString *url = [NSString stringWithFormat:@"%@/v1/estimates/time?server_token=%@&start_latitude=%f&start_longitude=%f", baseURL, serverToken, startLatitude, startLongitude];
    [self performNetworkOperationWithURL:url success:^(NSDictionary *results)
     {
         NSArray *times = [results objectForKey:@"times"];
         NSMutableArray *availableTimes = [[NSMutableArray alloc] init];
         for(int i=0; i<times.count; i++)
         {
             UberTime *time = [[UberTime alloc] initWithDictionary:[times objectAtIndex:i]];
             [availableTimes addObject:time];
         }
         success(availableTimes);
         
     }
    failure:^(NSError *error, NSHTTPURLResponse *response)
     {
         failure(error, response);
     }];
}

#pragma mark - Deep Linking

- (void) openUberApp
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"uber://"]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"uber://"]];
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://uber.com"]];
    }
}

@end

@implementation UberKit (Private)

- (void) performNetworkOperationWithURL:(NSString *)url success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *, NSHTTPURLResponse *))failure
{
    NSLog(@"Url %@", url);
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    [[session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {

            NSError *jsonError = nil;
            NSDictionary *serializedResults = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            
            if (jsonError == nil) {
                success(serializedResults);
            } else {
                NSHTTPURLResponse *convertedResponse = (NSHTTPURLResponse *)response;
                failure(jsonError, convertedResponse);
            }
            
        } else {
            
            NSHTTPURLResponse *convertedResponse = (NSHTTPURLResponse *)response;
            failure(error, convertedResponse);
        }
    }] resume];
}

@end