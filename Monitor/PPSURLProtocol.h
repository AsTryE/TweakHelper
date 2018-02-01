//
//  PPSURLProtocol.h
//  PPSNetworkMonitor
//
//  Created by ppsheep on 2017/4/8.
//  Copyright © 2017年 ppsheep. All rights reserved.
//


/*
用法：
	1. didFinishing 中调用
	+++++++++++++++++++++++++++++++
	static dispatch_once_t onceToken;
	    dispatch_once(&onceToken, ^{
	        [PPSURLProtocol start];
	        NSLog(@"开始任务列表信息数据监听");
	    });
	+++++++++++++++++++++++++++++++

	2. 监听 MobileSafari 浏览器进程 -> 添加 bundle id —> com.apple.mobilesafari
	添加下面代码：
	+++++++++++++++++++++++++++++++
	%ctor {
		Class cls = NSClassFromString(@"WKBrowsingContextController");
		SEL sel = NSSelectorFromString(@"registerSchemeForCustomProtocol:");
		if ([(id)cls respondsToSelector:sel]) {
		    // 把 http 和 https 请求交给 NSURLProtocol 处理
		    [(id)cls performSelector:sel withObject:@"http"];
		    [(id)cls performSelector:sel withObject:@"https"];
		}
		// PPSURLProtocol 自定义的协议
		[NSURLProtocol registerClass:[PPSURLProtocol class]];
	} 
	+++++++++++++++++++++++++++++++

注意：想要监听浏览器必须添加上面第二步的代码 ^ - ^ 
*/

#import <Foundation/Foundation.h>
#import "PPSURLSessionConfiguration.h"
#import "../MethodTrace/ANYMethodLog.h"

@interface PPSURLProtocol : NSURLProtocol

+ (void)start;

+ (void)end;

@end
