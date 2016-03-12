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
#import "FXManifestBuilder.h"

#include <wchar.h>

#include "burner.h"
#include "burnint.h"
#include "driverlist.h"

@interface FXManifestBuilder()

- (NSString *) titleOfDriver:(int) index;
- (NSDictionary *) inputsForDriver:(int) driverId;
- (NSMutableDictionary *) componentsForDriver:(int) driverIndex;
- (void) pruneCommonSubsetFilesIn:(NSMutableDictionary *) outer;

@end

@implementation FXManifestBuilder

- (instancetype)init
{
	if ((self = [super init])) {
		BurnLibInit();
	}
	return self;
}

- (void) dealloc
{
	BurnLibExit();
}

- (NSString *) titleOfDriver:(int) index
{
#ifdef wcslen
#undef wcslen
#endif
	NSString *title = nil;
	const wchar_t *fullName = pDriver[index]->szFullNameW;
	if (fullName != NULL) {
		title = [[NSString alloc] initWithBytes:fullName
										 length:sizeof(wchar_t) * wcslen(fullName)
									   encoding:NSUTF32LittleEndianStringEncoding];
	}
	
	if (title == nil) {
		title = [NSString stringWithCString:pDriver[index]->szFullNameA
								   encoding:NSASCIIStringEncoding];
	}
	
	return title;
}

- (NSDictionary *) romSets
{
	NSMutableDictionary *setMap = [@{} mutableCopy];
	NSMutableArray *attrs = [@[] mutableCopy];
	
	for (int index = 0; index < nBurnDrvCount; index++) {
		UInt32 hardware = pDriver[index]->Hardware & HARDWARE_PUBLIC_MASK;
		if ((hardware != HARDWARE_CAPCOM_CPS1) &&
			(hardware != HARDWARE_CAPCOM_CPS1_GENERIC) &&
			(hardware != HARDWARE_CAPCOM_CPS1_QSOUND) &&
			(hardware != HARDWARE_CAPCOM_CPS2) &&
			(hardware != HARDWARE_CAPCOM_CPS2_SIMM) &&
			(hardware != HARDWARE_CAPCOM_CPS3) &&
			(hardware != HARDWARE_CAPCOM_CPS3_NO_CD) &&
			//            (hardware != HARDWARE_PREFIX_KONAMI) &&
			(hardware != (HARDWARE_SNK_NEOGEO | HARDWARE_PREFIX_CARTRIDGE))) {
			// Don't care
			continue;
		}
		
		NSString *archive = [NSString stringWithCString:pDriver[index]->szShortName
											   encoding:NSASCIIStringEncoding];
		
		NSMutableDictionary *set = [@{
									  @"driver": @(index),
									  @"title": [self titleOfDriver:index],
									  @"width": @(pDriver[index]->nWidth),
									  @"height": @(pDriver[index]->nHeight),
									  @"system": [NSString stringWithCString:pDriver[index]->szSystemA
																	encoding:NSASCIIStringEncoding],
									  @"input": [self inputsForDriver:index],
									  } mutableCopy];
		
		if (pDriver[index]->szParent != NULL) {
			[set setObject:[NSString stringWithCString:pDriver[index]->szParent
											 encoding:NSASCIIStringEncoding]
					forKey:@"parent"];
		}
		
		[attrs removeAllObjects];
		if (pDriver[index]->Flags & BDF_ORIENTATION_VERTICAL) {
			[attrs addObject:@"rotated"];
		}
		if (pDriver[index]->Flags & BDF_ORIENTATION_FLIPPED) {
			[attrs addObject:@"flipped"];
		}
		if ([attrs count] > 0) {
			[set setObject:[attrs componentsJoinedByString:@","]
					forKey:@"attrs"];
		}
		
		NSMutableDictionary *components = [self componentsForDriver:index];
		[set addEntriesFromDictionary:components];
		
		[setMap setObject:set
				   forKey:archive];
	}
	
	[self pruneCommonSubsetFilesIn:setMap];
	
	return setMap;
}

- (NSDictionary *) inputsForDriver:(int) driverId
{
	NSMutableDictionary *inputs = [NSMutableDictionary dictionary];
	struct BurnInputInfo bii;
	for (int i = 0; i < 0x1000; i++) {
		if (pDriver[driverId]->GetInputInfo(&bii, i)) {
			break;
		}
		
		if (bii.nType == BIT_DIGITAL) {
			[inputs setObject:@{
								@"code": @(i + 1),
								@"desc": [NSString stringWithCString:bii.szName
															encoding:NSASCIIStringEncoding],
								}
					   forKey:[NSString stringWithCString:bii.szInfo
												 encoding:NSASCIIStringEncoding]];
		}
	}
	
	return inputs;
}

- (NSMutableDictionary *) componentsForDriver:(int) driverIndex
{
	NSMutableDictionary *outer = [@{} mutableCopy];
	NSMutableDictionary *files = [@{} mutableCopy];
	
	[outer setObject:[@{ @"local": files } mutableCopy]
			  forKey:@"files"];
	
	struct BurnRomInfo ri;
	for (int i = 0; ; i++) {
		if (pDriver[driverIndex]->GetRomInfo(&ri, i)) {
			break;
		}
		
		if (ri.nType == 0) {
			continue;
		}
		
		char *cAlias = NULL;
		if (pDriver[driverIndex]->GetRomName(&cAlias, i, 0)) {
			continue;
		}
		
		NSDictionary *romInfo = @{
								  @"len": @(ri.nLen),
								  @"crc": @(ri.nCrc),
								  };
		
		[files setObject:romInfo
				  forKey:[NSString stringWithCString:cAlias
						   encoding:NSASCIIStringEncoding]];
	}
	
	return outer;
}

- (void) pruneCommonSubsetFilesIn:(NSMutableDictionary *) sets
{
	[sets enumerateKeysAndObjectsUsingBlock:^(NSString *archive, NSMutableDictionary *set, BOOL * _Nonnull stop) {
		NSString *parent = [set objectForKey:@"parent"];
		if (!parent) {
			return;
		}
		
		NSDictionary *parentFiles = [[[sets objectForKey:parent] objectForKey:@"files"] objectForKey:@"local"];
		NSMutableDictionary *subFiles = [[set objectForKey:@"files"] objectForKey:@"local"];
		
		NSMutableArray *commonInParent = [@[] mutableCopy];
		[[subFiles copy] enumerateKeysAndObjectsUsingBlock:^(NSString *fileName, NSDictionary *fileInfo, BOOL * _Nonnull stop) {
			if ([parentFiles objectForKey:fileName]) {
				[subFiles removeObjectForKey:fileName];
				[commonInParent addObject:fileName];
			}
		}];
		
		if ([commonInParent count] > 0) {
			[[set objectForKey:@"files"] setObject:commonInParent
											forKey:@"super"];
		}
	}];
}

@end