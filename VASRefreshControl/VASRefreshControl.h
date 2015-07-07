//
//  VASRefreshControl.h
//
//  Created by Igor Vasilenko on 03/07/15.
//  Copyright (c) 2015 Igor Vasilenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RACCommand;
@class RACSignal;

typedef NS_ENUM(NSUInteger, VASRefreshControlLoaderStyle) {
    VASRefreshControlLoaderStyleBlue = 1, // default
    VASRefreshControlLoaderStyleWhite = 2
};

typedef NS_ENUM(NSUInteger, VASRefreshControlState) {
    VASRefreshControlStateNormal = 1,
    VASRefreshControlStatePulling = 2,
    VASRefreshControlStateRefreshing = 3
};

typedef void(^VASRefreshControlCallbackBlock)();

@interface VASRefreshControl : UIView

@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;
@property (nonatomic, readonly) VASRefreshControlState state;
@property (nonatomic, readonly) RACSignal *controlStateSignal;

@property (nonatomic, strong) RACCommand *rac_command;

/*!
 Base initialization method VASRefreshControl
 @param loaderStyle Can be nil. Use VASRefreshControlLoaderStyle from NS_ENUM list. Default is VASRefreshControlLoaderStyleBlue.
 @param scrollView UIScrollView, where you want showing YTSRefreshControl.
*/
- (instancetype)initWithLoaderStyle:(VASRefreshControlLoaderStyle)loaderStyle
                      forScrollView:(UIScrollView *)scrollView;

+ (instancetype)refreshControlWithLoaderStyle:(VASRefreshControlLoaderStyle)loaderStyle
                                forScrollView:(UIScrollView *)scrollView;

- (void)setCallbackBlock:(VASRefreshControlCallbackBlock)callbackBlock;
- (void)startRefreshing;
- (void)endRefreshing;

@end
