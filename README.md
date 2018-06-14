/**
 *  获取所有属性列表
 *
 *  @param obj 当前model
 *
 *  @return 属性数组
 */
- (NSArray *)propertys;
/**
 *  获取所有属性列表
 *
 *  @param obj 当前model
 *  @param avoidKeys 要过滤掉的属性key
 *
 *  @return 属性数组
 */
- (NSArray *)propertysAvoidKeys:(NSArray *)avoidKeys;

//+ (NSArray *)valuesFromObj:(id)obj;
//
//+ (NSArray *)valuesFromObj:(id)obj avoidKeys:(NSArray *)avoidKeys;

/**
 *  model 转 NSDcitionary
 *
 *  @param obj model对象
 *
 *  @return model所有属性的字典属性（nil值过滤）
 */
- (NSDictionary *)valuesAndKeysDictionay;
/**
 *  model 转 NSDictionary 避免某些特定属性
 *
 *  @param obj       model对象
 *  @param avoidKeys 要过滤掉的属性key
 *
 *  @return 过滤掉avoidKeys的字典
 */
- (NSDictionary *)valuesAndKeysDictionayAvoidKeys:(NSArray *)avoidKeys;
/**
 *  model 转 NSDictionay  指定的某些属性
 *
 *  @param obj         model对象
 *  @param containKeys 指定属性
 *
 *  @return 指定containKeys的字典
 */
- (NSDictionary *)valuesAndKeysDictionayContainKeys:(NSArray *)containKeys;
@end

@interface NSObject(Dict)
/**
 *  打印出所有属性
 *
 *  @param dict 要转 model的NSDictionary
 */
+ (void)dictChangeToModelPropertys:(NSDictionary *)dict;
/**
 *  浅赋值
 *  @param isClean如果传入数据为空，则删除本地数据（基础数据类型）
 *  @param  reflex 映射字典，可以是当前对象的key，value是传入obj的映射key
 *  @param dict 要转model的字典
 */
- (instancetype) setShallowModelPropertyForObj:(NSObject *)obj isCleanValue:(BOOL)isClean reflexDictionary:(NSDictionary *)reflex;


- (instancetype) setShallowModelPropertyForObj:(NSObject *)obj avoidKeys:(NSArray *)avoidKeys isCleanValue:(BOOL)isClean reflexDictionary:(NSDictionary *)reflex;


- (instancetype) setShallowModelPropertyForObj:(NSObject *)obj containKeys:(NSArray *)containKeys isCleanValue:(BOOL)isClean reflexDictionary:(NSDictionary *)reflex;

/**
 *  深度赋值（包括数组，字典等嵌套类型,这里 NSManagerObject未做处理）
 *  @param isClean如果传入数据为空，则删除本地数据
 *  @param dict 要转model的字典
 */
- (instancetype) setDeepModelPropertyForObj:(NSObject *)obj isCleanValue:(BOOL)isClean;
- (instancetype) setDeepModelPropertyForObj:(NSObject *)obj avoidKeys:(NSArray *)avoidKeys isCleanValue:(BOOL)isClean;
