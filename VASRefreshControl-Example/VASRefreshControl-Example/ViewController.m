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
    
    self.refreshControl = [[VASRefreshControl alloc] initWithLoaderStyle:VASRefreshControlLoaderStyleBlue
                                                                         forScrollView:self.scrollView];
    self.refreshControl.rac_command = self.refreshCommand;
}

- (RACCommand *)refreshCommand
{
    if (!_refreshCommand) {
        _refreshCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                
                NSLog(@"Signal execute!");
                [subscriber sendCompleted];
                return nil;
            }];
        }];
    }
    return _refreshCommand;
}

@end
