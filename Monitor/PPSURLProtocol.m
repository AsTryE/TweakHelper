//
//  PPSURLProtocol.m
//  PPSNetworkMonitor
//
//  Created by ppsheep on 2017/4/8.
//  Copyright © 2017年 ppsheep. All rights reserved.
//

#import "PPSURLProtocol.h"

static NSString *const PPSHTTP = @"PPSHTTP";//为了避免canInitWithRequest和canonicalRequestForRequest的死循环

@interface PPSURLProtocol()<NSURLConnectionDelegate,NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLRequest *pps_request;
@property (nonatomic, strong) NSURLResponse *pps_response;
@property (nonatomic, strong) NSMutableData *pps_data;

@end

@implementation PPSURLProtocol

- (NSMutableData *)pps_data{
        if (!_pps_data) {
            _pps_data = [[NSMutableData alloc]init];
        }
        return _pps_data;
}

#pragma mark - init
- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (void)load {
    
}

+ (void)start {
    PPSURLSessionConfiguration *sessionConfiguration = [PPSURLSessionConfiguration defaultConfiguration];
    [NSURLProtocol registerClass:[PPSURLProtocol class]];
    if (![sessionConfiguration isSwizzle]) {
        [sessionConfiguration load];
    }
}

+ (void)end {
    PPSURLSessionConfiguration *sessionConfiguration = [PPSURLSessionConfiguration defaultConfiguration];
    [NSURLProtocol unregisterClass:[PPSURLProtocol class]];
    if ([sessionConfiguration isSwizzle]) {
        [sessionConfiguration unload];
    }
}


/**
 需要控制的请求

 @param request 此次请求
 @return 是否需要监控
 */
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    
    if (![request.URL.scheme isEqualToString:@"http"] &&
        ![request.URL.scheme isEqualToString:@"https"]) {
        return NO;
    }
    //如果是已经拦截过的  就放行
    if ([NSURLProtocol propertyForKey:PPSHTTP inRequest:request] ) {
        return NO;
    }
    return YES;
}

/**
 设置我们自己的自定义请求
 可以在这里统一加上头之类的
 
 @param request 应用的此次请求
 @return 我们自定义的请求
 */
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    [NSURLProtocol setProperty:@YES
                        forKey:PPSHTTP
                     inRequest:mutableReqeust];
    return [mutableReqeust copy];
}

- (void)startLoading {
    NSURLRequest *request = [[self class] canonicalRequestForRequest:self.request];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    self.pps_request = self.request;
}

- (void)stopLoading {
    [self.connection cancel];

    //获取请求方法
    NSString *requestMethod = self.pps_request.HTTPMethod;
    NSLog(@"请求方法：%@\n",requestMethod);
    
    //获取请求头
    NSDictionary *headers = self.pps_request.allHTTPHeaderFields;
    NSLog(@"请求头：\n");
    for (NSString *key in headers.allKeys) {
        if (key != nil && headers[key] != nil)
        {
            NSLog(@"%@ : %@",key,headers[key]);
        }
    }
    
    //打印请求参数
    if ([requestMethod isEqualToString:@"POST"]) {
        NSString *urlString = self.pps_request.URL.description;
        NSLog(@"POST请求URL：\n%@",urlString);
        if (self.pps_request == nil)
        {   
             return;
        }
        if (self.pps_request.HTTPBody == nil)
        {
            NSLog(@"POST请求URL：\n%@ 没有请求参数",urlString);
            return;
        }
        NSDictionary *httpBody = [NSJSONSerialization JSONObjectWithData:self.pps_request.HTTPBody options:NSJSONReadingMutableContainers error:nil];
        if (httpBody != nil) {
            NSLog(@"POST请求参数JSON：\n%@",httpBody);
        }else {
            NSString *htmlString =  [[NSString alloc] initWithData:self.pps_request.HTTPBody  encoding:NSUTF8StringEncoding];
            if (htmlString != nil && ![htmlString isEqualToString:@"(null)"] && ![htmlString isEqualToString:@"null"]) {
                NSLog(@"POST请求参数字符串：\n%@",htmlString);
            } else {
                if (self.pps_request != nil)
                {
                    if (self.pps_request.HTTPBody != nil)
                    {
                        NSLog(@"POST请求参数解析失败,因为是二进制数据：\n%@",self.pps_request.HTTPBody);
                    }
                }
            }
        }
    } else {
        if (self.pps_request != nil)
                {
                    if (self.pps_request.URL.description != nil)
                    {
                        NSString *urlString = self.pps_request.URL.description;
                         NSLog(@"GET请求URL：\n%@",urlString);
                    }
                }
    }

    //打印响应值
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:self.pps_data options:NSJSONReadingMutableLeaves error:nil];
    if (dic != nil) {
        NSLog(@"返回响应值JSON：\n%@",dic); 
        // NSString *urlString = self.pps_request.URL.description;

        // // test url http://192.168.10.37/auser/getshikedata
        // if ([urlString containsString:@"http://shike.com/shike/api/appList"])
        // {
        //     // 小鱼赚钱任务列表获取成功，开始上传至服务器
        //     NSData *tasksData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
        //     NSString *taskJsonString = [[NSString alloc] initWithData:tasksData encoding:NSUTF8StringEncoding];
        //     NSLog(@"shike45 数据开始上传 -> %@",taskJsonString);
        //     [MyNetWorkManager postWithUrlString:@"http://manage.cattry.com/auser/getshikedata" parameters:@{@"shikeData":taskJsonString} success:^(NSDictionary *data) {
        //         TLog(@"shike45 ok 上传成功 %@",data);
        //         // NSString *js = [NSString stringWithFormat:@"var alert = [[UIAlertView alloc] initWithTitle:nil message:@\"success !!!!\" delegate:nil cancelButtonTitle:nil otherButtonTitles:@\"ok\", nil];\n[alert show];"];
        //         // BOOL written = [js writeToFile:ALERT_OK_JS_PATH atomically:YES];
        //         // NSString *cmd = [NSString stringWithFormat:@"cycript -p SpringBoard %@",ALERT_OK_JS_PATH];
        //         // runCmd([cmd cStringUsingEncoding:NSUTF8StringEncoding]);
        //     } failure:^(NSError *error) {
        //         TLog(@"shike45 ok 上传失败 %@",[error description]);
        //         // NSString *js = [NSString stringWithFormat:@"var alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@\"error:\n%@\",[error description]] delegate:nil cancelButtonTitle:nil otherButtonTitles:@\"ok\", nil];\n[alert show];"];
        //         // BOOL written = [js writeToFile:ALERT_ERROR_JS_PATH atomically:YES];
        //         // NSString *cmd = [NSString stringWithFormat:@"cycript -p SpringBoard %@",ALERT_ERROR_JS_PATH];
        //         // runCmd([cmd cStringUsingEncoding:NSUTF8StringEncoding]);
        //     }];
        //  }

    }
    
    if (dic == nil) {
        NSString *htmlString =  [[NSString alloc] initWithData:self.pps_data  encoding:NSUTF8StringEncoding];
        if (htmlString != nil && ![htmlString isEqualToString:@"(null)"] && ![htmlString isEqualToString:@"null"]) {
            NSLog(@"返回响应值html：\n%@",htmlString);
            NSLog(@"返回值为二进制数据：\n%@",self.pps_data);
        }
        else {
            if (self.pps_data != nil)
            {
                NSLog(@"返回值为二进制资源文件数据：\n%@",self.pps_data);
            }
        }
    }
    
}

#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [self.client URLProtocol:self didFailWithError:error];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection{
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    [self.client URLProtocol:self didReceiveAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection
didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [self.client URLProtocol:self didCancelAuthenticationChallenge:challenge];
}

#pragma mark - NSURLConnectionDataDelegate
-(NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response{
    if (response != nil) {
        self.pps_response = response;
        [self.client URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    }
    return request;
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    self.pps_response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
    [self.pps_data appendData:data];
    
    //获取请求结果
    // NSString *urlString = self.pps_request.URL.description;
    
    // if ([urlString isEqualToString:@"https://wall.qumi.com/Ioswall/Wall/AdList"]) {
    //     NSLog(@"请求结果1：%@",json);
    // }
    
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return cachedResponse;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[self client] URLProtocolDidFinishLoading:self];
}

//转换json
-(id)responseJSONFromData:(NSData *)data {
    if(data == nil) return nil;
    NSError *error = nil;
    id returnValue = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if(error) {
        NSLog(@"JSON Parsing Error: %@", error);
        //https://github.com/coderyi/NetworkEye/issues/3
        return nil;
    }
    //https://github.com/coderyi/NetworkEye/issues/1
    if (!returnValue || returnValue == [NSNull null]) {
        return nil;
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:returnValue options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

@end
