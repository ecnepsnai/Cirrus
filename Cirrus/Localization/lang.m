#import "lang.h"

@implementation lang

static id _langDict;

+ (void) loadDict {
    NSString * preferrendLang = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString * lang;
    for (NSString * supportedLanguage in @[@"en"]) {
        if ([preferrendLang hasPrefix:supportedLanguage]) {
            lang = supportedLanguage;
        }
    }
    if (lang == nil) { lang = @"en"; }
#if LANG_DEBUG
    d(@"Loading lang dictionary for lang: %@", lang);
#endif
    _langDict = [NSDictionary dictionaryWithContentsOfFile:
                                     [[NSBundle mainBundle] pathForResource:lang ofType:@"plist"]];
}

+ (NSString *) key:(NSString *)key dict:(NSDictionary *)dict {
    NSString * translatedString = dict[key];
    if (translatedString == nil) {
        d(@"Unrecognized language key: %@", key);
        translatedString = key;
    }
#if LANG_DEBUG > 1
    d(@"Requesting translated string for key (%@) %@", key, translatedString);
#endif
    return translatedString;
}

+ (BOOL) keyExists:(NSString *)key {
    return [_langDict stringForKey:key] != nil;
}

+ (NSString *) key:(NSString *)key args:(NSArray<NSString *> *)args dict:(NSDictionary *)dict {
    NSString * translatedString = [lang key:key dict:dict];
    NSString * stringKey;
    NSUInteger length = args.count;
    for (int i = 0; i < length; i++) {
        stringKey = [NSString stringWithFormat:@"{%u}", i];
#if LANG_DEBUG > 1
        d(@"Replacing lang argument key %@ with value %@", stringKey, args[i]);
#endif
        translatedString = [translatedString stringByReplacingOccurrencesOfString:stringKey
            withString:args[i]];
    }

    return translatedString;
}

+ (NSString *) key:(NSString *)key {
    if (!key) {
        return @"";
    }

    if (_langDict == nil) {
        [lang loadDict];
    }
    return [lang key:key dict:_langDict];
}

+ (NSString *) key:(NSString *)key args:(NSArray<NSString *> *)args {
    if (_langDict == nil) {
        [lang loadDict];
    }
    return [lang key:key args:args dict:_langDict];
}

+ (NSString *) key:(NSString *)key forLanguage:(NSString *)language {
    NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:
        [[NSBundle mainBundle] pathForResource:language ofType:@"plist"]];
    return [lang key:key dict:dict];
}

+ (NSString *) key:(NSString *)key
    args:(NSArray<NSString *> *)args
    forLanguage:(NSString *)language {
    NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:
        [[NSBundle mainBundle] pathForResource:language ofType:@"plist"]];
    return [lang key:key args:args dict:dict];
}

@end
