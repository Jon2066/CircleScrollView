//
//  CircleScrollView.m
//  Dandanjia
//
//  Created by Jonathan on 16/9/8.
//  Copyright © 2016年 xiandanjia.com. All rights reserved.
//

#import "JNCircleScrollView.h"



#define CSMiddle @"CS-Middle"
#define CSLeft   @"CS-Left"
#define CSRight  @"CS-Right"

static void *kJNCircleScrollViewContentOffsetChange = &kJNCircleScrollViewContentOffsetChange;


@interface JNCircleScrollView ()<UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) NSMutableDictionary *itemViews;

@property (assign, nonatomic) NSInteger pageCount;

@property (assign, nonatomic) NSInteger currentPage;

@property (weak, nonatomic) NSTimer *timer;

@end

@implementation JNCircleScrollView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self  = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)dealloc
{
    [self.scrollView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) context:kJNCircleScrollViewContentOffsetChange];
}

- (void)setup
{
    _autoScrollInterval = 5.0f;
    _autoScroll = YES;

    self.itemViews = [[NSMutableDictionary alloc] init];
    self.currentPage = 0;
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    [self addSubview:self.scrollView];
    [self autoSizeScrollView];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    
    //abserver to get scrollView'contentOffset change
    [self.scrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:kJNCircleScrollViewContentOffsetChange];

    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.numberOfPages = 1;
    self.pageControl.currentPage = self.currentPage;
    self.pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
//    self.pageControl.hidden = YES;
    [self addSubview:self.pageControl];
    
    [self autoSizePageControl];
}

- (void)autoSizeScrollView
{
    [self.scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    //创建约束
    NSLayoutConstraint *leadingCt = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    
    NSLayoutConstraint *trailingCt = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    
    NSLayoutConstraint *topCt = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    
    NSLayoutConstraint *bottomCt = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    
    [self addConstraints:@[leadingCt, trailingCt, topCt, bottomCt]];
    
    [self updateConstraintsIfNeeded];
}

- (void)autoSizePageControl
{
    [self.pageControl setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSLayoutConstraint *trailingCt = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.pageControl attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:5.0];
    
    NSLayoutConstraint *bottomCt = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.pageControl attribute:NSLayoutAttributeBottom multiplier:1.0 constant:5.0];

    NSLayoutConstraint *heightCt = [NSLayoutConstraint constraintWithItem:self.pageControl attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:10.0f];
    
    [self addConstraints:@[trailingCt, bottomCt, heightCt]];
    
    [self updateConstraintsIfNeeded];
}

- (CGPoint)centerPoint
{
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    return CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
}

- (CGSize)viewSize
{
    [self setNeedsLayout];
    [self layoutIfNeeded];
    return CGSizeMake(self.bounds.size.width, self.bounds.size.height);
}

#pragma mark - method -

- (void)reloadData
{
    [self stopAutoScroll];
    self.pageCount = [self.dataSource numberOfPagesInCircleScrollView];
    self.currentPage = 0;
    self.pageControl.numberOfPages = self.pageCount;
    self.pageControl.currentPage = self.currentPage;
    [self updateConstraintsIfNeeded];
    if (self.pageCount == 1) {
        self.scrollView.contentSize  = [self viewSize];
        UIView *view = [self.dataSource circleScrollViewShouldLoadView:self.itemViews[CSMiddle] atPage:0];
        UIView *mView = self.itemViews[CSMiddle];
        if (view != mView) {
            if (mView) {
                [mView removeFromSuperview];
            }
            view.center = [self centerPoint];
           
            [self.scrollView addSubview:view];
            [self.itemViews setObject:view forKey:CSMiddle];
        }

    }
    else{
        self.scrollView.contentSize = CGSizeMake([self viewSize].width * 3, [self viewSize].height);
        self.scrollView.contentOffset = CGPointMake([self viewSize].width, 0);
        [self reloadLeftViewWithPage:self.pageCount - 1];
        [self reloadMiddleViewWithPage:0];
        [self reloadRightViewWithPaeg:1];
    }
    if (self.autoScroll) {
        [self startAutoScroll];
    }
}

- (void)reloadLeftViewWithPage:(NSInteger)pageNumber
{
    UIView *lView = self.itemViews[CSLeft];
    UIView *leftView = [self.dataSource circleScrollViewShouldLoadView:lView atPage:pageNumber]; //左边加载最后一个  left load the last object
    if(leftView != lView){
        if (lView) {
            [lView removeFromSuperview];
        }
        leftView.center = [self centerPoint];
        [self.scrollView addSubview:leftView];
        [self.itemViews setObject:leftView forKey:CSLeft];
    }
}

- (void)reloadMiddleViewWithPage:(NSInteger)pageNumber
{
    UIView *mView = self.itemViews[CSMiddle];
    UIView *centerView = [self.dataSource circleScrollViewShouldLoadView:mView atPage:pageNumber];
    if (centerView != mView) {
        if (mView) {
            [mView removeFromSuperview];
        }
        centerView.center = CGPointMake([self centerPoint].x + [self viewSize].width, [self centerPoint].y);
        [self.scrollView addSubview:centerView];
        [self.itemViews setObject:centerView forKey:CSMiddle];
    }
}

- (void)reloadRightViewWithPaeg:(NSInteger)pageNumber
{
    UIView *rView = self.itemViews[CSRight];
    UIView *rightView = [self.dataSource circleScrollViewShouldLoadView:rView atPage:pageNumber];
    if(rightView != rView){
        if (rView) {
            [rView removeFromSuperview];
        }
        rightView.center = CGPointMake([self centerPoint].x + [self viewSize].width * 2, [self centerPoint].y);
        [self.scrollView addSubview:rightView];
        [self.itemViews setObject:rightView forKey:CSRight];
    }
}

#pragma mark - scrollView delegate -

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.autoScroll) {
        [self stopAutoScroll];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{

//    [self handleContentOffsetChange];
    if (self.autoScroll) {
        [self startAutoScroll];
    }

}

#pragma mark - timer auto scroll -

- (void)setAutoScroll:(BOOL)autoScroll
{
    _autoScroll = autoScroll;
    if (!_autoScroll) {
        [self stopAutoScroll];
    }
    else{
        [self startAutoScroll];
    }
}

- (void)setAutoScrollInterval:(NSTimeInterval)autoScrollInterval
{
    if (_autoScrollInterval != autoScrollInterval && self.autoScroll) {
        _autoScrollInterval = autoScrollInterval;
        [self stopAutoScroll];
        [self startAutoScroll];
    }
    else{
        _autoScrollInterval = autoScrollInterval;
    }
}

- (void)startAutoScroll
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.autoScrollInterval target:self selector:@selector(autoScrollToNextPage) userInfo:nil repeats:YES];
}

- (void)stopAutoScroll
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}


#pragma mark - observe -
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kJNCircleScrollViewContentOffsetChange) {
        if (object == self.scrollView && [keyPath isEqualToString:NSStringFromSelector(@selector(contentOffset))]) {
//            CGPoint oldContentOffset = [[change objectForKey:NSKeyValueChangeOldKey] CGPointValue];
//            CGPoint newContentOffset = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue];
            [self handleContentOffsetChange];
        }
    }
}

#pragma mark - scroll handle -

- (void)autoScrollToNextPage
{
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x + [self viewSize].width, self.scrollView.contentOffset.y) animated:YES];
}

- (void)handleContentOffsetChange
{
    //右滑
    if (self.scrollView.contentOffset.x <= 0.0) {
        UIView *lView = self.itemViews[CSLeft];
        if (!lView) {
            return;
        }
        UIView *mView = self.itemViews[CSMiddle];
        UIView *rView = self.itemViews[CSRight];

        //重置offset到中间位置
        self.scrollView.contentOffset = CGPointMake([self viewSize].width, 0);
        self.currentPage  = (self.currentPage - 1 > 0)?self.currentPage - 1 : self.pageCount - 1;
        
        CGPoint lCenter = lView.center;
        lView.center = mView.center;
        mView.center = rView.center;
        rView.center  = lCenter;
        
        [self.itemViews setObject:mView forKey:CSRight];
        [self.itemViews setObject:lView forKey:CSMiddle];
        [self.itemViews setObject:rView forKey:CSLeft];

        self.pageControl.currentPage = self.currentPage;
        [self reloadLeftViewWithPage:(self.currentPage - 1 > 0)?self.currentPage - 1 : self.pageCount - 1];
    }
    else if(self.scrollView.contentOffset.x >= [self viewSize].width * 2){ //左滑

        UIView *lView = self.itemViews[CSLeft];
        if (!lView) {
            return;
        }
        UIView *mView = self.itemViews[CSMiddle];
        UIView *rView = self.itemViews[CSRight];

        
        self.scrollView.contentOffset = CGPointMake([self viewSize].width, 0);
        self.currentPage  = (self.currentPage + 1 <= self.pageCount - 1)?self.currentPage + 1 : 0;
        
        CGPoint rCenter = rView.center;
        rView.center = mView.center;
        mView.center = lView.center;
        lView.center  = rCenter;
        
        [self.itemViews setObject:mView forKey:CSLeft];
        [self.itemViews setObject:rView forKey:CSMiddle];
        [self.itemViews setObject:lView forKey:CSRight];
        
        self.pageControl.currentPage = self.currentPage;
        [self reloadRightViewWithPaeg:(self.currentPage + 1 <= self.pageCount - 1)?self.currentPage + 1 : 0];
        
    }
}
@end
