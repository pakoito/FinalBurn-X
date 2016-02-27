/*****************************************************************************
 **
 ** FinalBurn X: Port of FinalBurn to OS X
 ** https://github.com/pokebyte/FinalBurnX
 ** Copyright (C) 2014-2016 Akop Karapetyan
 **
 ** This program is free software; you can redistribute it and/or modify
 ** it under the terms of the GNU General Public License as published by
 ** the Free Software Foundation; either version 2 of the License, or
 ** (at your option) any later version.
 **
 ** This program is distributed in the hope that it will be useful,
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 ** GNU General Public License for more details.
 **
 ** You should have received a copy of the GNU General Public License
 ** along with this program; if not, write to the Free Software
 ** Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 **
 ******************************************************************************
 */
#import <Cocoa/Cocoa.h>

#import "FXEmulatorController.h"
#import "FXLauncherController.h"
#import "FXPreferencesController.h"

@class FXGameController;

@interface FXAppDelegate : NSObject <NSApplicationDelegate>
{
    @private
    FXEmulatorController *emulator;
    FXLauncherController *launcher;
    FXPreferencesController *prefs;
    NSString *appSupportPath;
    NSString *romPath;
	
	NSMutableArray *_emulatorWindows;
}

+ (FXAppDelegate *)sharedInstance;

- (NSURL *)appSupportURL;
- (FXEmulatorController *)emulator;
- (FXPreferencesController *)prefs;
- (NSString *)ROMPath;

- (void)launch:(FXROMSet *)romSet;
- (void) cleanupWindow:(FXGameController *) controller;

- (IBAction)showLauncher:(id)sender;
- (IBAction)showPreferences:(id)sender;

@property (nonatomic, readonly, strong) NSString *nvramPath;
@property (nonatomic, readonly, strong) NSString *inputMapPath;

@end
