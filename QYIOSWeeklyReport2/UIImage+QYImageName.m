//
//  UIImage+QYImageName.m
//  QYDemoProject
//
//  Created by qianye on 17/2/13.
//  Copyright © 2017年 qianye. All rights reserved.
//

#import "UIImage+QYImageName.h"

@interface NSMutableDictionary (QYImageNameDictionary)

- (void)weak_setObject:(id)anObject forKey:(NSString *)aKey;

- (void)weak_setObjectWithDictionary:(NSDictionary *)dic;

- (id)weak_getObjectForKey:(NSString *)key;

@end

typedef id(^WeakReference)(void);

@implementation NSMutableDictionary (QYImageNameDictionary)

- (void)weak_setObject:(id)anObject forKey:(NSString *)aKey {
    [self setObject:makeWeakReference(anObject) forKey:aKey];
}

- (void)weak_setObjectWithDictionary:(NSDictionary *)dic {
    for (NSString *key in dic.allKeys) {
        [self setObject:makeWeakReference(dic[key]) forKey:key];
    }
}

- (id)weak_getObjectForKey:(NSString *)key {
    return weakReferenceNonretainedObjectValue(self[key]);
}

WeakReference makeWeakReference(id object) {
    __weak id weakref = object;
    return ^{
        return weakref;
    };
}

id weakReferenceNonretainedObjectValue(WeakReference ref) {
    return ref ? ref() : nil;
}

@end



@implementation UIImage (QYImageName)

+ (NSMutableDictionary *)imageBuff {
    static NSMutableDictionary *_imageBuff;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _imageBuff = [[NSMutableDictionary alloc] init];
    });
    return _imageBuff;
}

+ (instancetype)imageNamed:(NSString *)imageName {
    if (!imageName) {
        return nil;
    }
    UIImage *image = [self.imageBuff weak_getObjectForKey:imageName];
    if (image) {
        return image;
    }
    
    NSString *res = imageName.stringByDeletingPathExtension;
    NSString *ext = imageName.pathExtension;
    NSString *path = nil;
    CGFloat scale = 1;
    
    NSArray *exts = ext.length > 0 ? @[ext] : @[@"", @"png", @"jpeg", @"jpg", @"gif", @"webp", @"apng"];
    NSArray *scales = self.preferredScales;
    for (int s = 0; s < scales.count; s++) {
        scale = ((NSNumber *)scales[s]).floatValue;
        NSString *scaledName = res;
        if (fabs(scale - 1) <= __FLT_EPSILON__ || res.length == 0 || [res hasSuffix:@"/"]) {
            scaledName = res;
        } else {
            scaledName = [res stringByAppendingFormat:@"@%@x", @(scale)];
        }
        for (NSString *e in exts) {
            path = [[NSBundle mainBundle] pathForResource:scaledName ofType:e];
            if (path) break;
        }
        if (path) break;
    }
    if (path.length == 0) return nil;
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data.length == 0) return nil;
    UIImage *storeImage = [[UIImage alloc] initWithData:data scale:scale];
    [self.imageBuff weak_setObject:storeImage forKey:imageName];
    return storeImage;
}

+ (NSArray *)preferredScales {
    static NSArray *scales;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat screenScale = [UIScreen mainScreen].scale;
        if (screenScale <= 1) {
            scales = @[@1,@2,@3];
        } else if (screenScale <= 2) {
            scales = @[@2,@3,@1];
        } else {
            scales = @[@3,@2,@1];
        }
    });
    return scales;
}

@end
