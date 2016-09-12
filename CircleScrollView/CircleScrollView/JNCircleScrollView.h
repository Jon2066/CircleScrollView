//
//  CircleScrollView.h
//  Jonathan
//
//  Created by Jonathan on 16/9/8.
//  Copyright © 2016年 Jonathan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JNCircleScrollView;
@protocol CircleScrollViewDataSouce <NSObject>

- (UIView *)circleScrollViewShouldLoadView:(UIView *)view atPage:(NSInteger)pageNumber;
- (NSInteger)numberOfPagesInCircleScrollView;
@end

@interface JNCircleScrollView : UIView

@property (assign, nonatomic) id<CircleScrollViewDataSouce> dataSource;

@property (strong, nonatomic) UIPageControl *pageControl;

@property (assign, nonatomic) BOOL autoScroll;

@property (assign, nonatomic) NSTimeInterval autoScrollInterval; 

- (void)reloadData;
@end
