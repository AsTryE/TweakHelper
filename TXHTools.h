#import <Foundation/Foundation.h>
#import "MethodTrace/ANYMethodLog.h"
#import "Monitor/PPSURLProtocol.h"
#import "Others/MyTools.h"
#import "NetworkManager/MyNetWorkManager.h"
/*
使用方法

	1. 导入TweakHelper文件件到项目根目录
	2. 配置Makefile文件
		2.1 首行新增 THEOS_DEVICE_IP = 192.168.2.62     表示通过ssh安装插件到指定IP的手机
		2.2 添加编译源文件选项到 $(TWEAK_NAME)_FILES 下面

			$(TWEAK_NAME)_FILES += TweakHelper/TXHTools.m \
						TweakHelper/MethodTrace/ANYMethodLog.m \
						TweakHelper/NetworkManager/MyNetWorkManager.m \
						TweakHelper/Monitor/PPSURLProtocol.m \
						TweakHelper/Others/MyTools.m \
						TweakHelper/Monitor/PPSURLSessionConfiguration.m \
						TweakHelper/Hook/ShouZhuanTweak.xm \

		2.3 添加忽略编译警告选项
			$(TWEAK_NAME)_CFLAGS = -fobjc-arc -w      表示工程开启ARC以及忽略编译警告
		2.4 可选，是否kill浏览器 进程名称 MobileSafari

	3. 监听浏览器网络请求

		3.1 didFinishing 中调用

		static dispatch_once_t onceToken;
		    dispatch_once(&onceToken, ^{
		        [PPSURLProtocol start];
		        NSLog(@"开始任务列表信息数据监听");
		    });

		3.2 监听 MobileSafari 浏览器进程 -> 添加 bundle id —> com.apple.mobilesafari
		添加下面代码：

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

		注意：想要监听浏览器必须添加上面第二步的代码 ^ - ^ 


	4. 打印类方法调用 官方文档 https://github.com/qhd/ANYMethodLog

			[ANYMethodLog logMethodWithClass:NSClassFromString(@"NavigationBar") condition:^BOOL(SEL sel) {
		    return  YES;
		} before:^(id target, SEL sel, NSArray *args, int deep) {
		    NSString *selector = NSStringFromSelector(sel);
		    NSArray *selectorArrary = [selector componentsSeparatedByString:@":"];
		    selectorArrary = [selectorArrary filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
		    NSMutableString *selectorString = [NSMutableString new];
		    for (int i = 0; i < selectorArrary.count; i++) {
		        [selectorString appendFormat:@"%@:%@ ", selectorArrary[i], args[i]];
		    }
		    NSMutableString *deepString = [NSMutableString new];
		    for (int i = 0; i < deep; i++) {
		        [deepString appendString:@"-"];
		    }
		    TLog(@"%@[%@ %@]", deepString , target, selectorString);
		} after:^(id target, SEL sel, NSArray *args, NSTimeInterval interval, int deep, id retValue) {
		    NSMutableString *deepString = [NSMutableString new];
		    for (int i = 0; i < deep; i++) {
		        [deepString appendString:@"-"];
		    }
		    TLog(@"%@ret:%@", deepString, retValue);
		}];

*/

@interface TXHTools : NSObject

@end

