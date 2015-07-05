//
//  VASRefreshControl.h
//
//  Created by Igor Vasilenko on 03/07/15.
//  Copyright (c) 2015 Igor Vasilenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RACCommand;

typedef NS_ENUM(NSUInteger, VASRefreshControlLoaderStyle) {
    VASRefreshControlLoaderStyleBlue, // default
    VASRefreshControlLoaderStyleWhite
};

typedef void(^VASRefreshControlCallbackBlock)();

@interface VASRefreshControl : UIView

@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

@property (nonatomic, strong) RACCommand *rac_command;

/*!
 Base initialization method VASRefreshControl
 @param loaderStyle Can be nil. Use VASRefreshControlLoaderStyle from NS_ENUM list. Default is VASRefreshControlLoaderStyleBlue.
 @param scrollView UIScrollView, where you want showing YTSRefreshControl.
*/
- (instancetype)initWithLoaderStyle:(VASRefreshControlLoaderStyle)loaderStyle
                      forScrollView:(UIScrollView *)scrollView;

- (void)setCallbackBlock:(VASRefreshControlCallbackBlock)callbackBlock;
- (void)startRefreshing;
- (void)endRefreshing;

@end
