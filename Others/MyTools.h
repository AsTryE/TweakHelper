//
//  MyTools.h
//  toolsgo
//
//  Created by tangxianhai on 2018/1/19.
//  Copyright © 2018年 ninetonrrr. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TLog(format,...) [MyTools TLog:[NSString stringWithFormat:(format), ##__VA_ARGS__]];

@interface MyTools : NSObject

// url编码
+ (NSString *)stringByAddingPercentEncodingForFormData:(BOOL)plusForSpace string:(NSString *)sourceString;
+ (NSString *)paramStringFromParams:(NSDictionary *)params;

// comm
int runCmd(char *cmd);

// 统一日志打印 前缀：TLog:
+ (void)TLog:(NSString*)logString;

@end
