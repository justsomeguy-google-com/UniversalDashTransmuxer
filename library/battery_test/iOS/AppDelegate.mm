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

#import "AppDelegate.h"

#include <HTTPServer.h>

#include "library/battery_test/BatteryTestHTTPConnection.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  _httpServer = [[HTTPServer alloc] init];
  [_httpServer setConnectionClass:[BatteryTestHTTPConnection class]];
  [_httpServer setType:@"_http._tcp."];
  [_httpServer setPort:12345];
  NSError* error;
  BOOL success = [_httpServer start:&error];
  if (!success) {
    NSLog(@"Could not start http server %@", error);
    return NO;
  }

  return YES;
}

@end
