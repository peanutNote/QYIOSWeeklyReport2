//
//  ViewMaker.m
//  QYDemoProject
//
//  Created by qianye on 17/2/10.
//  Copyright © 2017年 qianye. All rights reserved.
//

#import "ViewMaker.h"
#import <objc/runtime.h>

@implementation ViewMaker

- (instancetype)init {
    if (self = [super init]) {
        __weak typeof(self) weakSelf = self;
        _postion = ^ViewMaker *(CGFloat x, CGFloat y) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.viewPostion = CGPointMake(x, y);
            return strongSelf;
        };
        
        _size = ^ViewMaker *(CGFloat width, CGFloat height) {
            __strong typeof (weakSelf) strongSelf = weakSelf;
            strongSelf.viewSize = CGSizeMake(width, height);
            return strongSelf;
        };
        
        _color = ^ViewMaker *(UIColor *color) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.viewColor = color;
            return strongSelf;
        };
        
        _intoView = ^UIView *(UIView *superView) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            id obj = [[weakSelf.viewClass alloc] init];
            if ([obj isKindOfClass:[UIView class]]) {
                CGRect rect = CGRectMake(strongSelf.viewPostion.x, strongSelf.viewPostion.y, strongSelf.viewSize.width, strongSelf.viewSize.height);
                UIView *viewObj = obj;
                viewObj.frame = rect;
                viewObj.backgroundColor = strongSelf.viewColor;
                [superView addSubview:viewObj];
                return viewObj;
            }
            return nil;
        };
        
    }
    return self;
}

@end


@implementation ViewClassHelper

- (ViewMaker *)with {
    ViewMaker *maker = ViewMaker.new;
    maker.viewClass = self.viewClass;
    return maker;
}

@end

ViewClassHelper *alloc_a(Class aClass) {
    ViewClassHelper *helper = ViewClassHelper.new;
    helper.viewClass = aClass;
    return helper;
}
