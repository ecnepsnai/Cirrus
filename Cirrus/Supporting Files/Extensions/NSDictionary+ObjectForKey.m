@implementation NSDictionary (ObjectForKey)

- (NSString *) stringForKey:(NSString *)key {
    return (NSString *)[self objectForKey:key];
}

- (NSNumber *) numberForKey:(NSString *)key {
    return (NSNumber *)[self objectForKey:key];
}

- (BOOL) boolForKey:(NSString *)key {
    return [[self numberForKey:key] boolValue];
}

- (NSDictionary *) dictionaryForKey:(NSString *)key {
    return (NSDictionary *)[self objectForKey:key];
}

- (NSArray *) arrayForKey:(NSString *)key {
    return (NSArray *)[self objectForKey:key];
}

- (NSUInteger) unsignedIntegerForKey:(NSString * _Nonnull)key {
    return [[self numberForKey:key] unsignedIntegerValue];
}

- (NSInteger) integerForKey:(NSString * _Nonnull)key {
    return [[self numberForKey:key] integerValue];
}

@end
