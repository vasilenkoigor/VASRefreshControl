//
//  ViewController.m
//  VASRefreshControl-Example
//
//  Created by Igor Vasilenko on 05/07/15.
//  Copyright (c) 2015 Igor Vasilenko. All rights reserved.
//

#import "ViewController.h"

#import "VASRefreshControl.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) VASRefreshControl *refreshControl;
@property (nonatomic, strong) RACCommand *refreshCommand;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshControl = [VASRefreshControl refreshControlWithLoaderStyle:VASRefreshControlLoaderStyleBlue
                                                             forScrollView:self.scrollView];
    self.refreshControl.rac_command = self.refreshCommand;
}

- (RACCommand *)refreshCommand
{
    if (!_refreshCommand) {
        _refreshCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSLog(@"Signal execute!");
                    [subscriber sendCompleted];
                });
                return nil;
            }];
        }];
    }
    return _refreshCommand;
}

@end
