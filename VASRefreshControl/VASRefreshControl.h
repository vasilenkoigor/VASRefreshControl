//
//  VASRefreshControl.h
//
//  Created by Igor Vasilenko on 03/07/15.
//  Copyright (c) 2015 Igor Vasilenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RACCommand;

typedef NS_ENUM(NSUInteger, YTSRefreshControlLoaderStyle) {
    YTSRefreshControlLoaderStyleBlue, // default
    YTSRefreshControlLoaderStyleWhite
};

typedef void(^YTSRefreshControlCallbackBlock)();

@interface VASRefreshControl : UIView

@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

@property (nonatomic, strong) RACCommand *rac_command;

/*!
 Base initialization method YTSRefreshControl
 @param loaderStyle Can be nil. Use YTSRefreshControlLoaderStyle from NS_ENUM list. Default is YTSRefreshControlLoaderStyleBlue.
 @param scrollView UIScrollView, where you want showing YTSRefreshControl.
*/
- (instancetype)initWithLoaderStyle:(YTSRefreshControlLoaderStyle)loaderStyle
                      forScrollView:(UIScrollView *)scrollView;

- (void)setCallbackBlock:(YTSRefreshControlCallbackBlock)callbackBlock;
- (void)startRefreshing;
- (void)endRefreshing;

@end
