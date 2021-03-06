/*****************************************************************************
 **
 ** FinalBurn X: FinalBurn for macOS
 ** https://github.com/0xe1f/FinalBurn-X
 ** Copyright (C) 2014-2018 Akop Karapetyan
 **
 ** Licensed under the Apache License, Version 2.0 (the "License");
 ** you may not use this file except in compliance with the License.
 ** You may obtain a copy of the License at
 **
 **     http://www.apache.org/licenses/LICENSE-2.0
 **
 ** Unless required by applicable law or agreed to in writing, software
 ** distributed under the License is distributed on an "AS IS" BASIS,
 ** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 ** See the License for the specific language governing permissions and
 ** limitations under the License.
 **
 ******************************************************************************
 */
#import <Cocoa/Cocoa.h>

#import "FXEmulatorController.h"
#import "FXLauncherController.h"
#import "FXPreferencesController.h"

@interface FXAppDelegate : NSObject <NSApplicationDelegate>

+ (FXAppDelegate *)sharedInstance;

- (NSURL *) appSupportURL;
- (void) launch:(NSString *) name;
- (void) suppressScreenSaver;
- (void) restoreScreenSaver;

- (IBAction) showLauncher:(id) sender;
- (IBAction) showPreferences:(id) sender;
- (IBAction) showAbout:(id) sender;

@property (nonatomic, readonly) NSString *romPath;
@property (nonatomic, readonly) NSString *nvramPath;
@property (nonatomic, readonly) NSString *inputMapPath;
@property (nonatomic, readonly) NSString *dipPath;

@property (nonatomic, readonly) FXEmulatorController *emulator;
@property (nonatomic, readonly) FXPreferencesController *prefs;

@end
