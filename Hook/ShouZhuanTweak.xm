#import "../Others/MyTools.h"
// 移除越狱后安装的常见应用
%hook LSApplicationWorkspace
- (NSArray *)allInstalledApplications {
	NSArray *appList = %orig;
	NSMutableArray *mApplist = [[NSMutableArray alloc] initWithArray:appList];
	Class LSApplicationProxy_class = object_getClass(@"LSApplicationProxy");
	for (LSApplicationProxy_class in appList)
    {
        NSString *bundleID = [LSApplicationProxy_class performSelector:@selector(applicationIdentifier)];
        NSString *version =  [LSApplicationProxy_class performSelector:@selector(bundleVersion)];
        NSString *shortVersionString =  [LSApplicationProxy_class performSelector:@selector(shortVersionString)];
        if ([bundleID containsString:@"Cydia"] 
            || [bundleID containsString:@"yalu102"]
        	|| [bundleID containsString:@"yalu103"] 
            || [bundleID containsString:@"touchsprite"]
        	|| [bundleID containsString:@"eu.heinelt.ifile"] 
            || [bundleID containsString:@"com.doubibi74.money76"]
        	|| [bundleID containsString:@"com.a.emoji"] 
            || [bundleID containsString:@"com.e4bf058461-1-42"]
        	|| [bundleID containsString:@"ent.touchsprite.ios"]) {
                [mApplist removeObject:LSApplicationProxy_class];
                TLog(@"已经移除越狱app1----->bundleID：%@\n version： %@\n ,shortVersionString:%@\n", bundleID,version,shortVersionString);
        } else {
                TLog(@"bundleID：%@\n version： %@\n ,shortVersionString:%@\n", bundleID,version,shortVersionString);
        }
    }
    return  mApplist;
}
%end