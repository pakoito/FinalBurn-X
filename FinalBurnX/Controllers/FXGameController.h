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

#import "FXEmulatorProcessWrapper.h"
#import "FXScreenView.h"

@protocol AKKeyboardEventDelegate;

@interface FXGameController : NSWindowController<NSWindowDelegate, AKKeyboardEventDelegate>
{
    IBOutlet FXScreenView *screen;
    IBOutlet NSProgressIndicator *spinner;
	IBOutlet FXEmulatorProcessWrapper *wrapper;
}

- (IBAction) resizeNormalSize:(id) sender;
- (IBAction) resizeDoubleSize:(id) sender;
- (IBAction) pauseGameplay:(id) sender;

- (IBAction) resetEmulation:(id) sender;
- (IBAction) toggleTestMode:(id) sender;

- (instancetype) initWithArchive:(NSString *) archive;

@end