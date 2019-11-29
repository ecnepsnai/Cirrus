#import "CFZone.h"

@implementation CFZone

+ (CFZone *) fromDictionary:(NSDictionary<NSString *, id> *)dictionary {
    CFZone * zone = [CFZone new];
#define _zone_add(prop, key) zone.prop = [dictionary objectForKey:key]
    _zone_add(identifier, @"id");
    _zone_add(name, @"name");
    _zone_add(status, @"status");
    _zone_add(type, @"type");
    _zone_add(name_servers, @"name_servers");
    _zone_add(original_name_servers, @"original_name_servers");
    _zone_add(original_registrar, @"original_registrar");
    _zone_add(original_dnshost, @"original_dnshost");
    _zone_add(modified_on, @"modified_on");
    _zone_add(created_on, @"created_on");
    _zone_add(meta, @"meta");
    _zone_add(owner, @"owner");
    _zone_add(permissions, @"permissions");
    _zone_add(plan, @"plan");
    zone.development_mode = [[dictionary objectForKey:@"development_mode"] intValue];
    zone.paused = [[dictionary objectForKey:@"paused"] boolValue];

    return zone;
}

- (NSDictionary<NSString *, id> *) dictionaryValue {
    return @{
             @"id": self.identifier,
             @"name": self.name,
             @"status": self.status,
             @"type": self.type,
             @"name_servers": self.name_servers,
             @"original_name_servers": self.original_name_servers,
             @"original_registrar": self.original_registrar,
             @"original_dnshost": self.original_dnshost,
             @"modified_on": self.modified_on,
             @"created_on": self.created_on,
             @"meta": self.meta,
             @"owner": self.owner,
             @"permissions": self.permissions,
             @"plan": self.plan,
             @"development_mode": [NSNumber numberWithInt:self.development_mode],
             @"paused": [NSNumber numberWithBool:self.paused]
             };
}

- (CFZoneStatus) displayStatus {
    if (self.development_mode > 0) {
        return CFZoneStatusDevMode;
    }
    
    if (self.paused) {
        return CFZoneStatusPaused;
    }
    
    if ([self.status isEqualToString:@"moved"]) {
        return CFZoneStatusMoved;
    }
    
    return CFZoneStatusActive;
}

- (BOOL) hidden {
    NSArray<NSString *> * hiddenZones = UserOptions.hiddenZones;
    return [hiddenZones containsObject:self.name];
}

- (BOOL) readOnly {
    NSArray<NSString *> * readOnlyZones = UserOptions.readOnlyZones;
    return [readOnlyZones containsObject:self.name];
}

- (void) setHidden:(BOOL)hidden {
    NSArray<NSString *> * zl = UserOptions.hiddenZones;
    if (zl == nil) {
        zl = @[];
    }
    NSMutableArray<NSString *> * zones = [NSMutableArray arrayWithArray:zl];
    if (hidden) {
        [zones addObject:self.name];
    } else {
        [zones removeObject:self.name];
    }
    UserOptions.hiddenZones = zones;
}

- (void) setReadOnly:(BOOL)readOnly {
    NSArray<NSString *> * zl = UserOptions.readOnlyZones;
    if (zl == nil) {
        zl = @[];
    }
    NSMutableArray<NSString *> * zones = [NSMutableArray arrayWithArray:zl];
    if (readOnly) {
        [zones addObject:self.name];
    } else {
        [zones removeObject:self.name];
    }
    UserOptions.readOnlyZones = zones;
}

@end
