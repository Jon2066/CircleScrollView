//
//  ViewController.m
//  CircleScrollView
//
//  Created by Jonathan on 16/9/9.
//  Copyright © 2016年 Jonathan. All rights reserved.
//

#import "ViewController.h"
#import "JNCircleScrollView.h"
@interface ViewController ()<CircleScrollViewDataSouce>
@property (weak, nonatomic) IBOutlet JNCircleScrollView *circleView;


@property (strong, nonatomic) NSArray *items;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.items = @[@"page0", @"page1", @"page2", @"page3", @"page4"];
    self.circleView.dataSource = self;
    
//    [self resetPageControl];
    
//    self.circleView.autoScroll = NO;
//    self.circleView.autoScroll = YES;
//    self.circleView.autoScrollInterval = 2.0f;
    
    [self.circleView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)resetPageControl
{
//    self.circleView.pageControl.hidden  = YES;
    [self.circleView.pageControl removeConstraints:self.circleView.pageControl.constraints];
    [self.circleView.pageControl setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *trailingCt = [NSLayoutConstraint constraintWithItem:self.circleView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.circleView.pageControl attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:8.0];
    NSLayoutConstraint *bottomCt = [NSLayoutConstraint constraintWithItem:self.circleView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.circleView.pageControl attribute:NSLayoutAttributeBottom multiplier:1.0 constant:5.0];
    
    NSLayoutConstraint *heightCt = [NSLayoutConstraint constraintWithItem:self.circleView.pageControl attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:10.0f];

    [self.circleView addConstraints:@[trailingCt, bottomCt, heightCt]];
    
    [self.circleView updateConstraintsIfNeeded];
    
//    self.circleView.pageControl.currentPageIndicatorTintColor = [UIColor redColor];
//    self.circleView.pageControl.pageIndicatorTintColor = [UIColor blueColor];
}

- (NSInteger)numberOfPagesInCircleScrollView
{
    return self.items.count;
}

- (UIView *)circleScrollViewShouldLoadView:(UIView *)view atPage:(NSInteger)pageNumber
{
    if (view) {
        ((UILabel *)view).text = self.items[pageNumber];
        return view;
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 128)];
    CGFloat red   = (arc4random() % 256)/255.0;
    CGFloat green = (arc4random() % 256)/255.0;
    CGFloat blue  = (arc4random() % 256)/255.0;
    CGFloat alpha = 1.0f;
    label.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    label.text = self.items[pageNumber];
    return label;
}

@end
