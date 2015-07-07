# VASRefreshControl
Simple pull to refresh control with support RACCommand. Different styles refresh indicator.

<img src="https://habrastorage.org/files/d7f/7b0/9ec/d7f7b09ec21b439dacdada7dc506e54d.gif"/>

### Cocoapods:

```
pod 'VASRefreshControl', :git => 'https://github.com/spbvasilenko/VASRefreshControl.git'
```

### How to use:

1) Create RACCommand, if you need for this:
```
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
```
2) Init VASRefreshControl for your UIScrollView and set RACCommand for execute during refresh: 

```
self.refreshControl = [[VASRefreshControl alloc] initWithLoaderStyle:VASRefreshControlLoaderStyleBlue
                                                       forScrollView:self.scrollView];
self.refreshControl.rac_command = self.refreshCommand;
```

### TO DO:

1) More customize

2) Implement load more refresh

3) Improve animation refresh activity

### Contribution: 

Enjoy merge requests!

# License

The MIT License (MIT)

Copyright (c) 2015, Igor Vasilenko.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
