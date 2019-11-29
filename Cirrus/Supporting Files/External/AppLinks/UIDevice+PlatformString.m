#import "UIDevice+PlatformString.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@implementation UIDevice (PlatformString)

- (NSString *) platform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

- (NSString *) platformString{
    NSString *platform = [self platform];
    // Source: https://www.theiphonewiki.com/wiki/Models

    // Apple TV
    if ([platform isEqualToString:@"AppleTV2,1"])   return @"Apple TV 2";
    if ([platform isEqualToString:@"AppleTV3,1"])   return @"Apple TV 3";
    if ([platform isEqualToString:@"AppleTV3,2"])   return @"Apple TV 3 (Rev 2)";
    if ([platform isEqualToString:@"AppleTV5,3"])   return @"Apple TV 4";
    if ([platform isEqualToString:@"AppleTV6,2"])   return @"Apple TV 4K";

    // iPhone
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone10,1"])   return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,4"])   return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,2"])   return @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,5"])   return @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,3"])   return @"iPhone X";
    if ([platform isEqualToString:@"iPhone10,6"])   return @"iPhone X";
    if ([platform isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
    if ([platform isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
    if ([platform isEqualToString:@"iPhone11,8"])   return @"iPhone XR";

    // iPod Touch
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5";
    if ([platform isEqualToString:@"iPod7,1"])      return @"iPod Touch 6";
    if ([platform isEqualToString:@"iPod9,1"])      return @"iPod Touch 7";

    // iPad
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air (Cellular - China)";
    if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2 (WiFi)";
    if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2 (Cellular)";
    if ([platform isEqualToString:@"iPad6,7"])      return @"iPad Pro (12.9\" WiFi)";
    if ([platform isEqualToString:@"iPad6,8"])      return @"iPad Pro (12.9\" Cellular)";
    if ([platform isEqualToString:@"iPad6,3"])      return @"iPad Pro (9.7\" WiFi)";
    if ([platform isEqualToString:@"iPad6,4"])      return @"iPad Pro (9.7\" Cellular)";
    if ([platform isEqualToString:@"iPad7,3"])      return @"iPad Pro (10.5\" WiFi)";
    if ([platform isEqualToString:@"iPad7,4"])      return @"iPad Pro (10.5\" Cellular)";
    if ([platform isEqualToString:@"iPad6,11"])      return @"iPad 5 (WiFi)";
    if ([platform isEqualToString:@"iPad6,12"])      return @"iPad 5 (Cellular)";
    if ([platform isEqualToString:@"iPad7,5"])      return @"iPad 6 (WiFi)";
    if ([platform isEqualToString:@"iPad7,6"])      return @"iPad 6 (Cellular)";
    if ([platform isEqualToString:@"iPad8,1"])      return @"iPad Pro (10.5\" WiFi)";
    if ([platform isEqualToString:@"iPad8,2"])      return @"iPad Pro (10.5\" WiFi)";
    if ([platform isEqualToString:@"iPad8,3"])      return @"iPad Pro (10.5\" Cellular)";
    if ([platform isEqualToString:@"iPad8,4"])      return @"iPad Pro (10.5\" Cellular)";
    if ([platform isEqualToString:@"iPad8,5"])      return @"iPad Pro (12.9\" 2 WiFi)";
    if ([platform isEqualToString:@"iPad8,6"])      return @"iPad Pro (12.8\" 2 WiFi)";
    if ([platform isEqualToString:@"iPad8,7"])      return @"iPad Pro (12.9\" 2 Cellular)";
    if ([platform isEqualToString:@"iPad8,8"])      return @"iPad Pro (12.8\" 2 Cellular)";
    if ([platform isEqualToString:@"iPad11,3"])      return @"iPad Air 3 (WiFi)";
    if ([platform isEqualToString:@"iPad11,4"])      return @"iPad Air 3 (Cellular)";

    // iPad Mini
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad mini 2 (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad mini 2 (Cellular)";
    if ([platform isEqualToString:@"iPad4,6"])      return @"iPad mini 2 (Cellular - China)";
    if ([platform isEqualToString:@"iPad4,7"])      return @"iPad mini 3 (WiFi)";
    if ([platform isEqualToString:@"iPad4,8"])      return @"iPad mini 3 (Cellular)";
    if ([platform isEqualToString:@"iPad4,9"])      return @"iPad mini 3 (Cellular - China)";
    if ([platform isEqualToString:@"iPad5,1"])      return @"iPad mini 4 (WiFi)";
    if ([platform isEqualToString:@"iPad5,2"])      return @"iPad mini 4 (Cellular)";
    if ([platform isEqualToString:@"iPad11,1"])      return @"iPad mini 5 (WiFi)";
    if ([platform isEqualToString:@"iPad11,2"])      return @"iPad mini 5 (Cellular)";

    // Other
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}

@end
