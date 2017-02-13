//
//  ViewMaker.h
//  QYDemoProject
//
//  Created by qianye on 17/2/10.
//  Copyright © 2017年 qianye. All rights reserved.
//

#import <UIKit/UIKit.h>

#define AllocA(aClass)    alloc_a([aClass class])

@interface ViewMaker : NSObject

@property (nonatomic, copy) Class viewClass;
@property (nonatomic, assign) CGPoint viewPostion;
@property (nonatomic, assign) CGSize viewSize;
@property (nonatomic, strong) UIColor *viewColor;
@property (nonatomic, copy) ViewMaker *(^postion)(CGFloat x, CGFloat y);
@property (nonatomic, copy) ViewMaker *(^size)(CGFloat width, CGFloat height);
@property (nonatomic, copy) ViewMaker *(^color)(UIColor *color);
@property (nonatomic, copy) UIView *(^intoView)(UIView *superView);

@end

@interface ViewClassHelper : NSObject

@property (nonatomic, strong) Class viewClass;
@property (nonatomic, readonly) ViewMaker *with;

@end

ViewClassHelper *alloc_a(Class aClass);

