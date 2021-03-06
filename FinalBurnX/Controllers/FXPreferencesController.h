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

#import "AKKeyCaptureView.h"
#import "AKGamepadManager.h"
#import "AKKeyboardManager.h"

@interface FXButtonConfig : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) int virtualCode;

@end

@interface FXDIPOptionUI : NSObject

@property (nonatomic, readonly) NSString *title;

@end

@interface FXDIPGroupUI : NSObject

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSArray<FXDIPOptionUI *> *options;
@property (nonatomic, assign) NSUInteger selection;

@end

@interface FXPreferencesController : NSWindowController<NSTableViewDataSource, NSWindowDelegate, AKKeyboardEventDelegate, AKGamepadEventDelegate>
{
    IBOutlet NSToolbar *toolbar;
    IBOutlet NSTabView *contentTabView;
    IBOutlet NSTableView *inputTableView;
    IBOutlet NSTableView *dipswitchTableView;
    IBOutlet NSButton *resetDipSwitchesButton;
	IBOutlet NSSlider *volumeSlider;
	IBOutlet NSPopUpButton *inputDevicesPopUp;
}

- (IBAction) tabChanged:(id) sender;
- (IBAction) resetDipSwitchesClicked:(id) sender;
- (IBAction) showNextTab:(id) sender;
- (IBAction) showPreviousTab:(id) sender;
- (IBAction) inputDeviceDidChange:(id) sender;

@end
