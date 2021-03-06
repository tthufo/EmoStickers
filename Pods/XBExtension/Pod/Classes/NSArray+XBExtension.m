//
//  NSArray+XBExtension.m
//  Pods
//
//  Created by Binh Nguyen Xuan on 5/19/15.
//
//

#import "XBExtension.h"

@implementation NSArray (XBExtension)

+ (NSMutableArray *)arrayWithContentsOfPlist:(NSString *)plistname
{
    NSString *path = [[NSBundle mainBundle] pathForResource:plistname ofType:@"plist"];
    return [[NSArray arrayWithContentsOfFile:path] deepMutableCopy];
}

+ (NSMutableArray *)arrayWithContentsOfPlist:(NSString *)plistname bundleName:(NSString *)name
{
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:name ofType:@"bundle"]];
    NSString *path = [bundle pathForResource:plistname ofType:@"plist"];
    return [[NSArray arrayWithContentsOfFile:path] deepMutableCopy];
}

- (NSArray *)arrayOrderedByString:(NSString *)orderField accending:(BOOL)accending
{
    return [self sortedArrayUsingComparator:^NSComparisonResult(id  __nonnull obj1, id  __nonnull obj2) {
        NSString *s1 = [obj1 objectForPath:orderField];
        NSString *s2 = [obj2 objectForPath:orderField];
        NSComparisonResult result = [s1 compare:s2];
        if (accending)
        {
            return result;
        }
        else
        {
            return - result;
        }
    }];
}

- (NSArray *)arrayOrderedByNumber:(NSString *)orderField accending:(BOOL)accending
{
    return [self sortedArrayUsingComparator:^NSComparisonResult(id  __nonnull obj1, id  __nonnull obj2) {
        float f1 = [[obj1 objectForPath:orderField] floatValue];
        float f2 = [[obj2 objectForPath:orderField] floatValue];
        NSComparisonResult result;
        if (f1 > f2)
        {
            result = NSOrderedDescending;
        }
        else if (f1 < f2)
        {
            result = NSOrderedAscending;
        }
        else
        {
            result = NSOrderedSame;
        }
        if (accending)
        {
            return result;
        }
        else
        {
            return - result;
        }
    }];
}

@end
