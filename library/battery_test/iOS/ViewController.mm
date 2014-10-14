/*
Copyright 2014 Google Inc. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#import "ViewController.h"

#import "AppDelegate.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPMoviePlayerController.h>

NSString* kMovieUrl = @"http://localhost:12345/video.m3u8";

@interface ViewController ()
@property(strong, nonatomic) IBOutlet UIView* movieHolder;
@property(weak, nonatomic) IBOutlet UILabel *counter;
@property(weak, nonatomic) IBOutlet UILabel *batteryLabel;
@property(strong, nonatomic) MPMoviePlayerController* moviePlayer;
@end

@implementation ViewController

- (void)viewDidLoad
{
  ((AppDelegate*)[[UIApplication sharedApplication] delegate]).viewController = self;
  [super viewDidLoad];
  self.moviePlayer =
      [[MPMoviePlayerController alloc] initWithContentURL:
           [NSURL URLWithString:kMovieUrl]];
  [self.movieHolder addSubview:self.moviePlayer.view];
  [self.moviePlayer play];
}

- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];
  [self.moviePlayer.view setFrame:[self.movieHolder bounds]];
}

- (void)dealloc {
}

- (void)incrementCounter {
  static uint32_t s_counter = 0;
  _counter.text = [NSString stringWithFormat:@"%d", s_counter, NULL];
  ++s_counter;

  _batteryLabel.text = [NSString stringWithFormat:@"%f", [[UIDevice currentDevice] batteryLevel]];
}

@end
