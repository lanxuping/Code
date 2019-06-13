//
//  RuntimeViewController.m
//  Code
//
//  Created by 兰旭平 on 2019/6/10.
//  Copyright © 2019 兰旭平. All rights reserved.
//

#import "RuntimeViewController.h"
#import <objc/runtime.h>
/**
 属性 ： property （给ivar添加了setter和getter方法）
 实例变量 ： ivar
 isa指针 ： 任何对象都有isa指针，分类没有
 */
@interface testModel : NSObject
{
    NSString *__interfaceName;
}
@property (nonatomic, strong) NSString *interfaceFirstP;
- (void)testMethod;
+ (void)classmethod;
@end
@interface testModel ()
{
    NSString *__extersionName;
}
@property (nonatomic, strong) NSString *extersionFirstP;
@end
@implementation testModel
- (void)testMethod {
    NSLog(@"class testMethod");
}
+ (void)classmethod {
}
@end

@interface testModel (myTestModel)
//{ 分类中不能添加实例变量，
//    __categroyIvar; //Instance variables may not be placed in categories
//}
@property (nonatomic, strong) NSString *categroyP;
- (void)testMethod;
@end
@implementation testModel (myTestModel)
@dynamic categroyP; //分类中@dynamic只能解除警告，不会实现setter和getter方法。
- (NSString *)categroyP {
    return objc_getAssociatedObject(self, @selector(categroyP));
}
- (void)setCategroyP:(NSString *)categroyP {
    objc_setAssociatedObject(self, @selector(categroyP), categroyP, OBJC_ASSOCIATION_COPY);
}

- (void)testMethod {
    NSLog(@"categroy myTestModel testMethod");
}
@end


@interface testModel (two)
@end
@implementation testModel (two)
- (void)testMethod {
    NSLog(@"categroy two testMethod");  //主类和分类同时实现一个方法，分类会将该方法放到methodlist列表的最前面，用户调用的时候会直接调用分类的方法。多个分类同时实现同一个方法，最后一个加载到内存的分类会被用户调用。
}
@end

@interface RuntimeViewController ()
@end
@implementation RuntimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    testModel *model = [testModel new];
    model.categroyP = @"myCategroy value";
    [model testMethod];
    NSLog(@"%@",model.categroyP);
    [self getIvarList:[testModel class]];
    [self getPropertys:[testModel class]];
    [self getMethods:[testModel class]];
    NSLog(@"-------");
    [self getMethods:object_getClass([testModel class])];
    // Do any additional setup after loading the view.
}
- (void)getIvarList:(Class)class {
    NSLog(@"%@ 包含的ivars",class);
    unsigned int count;
    Ivar *ivars = class_copyIvarList(class, &count);
    for (int i = 0; i < count; i ++) {
        Ivar ivar = ivars[i];
        const char *cname = ivar_getName(ivar);
        NSString *name = [NSString stringWithUTF8String:cname];
        NSLog(@"%@",name);
    }
    free(ivars);
}
- (void)getPropertys:(Class)class {
    NSLog(@"%@ 包含的propertys: ",class);
    unsigned int count;
    objc_property_t *propertys = class_copyPropertyList(class, &count);
    for (int i = 0; i < count; i ++) {
        objc_property_t property = propertys[i];
        const char *cname = property_getName(property);
        NSString *name = [NSString stringWithUTF8String:cname];
        NSLog(@"%@",name);
    }
    free(propertys);
}
- (void)getMethods:(Class)cls {
    NSLog(@"%@ 包含的methods: ",cls);
    unsigned int count ;
    Method *methods = class_copyMethodList(cls, &count);
    for (int i = 0; i < count; i ++) {
        Method method = methods[i];
        SEL sel = method_getName(method);
        NSString *name = NSStringFromSelector(sel);
        NSLog(@"%@",name);
    }
    free(methods);
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
