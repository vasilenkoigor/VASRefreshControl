# VASRefreshControl
Simple pull to refresh control with support RACCommand.

<img src="https://habrastorage.org/files/0ef/bcf/e5c/0efbcfe5ce6041c6aa06901e2c08cff0.gif"/>

### How to use:

1. Create RACCommand, if you need for this:

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
