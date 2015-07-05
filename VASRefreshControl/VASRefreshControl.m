//
//  VASRefreshControl.m
//
//  Created by Igor Vasilenko on 03/07/15.
//  Copyright (c) 2015 Igor Vasilenko. All rights reserved.
//

#import "VASRefreshControl.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

static CGFloat const kDefaultDistance = 70.f;

@interface VASRefreshControl()

@property (nonatomic, readwrite, getter=isRefreshing) BOOL refreshing;
@property (nonatomic, assign) VASRefreshControlLoaderStyle loaderStyle;
@property (nonatomic, strong) VASRefreshControlCallbackBlock callbackBlock;

@property (nonatomic, strong) UIImageView *loaderImageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) UIEdgeInsets contentInset;

@property (nonatomic, strong) RACSubject *successSubject;
@property (nonatomic, strong) RACSignal *successSignal;

@end

@implementation VASRefreshControl

#pragma mark - Init

- (instancetype)initWithLoaderStyle:(VASRefreshControlLoaderStyle)loaderStyle
                      forScrollView:(UIScrollView *)scrollView
{
    if (self = [super init])
    {
        [self.loaderImageView.layer removeAllAnimations];
        
        _loaderStyle = loaderStyle;
        _scrollView = scrollView;
        _contentInset = scrollView.contentInset;
        
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
        default:
            loaderImage = [UIImage imageNamed:@"loader_small_blue"];
            break;
    }
    
    self.loaderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-loaderImage.size.width)/2, (kDefaultDistance-loaderImage.size.height)/2, loaderImage.size.width, loaderImage.size.height)];
    self.loaderImageView.image = loaderImage;
    
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
                         
                         if (self.callbackBlock) {
                             self.callbackBlock();
                         }
                         if (self.rac_command) {
                             [[self.rac_command execute:nil] subscribeNext:^(id x) {
                                 [self.successSubject sendNext:@(YES)];
                             } completed:^{
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
                self.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.contentOffset.y);
                
                CGFloat scale = MIN((-self.scrollView.contentOffset.y + (100 - kDefaultDistance))/100, 1);
                self.loaderImageView.transform = CGAffineTransformMakeScale(scale, scale);
                
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
    CABasicAnimation *rotationLoaderImageView = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationLoaderImageView.toValue = @(M_PI * 2.f);
    rotationLoaderImageView.duration = 1.f;
    rotationLoaderImageView.cumulative = YES;
    rotationLoaderImageView.repeatCount = HUGE_VAL;
    [self.loaderImageView.layer addAnimation:rotationLoaderImageView forKey:@"rotation"];
}

- (void)endAnimating
{
    [self.loaderImageView.layer removeAllAnimations];
}

@end
