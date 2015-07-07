//
//  VASRefreshControl.m
//
//  Created by Igor Vasilenko on 03/07/15.
//  Copyright (c) 2015 Igor Vasilenko. All rights reserved.
//

#import "VASRefreshControl.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

static CGFloat const kDefaultDistance = 70.f;
static NSString *const kRotateLoaderImageViewAnimationKey = @"rotation";
static NSString *const kCAAnimationTransformRotation = @"transform.rotation.z";

@interface VASRefreshControl()

@property (nonatomic, readwrite, getter=isRefreshing) BOOL refreshing;

@property (nonatomic, assign) VASRefreshControlLoaderStyle loaderStyle;
@property (nonatomic, readwrite) VASRefreshControlState state;

@property (nonatomic, strong) VASRefreshControlCallbackBlock callbackBlock;

@property (nonatomic, strong) UIImageView *loaderImageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) UIEdgeInsets contentInset;

@property (nonatomic, strong) RACSubject *successSubject;
@property (nonatomic, strong) RACSignal *successSignal;
@property (nonatomic, readwrite) RACSignal *controlStateSignal;
@property (nonatomic, strong) RACSubject *controlStateSubject;

@end

@implementation VASRefreshControl

#pragma mark - Init

+ (instancetype)refreshControlWithLoaderStyle:(VASRefreshControlLoaderStyle)loaderStyle
                                forScrollView:(UIScrollView *)scrollView
{
    return [[self alloc] initWithLoaderStyle:loaderStyle
                               forScrollView:scrollView];
}

- (instancetype)initWithLoaderStyle:(VASRefreshControlLoaderStyle)loaderStyle
                      forScrollView:(UIScrollView *)scrollView
{
    if (self = [super init])
    {
        [self.loaderImageView.layer removeAllAnimations];
        
        _loaderStyle = loaderStyle;
        _scrollView = scrollView;
        _contentInset = scrollView.contentInset;
        
        _state = VASRefreshControlStateNormal;
        [self.controlStateSubject sendNext:@(VASRefreshControlStateNormal)];
        
        [self setupLoaderView];
        [self setupActionsBind];
        [self observeOfScrollView];
    }
    return self;
}

#pragma mark - Setup loader

- (void)setupLoaderView
{
    self.layer.masksToBounds = YES;
    
    UIImage *loaderImage;
    
    switch (self.loaderStyle)
    {
        case VASRefreshControlLoaderStyleBlue:
            loaderImage = [UIImage imageNamed:@"loader_small_blue"];
            break;
        case VASRefreshControlLoaderStyleWhite:
            loaderImage = [UIImage imageNamed:@"loader_small_white"];
            break;
    }
    
    self.loaderImageView = [[UIImageView alloc] initWithImage:loaderImage];
    [self.loaderImageView setFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - loaderImage.size.width)/2,
                                              (kDefaultDistance - loaderImage.size.height)/2,
                                              loaderImage.size.width,
                                              loaderImage.size.height)];
    [self addSubview:self.loaderImageView];
    
    [self.scrollView addSubview:self];
}

#pragma mark - Actions

- (void)setupActionsBind
{
    @weakify(self);
    [self.successSignal subscribeNext:^(NSNumber *success) {
        @strongify(self);
        
        if (success.boolValue) {
            [self endRefreshing];
        }
    }];
}

- (void)startRefreshing
{
    [self startAnimating];
    
    @weakify(self);
    [UIView animateWithDuration:0.6f
                          delay:0.f
         usingSpringWithDamping:0.6f
          initialSpringVelocity:0.2f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         @strongify(self);
                         [self.scrollView setContentOffset:CGPointMake(0.f, - kDefaultDistance) animated:NO];
                         
                         UIEdgeInsets inset = self.contentInset;
                         inset.top += kDefaultDistance;
                         self.scrollView.contentInset = inset;
                         
                     } completion:^(BOOL finished) {
                         
                         self.refreshing = YES;
                         self.state = VASRefreshControlStateRefreshing;
                         [self.controlStateSubject sendNext:@(VASRefreshControlStateRefreshing)];
                         
                         if (self.callbackBlock) {
                             self.callbackBlock();
                         }
                         if (self.rac_command) {
                             [[self.rac_command execute:nil] subscribeCompleted:^{
                                 [self.successSubject sendNext:@(YES)];
                             }];
                         }
                     }];
}

- (void)endRefreshing
{
    [self endAnimating];
    
    @weakify(self);
    [UIView animateWithDuration:0.8f
                          delay:0.f
         usingSpringWithDamping:0.4f
          initialSpringVelocity:0.8f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         @strongify(self);
                         
                         self.scrollView.contentInset = self.contentInset;
                     } completion:^(BOOL finished) {
                         
                         self.refreshing = NO;
                         self.state = VASRefreshControlStateNormal;
                         [self.controlStateSubject sendNext:@(VASRefreshControlStateNormal)];
                         
                         self.frame = CGRectZero;
                     }];
}

#pragma mark - Properties

- (RACSignal *)successSignal
{
    if (!self.successSubject) {
        self.successSubject = [RACSubject new];
    }
    return self.successSubject;
}

- (RACSignal *)controlStateSignal
{
    if (_controlStateSubject) {
        _controlStateSubject = [RACSubject new];
    }
    return _controlStateSubject;
}

- (void)setCallbackBlock:(VASRefreshControlCallbackBlock)callbackBlock
{
    _callbackBlock = callbackBlock;
}

#pragma mark - Private methods

- (void)observeOfScrollView
{
    @weakify(self);
    [RACObserve(self.scrollView, contentOffset) subscribeNext:^(NSValue *contentOffset) {
        @strongify(self);
        
        if (!self.refreshing)
        {
            if (self.scrollView.contentOffset.y < 0)
            {
                self.state = VASRefreshControlStatePulling;
                [self.controlStateSubject sendNext:@(VASRefreshControlStatePulling)];
                
                self.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.contentOffset.y);
                
                CGFloat pullProgress = MIN((-self.scrollView.contentOffset.y + (100 - kDefaultDistance))/100, 1);
                self.loaderImageView.alpha = pullProgress;
                self.loaderImageView.layer.transform = CATransform3DMakeRotation(DegreesToRadians(180 + (180 * pullProgress)), 0.0, 0.0, 1.f);

                
                if(!self.scrollView.dragging && self.scrollView.decelerating && self.scrollView.contentOffset.y <= (-kDefaultDistance + 10))
                {
                    [self startRefreshing];
                }
            }
        }
    }];
}

- (void)startAnimating
{
    CABasicAnimation *rotationLoaderImageView = [CABasicAnimation animationWithKeyPath:kCAAnimationTransformRotation];
    rotationLoaderImageView.toValue = @(M_PI * 2.f);
    rotationLoaderImageView.duration = 1.f;
    rotationLoaderImageView.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotationLoaderImageView.cumulative = YES;
    rotationLoaderImageView.repeatCount = HUGE_VAL;
    rotationLoaderImageView.fillMode = kCAFillModeForwards;
    rotationLoaderImageView.autoreverses = NO;
    
    [self.loaderImageView.layer addAnimation:rotationLoaderImageView forKey:kRotateLoaderImageViewAnimationKey];
}

- (void)endAnimating
{
    [self.loaderImageView.layer removeAnimationForKey:kRotateLoaderImageViewAnimationKey];
}

#pragma mark - Helpers

CGFloat DegreesToRadians(CGFloat degrees)
{
    return degrees * M_PI / 180;
}

@end
