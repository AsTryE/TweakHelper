//
//  MyNetWorkManager.h
//  toolsgo
//
//  Created by tangxianhai on 2018/1/29.
//  Copyright © 2018年 ninetonrrr. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompletioBlock)(NSDictionary *dic, NSURLResponse *response, NSError *error);
typedef void (^SuccessBlock)(NSDictionary *data);
typedef void (^FailureBlock)(NSError *error);

@interface MyNetWorkManager : NSObject

/**
 *  get请求
 */
+ (void)getWithUrlString:(NSString *)url parameters:(id)parameters success:(SuccessBlock)successBlock failure:(FailureBlock)failureBlock;

/**
 * post请求
 */
+ (void)postWithUrlString:(NSString *)url parameters:(id)parameters success:(SuccessBlock)successBlock failure:(FailureBlock)failureBlock;
@end
