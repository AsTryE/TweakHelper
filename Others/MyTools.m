//
//  MyTools.m
//  toolsgo
//
//  Created by tangxianhai on 2018/1/19.
//  Copyright © 2018年 ninetonrrr. All rights reserved.
//

#import "MyTools.h"

@implementation MyTools
+ (NSString *)stringByAddingPercentEncodingForFormData:(BOOL)plusForSpace string:(NSString *)sourceString {
    NSString *unreserved = @"*-._";
    NSMutableCharacterSet *allowed = [NSMutableCharacterSet
                                      alphanumericCharacterSet];
    [allowed addCharactersInString:unreserved];
    if (plusForSpace) {
        [allowed addCharactersInString:@" "];
    }
    NSString *encoded = [sourceString stringByAddingPercentEncodingWithAllowedCharacters:allowed];
    if (plusForSpace) {
        encoded = [encoded stringByReplacingOccurrencesOfString:@" "
                                                     withString:@"+"];
    }
    return encoded;
}

+(void)TLog:(NSString*)logString {
        int stepLog = 600;
        NSInteger strLen = [@([logString length]) integerValue];
        NSInteger countInt = strLen / stepLog;
        if (strLen > stepLog) {
        for (int i=1; i <= countInt; i++) {
            NSString *character = [logString substringWithRange:NSMakeRange((i*stepLog)-stepLog, stepLog)];
            NSLog(@"TLog: count:%d-------character ---- %@",i, character);
        }
        NSString *character = [logString substringWithRange:NSMakeRange((countInt*stepLog), strLen-(countInt*stepLog))];
        NSLog(@"TLog: last character ----%@", character);
        } else {
            NSLog(@"TLog: %@", logString);
        }
}

+ (NSString *)paramStringFromParams:(NSDictionary *)params {


    NSMutableString *returnValue = [[NSMutableString alloc]initWithCapacity:0];
    NSArray *paramsAllKeys = [params allKeys];
    for(int i = 0;i < paramsAllKeys.count;i++)
    {
        [returnValue appendFormat:@"%@=%@",[paramsAllKeys objectAtIndex:i],[MyTools stringByAddingPercentEncodingForFormData:YES string:[params objectForKey:[paramsAllKeys objectAtIndex:i]]]];
        if(i < paramsAllKeys.count - 1)
        {
            [returnValue appendString:@"&"];
        }
    }
    return returnValue;
}

int runCmd(char *cmd) {
    pid_t pid;
    int status;

    if (cmd == NULL) {
        return (1); //如果cmdstring为空，返回非零值，一般为1
    }

    if ((pid = fork())<0) {
        status = -1; //fork失败，返回-1
    } else if(pid == 0) {
        execl("/bin/sh", "sh", "-c", cmd, (char *)0);
        _exit(127); // exec执行失败返回127，注意exec只在失败时才返回现在的进程，成功的话现在的进程就不存在啦~~
    }
    else {
        //父进程
        while(waitpid(pid, &status, 0) < 0) {
            if(errno != EINTR) {
                status = -1; //如果waitpid被信号中断，则返回-1
                break;
            }
        }
    }

    return status; //如果waitpid成功，则返回子进程的返回状态
}

@end
