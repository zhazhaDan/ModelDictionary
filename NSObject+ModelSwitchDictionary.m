 
//
//  NSObject+ModelSwitchDictionary.m
//  GDCommonDemo
//
//  Created by 龚丹丹 on 15/11/8.
//  Copyright © 2015年 龚丹丹. All rights reserved.
//

#import "NSObject+ModelSwitchDictionary.h"
#import <objc/runtime.h>

/**
 * json 三大类型  NSString NSNumber  NSNull
 */

@implementation NSObject (Model)

- (NSArray *)propertys {
    return [self propertysAvoidKeys:[NSMutableArray arrayWithCapacity:0]];
}

- (NSArray *)propertysAvoidKeys:(NSArray *)avoidKeys {
    return [self propertysContainKeys:nil avoidKeys:avoidKeys];
}

- (NSArray *)propertysContainKeys:(NSArray *)containKeys avoidKeys:(NSArray *)avoidKeys {
    unsigned int count;
    // 获取类中所有变量
    objc_property_t * varList = class_copyPropertyList([self class], &count);
    NSMutableArray * mulArray = [NSMutableArray array];
    
    if (containKeys && containKeys.count > 0) {
        for (int i = 0; i < count; i++) {
            objc_property_t var = varList[i];
            // 获取属性名称
            NSString * name = [NSString stringWithUTF8String:property_getName(var)];
            if ([containKeys containsObject:name]) {
                [mulArray addObject:name];
            }
        }
    }else {
        for (int i = 0; i < count; i++) {
            objc_property_t var = varList[i];
            @try {
                // 获取属性名称
                NSString * name = [NSString stringWithUTF8String:property_getName(var)];
                if (avoidKeys != nil && [avoidKeys containsObject:name]) {
                    continue;
                }else {
                    [mulArray addObject:name];
                }
            }
            @catch (NSException *exception) {
                YYBLog(exception);
            }
            @finally {
                
            }
            
        }
    }
    free(varList);//用c的方法一定要释放
    if (self.superclass != [NSObject class] && self.superclass != [NSManagedObject class] && self.superclass != [YYBInfo class] && self.superclass != [NSValue class]) {
        [mulArray addObjectsFromArray:[self.superclass propertysContainKeys:containKeys avoidKeys:avoidKeys]];
    }
    return [mulArray copy];
}

- (NSString *)propertyNameFromVarList:(void **)varList atIndex:(int)i {
    objc_property_t var = varList[i];
    // 获取属性名称
    NSString * name = [NSString stringWithUTF8String:property_getName(var)];
    return name;
}

- (NSArray *)valuesFromSelf {
    return [self valuesFromSelfAvoidKeys:[NSMutableArray arrayWithCapacity:0]];
}

- (NSArray *)valuesFromSelfAvoidKeys:(NSArray *)avoidKeys {
    return [self valuesFromSelfContainKeys:nil avoidKeys:avoidKeys];
}

- (NSArray *)valuesFromSelfContainKeys:(NSArray *)containKeys avoidKeys:(NSArray *)avoidKeys {
    NSMutableArray * mulArray = [NSMutableArray array];
    
    NSArray * array = [self propertysContainKeys:containKeys avoidKeys:avoidKeys];
    for (NSString * propertyKey in array) {
        id value = nil;
//        @try {
            value = [self objValueForKye:propertyKey];
//        }
//        @catch (NSException *exception) {
//            YYBLogLevel(LogWarning, ([NSString stringWithFormat:@"%@类型不匹配",propertyKey]));
//        }
//        @finally {
//            
//        }
        if (value == nil) {
            continue;
        }
        [mulArray addObject:value];
    }
    return [mulArray copy];
}

- (NSDictionary *)valuesAndKeysDictionay {
   return [self valuesAndKeysDictionayAvoidKeys:[NSMutableArray arrayWithCapacity:0]];
}

- (NSDictionary *)valuesAndKeysDictionayAvoidKeys:(NSArray *)avoidKeys {
    return [self valuesAndKeysDictionayContainKeys:nil avoidKeys:avoidKeys];
}

- (NSDictionary *)valuesAndKeysDictionayContainKeys:(NSArray *)containKeys {
    return [self valuesAndKeysDictionayContainKeys:containKeys avoidKeys:nil];
}

- (NSDictionary *)valuesAndKeysDictionayContainKeys:(NSArray *)containKeys avoidKeys:(NSArray *)avoidKeys {
    if ([self isKindOfClass:[NSSet class]] || [self isKindOfClass:[NSOrderedSet class]]) {
        return [NSMutableDictionary dictionary];
    }
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    NSArray * array = [self propertysContainKeys:containKeys avoidKeys:avoidKeys];
    for (NSString * propertyKey in array) {
        if ((avoidKeys != nil && [avoidKeys containsObject:propertyKey]) ||
            (containKeys != nil && ![containKeys containsObject:propertyKey])) {
            continue;
        }
        id value = nil;
//        @try {
            value = [self objValueForKye:propertyKey];
//        }
//        @catch (NSException *exception) {
//            YYBLogLevel(LogWarning, ([NSString stringWithFormat:@"%@类型不匹配",propertyKey]));
//        }
//        @finally {
//            
//        }
        if (value == nil) {
            continue;
        } else {
            [dict setValue:[self objectByPropertyValue:value containKeys:containKeys avoidKeys:avoidKeys] forKey:propertyKey];
        }
    }
    return [dict copy];
}

- (id)objectByPropertyValue:(id)obj containKeys:(NSArray *)containKeys avoidKeys:(NSArray *)avoidKeys {
    if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:[NSNull class]]) {
        return obj;
    } else if ([obj isKindOfClass:[NSArray class]]) {
        NSArray * objArray = obj;
        NSMutableArray * mulArray = [NSMutableArray arrayWithCapacity:objArray.count];
        for (int i = 0; i < objArray.count; i++) {
            [mulArray setObject:[self objectByPropertyValue:[objArray objectAtIndex:i] containKeys:containKeys avoidKeys:avoidKeys] atIndexedSubscript:i];
        }
        return mulArray;
    } else if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary * objDict = obj;
        NSMutableDictionary * mulDict = [NSMutableDictionary dictionaryWithCapacity:objDict.count];
        for (NSString * key in objDict.allKeys) {
            id value = nil;
//            @try {
                value = [objDict objValueForKye:key];
//            }
//            @catch (NSException *exception) {
//                YYBLogLevel(LogWarning, ([NSString stringWithFormat:@"%@类型不匹配",key]));
//            }
//            @finally {
//                
//            }
            [mulDict setObject:[self objectByPropertyValue:value containKeys:containKeys avoidKeys:avoidKeys] forKey:key];
        }
        return mulDict;
    } else {
        return [obj valuesAndKeysDictionayContainKeys:containKeys avoidKeys:avoidKeys];
    }
}

@end


@implementation NSObject(Dict)

+ (void)dictChangeToModelPropertys:(NSDictionary *)dict {
    NSMutableString * propertyString = [NSMutableString string];
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString * type;
        // 这里可以添加其他属性类型
        if ([obj isKindOfClass:NSClassFromString(@"__NSCFString")]) {
            type = @"NSString";
        }else if ([obj isKindOfClass:NSClassFromString(@"__NSCFNumber")]) {
            type = @"NSNumber";
        }else if ([obj isKindOfClass:NSClassFromString(@"__NSCFArray")]) {
            type = @"NSArray";
        }else if ([obj isKindOfClass:NSClassFromString(@"__NSCFDictionay")]) {
            type = @"NSDictionay";
        }
        
        // 这里可以修改对应的属性字符串
        NSString * property;
        if ([type containsString:@"NS"]) {
            property = [NSString stringWithFormat:@"@property (nonatomic, strong)%@ * %@",type,key];
        }else {
            property = [NSString stringWithFormat:@"@property (nonatomic, assign)%@ %@",type,key];
        }
        [propertyString appendFormat:@"\n%@\n",property];
    }];
    NSLog(@"%@",propertyString);
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {

}

- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

//- (void)setNilValueForKey:(NSString *)key {
////    NSString * classString = [self propertyClassStringNameWithPropertyName:key];
////    if (classString) {
////        Class obj = NSClassFromString(classString);
////        [self setValue:[obj new] forKey:key];
////    }else {
////        [self setValue:@0 forKey:key];
////    }
//    @try {
//        [self setValue:nil forKey:key];
//    }
//    @catch (NSException *exception) {
//    }
//    @finally {
//        NSString * string = [NSString stringWithFormat:@"%@ value is nil",key];
//        YYBLogLevel(LogError, string);
//    }
//}

- (instancetype) setShallowModelPropertyForObj:(NSObject *)obj isCleanValue:(BOOL)isClean reflexDictionary:(NSDictionary *)reflex
{
    return [self setShallowModelPropertyForObj:obj avoidKeys:nil containKeys:nil isCleanValue:isClean reflexDictionary:reflex];
}

- (instancetype)setShallowModelPropertyForObj:(NSObject *)obj avoidKeys:(NSArray *)avoidKeys isCleanValue:(BOOL)isClean reflexDictionary:(NSDictionary *)reflex {
    return [self setShallowModelPropertyForObj:obj avoidKeys:avoidKeys containKeys:nil isCleanValue:isClean reflexDictionary:reflex];
}

- (instancetype)setShallowModelPropertyForObj:(NSObject *)obj containKeys:(NSArray *)containKeys isCleanValue:(BOOL)isClean reflexDictionary:(NSDictionary *)reflex {
    return [self setShallowModelPropertyForObj:obj avoidKeys:nil containKeys:containKeys isCleanValue:isClean reflexDictionary:reflex];
}
// reflex
- (instancetype)setShallowModelPropertyForObj:(NSObject *)obj avoidKeys:(NSArray *)avoidKeys containKeys:(NSArray *)containKeys isCleanValue:(BOOL)isClean reflexDictionary:(NSDictionary *)reflex {
    NSArray * propertyList = [self propertysContainKeys:containKeys avoidKeys:avoidKeys];
    if (reflex && reflex.count > 0) {
        for (NSString * propertyName in propertyList) {
            NSString * key = propertyName;
            if ([reflex.allKeys containsObject:propertyName]) {
                key = [reflex objectForKey:propertyName];
            }
            id value = nil;
//            @try {
                value = [obj objValueForKye:key];
//            }
//            @catch (NSException *exception) {
//                YYBLogLevel(LogWarning, ([NSString stringWithFormat:@"%@类型不匹配",key]));
//            }
//            @finally {
//                
//            }
            [self setSigleValue:value forKey:propertyName isCleanValue:isClean isDeep:NO];
        }
    }else {
        for (NSString * propertyName in propertyList) {
            id value = nil;
//            @try {
                value = [obj objValueForKye:propertyName];
//            }
//            @catch (NSException *exception) {
//                YYBLogLevel(LogWarning, ([NSString stringWithFormat:@"%@类型不匹配",propertyName]));
//
//            }
//            
//            @finally {
//                
//            }
//            
            [self setSigleValue:value forKey:propertyName isCleanValue:isClean isDeep:NO];
        }
    }
    return self;
}

- (void)setSigleValue:(id)value forKey:(NSString *)propertyName isCleanValue:(BOOL)isClean isDeep:(BOOL)isDeep {
    if ([[self propertyClassWithPropertyName:propertyName] isSubclassOfClass:[NSManagedObject class]]){
        return;
    }else if ([[self propertyClassWithPropertyName:propertyName] isSubclassOfClass:[NSSet class]]){
        //TODO:
        return;
    }else if ([[self propertyClassWithPropertyName:propertyName] isSubclassOfClass:[NSOrderedSet class]]){
        //TODO:
        return;
    }else if ([value isKindOfClass:[NSDictionary class]] && !isDeep) {
        return;
    } else if([value isKindOfClass:[NSArray class]]&& !isDeep){
        return;
    } else if (value == nil || ([value isKindOfClass:[NSNumber class]] && [value doubleValue] <= 0) || ([value isKindOfClass:[NSString class]] && [value length] <= 0)) {
        if (isClean) {
            //TODO:
            @try {
                if ([[self propertyClassWithPropertyName:propertyName] isSubclassOfClass:[NSObject class]])
                {
                    [self setValue:nil forKey:propertyName];
                }
                else
                {
                    [self setValue:@0 forKey:propertyName];
                }
            }
            @catch (NSException *exception) {
                
            }
            @finally {
//                NSString * string = [NSString stringWithFormat:@"%@ value is nil",propertyName];
//                YYBLogLevel(LogVerbose, string);
            }
//            [self setNilValueForKey:propertyName];
        }else {
            return;
        }
        //TODO:
    } else {
//        @try {
            [self setValue:value forKey:propertyName];
//        }
//        @catch (NSException *exception) {
//            NSString * log = [NSString stringWithFormat:@"%@类型%@不匹配",propertyName,[self propertyClassWithPropertyName:propertyName]];
//            YYBLog(log);
//        }
//        @finally {
//            
//        }
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    
}

- (instancetype) setDeepModelPropertyForObj:(NSObject *)obj isCleanValue:(BOOL)isClean {
    return [self setDeepModelPropertyForObj:obj avoidKeys:nil isCleanValue:isClean];
}

- (instancetype)setDeepModelPropertyForObj:(NSObject *)obj avoidKeys:(NSArray *)avoidKeys isCleanValue:(BOOL)isClean {
    NSArray * propertyList = [self propertysAvoidKeys:avoidKeys];
    for (NSString * propertyName in propertyList) {
        id value = nil;
//        @try {
            value = [obj objValueForKye:propertyName];
//        }
//        @catch (NSException *exception) {
//            YYBLogLevel(LogWarning, ([NSString stringWithFormat:@"%@类型不匹配",propertyName]));
//
//        }
//        @finally {
//            
//        }
        if ([value isKindOfClass:[NSDictionary class]]) {
            Class modelClass = [self propertyClassWithPropertyName:propertyName];
            if (modelClass && modelClass != [NSDictionary class] && modelClass != [NSArray class]) { // 如果存在这个类
                id model = [[modelClass alloc]init];
                value = [model setDeepModelPropertyForObj:value isCleanValue:isClean];
            }
        } else if([value isKindOfClass:[NSArray class]]){
            
            Class modelClass = [self propertyClassWithPropertyName:propertyName];
            if (modelClass == [NSSet class]) { // 过滤NSSet类型（暂时不处理）
                continue;
            }
            
            NSArray * values = (id)value;
            NSMutableArray * mulArray = [NSMutableArray arrayWithCapacity:values.count];
            [values enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    id model = [[modelClass alloc]init];
                    obj = [model setDeepModelPropertyForObj:obj isCleanValue:isClean];
                }
                [mulArray setObject:obj atIndexedSubscript:idx];
            }];
            value = mulArray;
        }
        [self setSigleValue:value forKey:propertyName isCleanValue:isClean isDeep:YES];
    }
    return self;
}

// 获取当前这个类的属性类型

- (NSString *)propertyClassStringNameWithPropertyName:(NSString *)propertyName {
    objc_property_t property = class_getProperty([self class], [propertyName UTF8String]);
    NSString * attribute = [NSString stringWithUTF8String:property_getAttributes(property)];
    NSRange range = [attribute rangeOfString:@"\""];
    if (range.length > 0) {
        attribute = [attribute substringFromIndex:range.location + range.length];
        range = [attribute rangeOfString:@"\""];
        attribute = [attribute substringToIndex:range.location];
        return attribute;
    }else {
        //Ti(int),Tq(NSInteger),Td(double,CGFloat),TB(枚举),TQ(NSUInteger)
        return nil;
    }
}
- (Class)propertyClassWithPropertyName:(NSString *)propertyName{
    NSString * className = [self propertyClassStringNameWithPropertyName:propertyName];
    if (className.length > 0) {
        Class modelClass = NSClassFromString(className);
        return modelClass;
    }else {
        return nil;
    }
}

@end

@implementation NSDictionary(SpecialKey)

- (id)valueForSpecialKey:(NSString *)key {
    if ([self valueForKey:key]) {
        return [self valueForKey:key];
    }else {
        return @"";
    }
}
@end


@implementation NSObject(ValueKey)

- (id)objValueForKye:(NSString *)key {
    id value = nil;
    if ([self isKindOfClass:[NSDictionary class]]) {
        value = [(NSDictionary *)self objectForKey:key];
    }else {
        objc_property_t var = class_getProperty([self class], key.UTF8String);
        if (var) {
            value = [self valueForKey:key];
        }
    }
    return value;
}

- (void)removeAllValues {
    [self setShallowModelPropertyForObj:[[self class] new] isCleanValue:YES reflexDictionary:nil];
}

@end
