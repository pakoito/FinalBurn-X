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
#import <Foundation/Foundation.h>

static const int FXMappingNotFound = -1;

@interface FXButtonMap : NSObject<NSCoding>

- (int) virtualCodeMatching:(int) code;
- (int) deviceCodeMatching:(int) code;
- (int) mapDeviceCode:(int) deviceCode
		  virtualCode:(int) virtualCode;

@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic, readonly) BOOL dirty;
@property (nonatomic, readonly) BOOL customized;

- (void) clearDirty;

@end
