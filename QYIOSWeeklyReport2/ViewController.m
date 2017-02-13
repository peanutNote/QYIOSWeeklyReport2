//
//  ViewController.m
//  QYIOSWeeklyReport2
//
//  Created by qianye on 16/7/19.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+QYImageName.h"
#import "ViewMaker.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *testImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *testImageView2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIImage *releaseImage = [UIImage imageNamed:@"chemanman_icon"];
    NSLog(@"%@", releaseImage);
    
    UIView *dslView = AllocA(UIView).with.postion(128, 300).size(120, 120).color([UIColor cyanColor]).intoView(self.view);
    NSLog(@"%@", dslView);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _testImageView1.image = [UIImage imageNamed:@"chemanman_icon"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _testImageView2.image = [UIImage imageNamed:@"chemanman_icon"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
