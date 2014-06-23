/*****************************************************************************
 **
 ** FinalBurn X: Port of FinalBurn to OS X
 ** https://github.com/pokebyte/FinalBurnX
 ** Copyright (C) 2014 Akop Karapetyan
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
#import "FXAudio.h"

#import "AKAppDelegate.h"

#include "burner.h"

@interface FXAudio ()

- (void)cleanup;

@end

@implementation FXAudio

#pragma mark - Init and dealloc

- (instancetype)init
{
    if (self = [super init]) {
    }

    return self;
}

- (void)dealloc
{
    [self cleanup];
}

#pragma mark - Core callbacks

- (BOOL)initCore
{
    NSLog(@"audio/init");
    
    if (nAudSampleRate <= 0) {
        return NO;
    }
    
    self->audioCallback = NULL;
	self->soundFps = nAppVirtualFps;
    nAudSegLen = (44010 * 100 + (self->soundFps / 2)) / self->soundFps;
    self->soundLoopLength = (nAudSegLen * nAudSegCount) * 4;
    
    int bufferSize = 64;
    for (; bufferSize < (nAudSegLen >> 1); bufferSize *= 2);
    
    /*
     audiospec_req.freq = 44010;
     audiospec_req.format = AUDIO_S16;
     audiospec_req.channels = 2;
     audiospec_req.samples = nSDLBufferSize;
     audiospec_req.callback = audiospec_callback;
     */
    
    self->soundBuffer = (short *)malloc(self->soundLoopLength);
    if (self->soundBuffer == NULL) {
        [self cleanup];
        return NO;
    }
    memset(self->soundBuffer, 0, self->soundLoopLength);
    
	nAudNextSound = (short *)malloc(nAudSegLen << 2);
	if (nAudNextSound == NULL) {
        return NO;
	}
    
    self->playPosition = 0;
    self->fillSegment = nAudSegCount - 1;
    
    /*
     if(SDL_OpenAudio(&audiospec_req, &audiospec)) {
     fprintf(stderr, "Couldn't open audio: %s\n", SDL_GetError());
     dprintf(_T("Couldn't open audio: %s\n"), SDL_GetError());
     return 1;
     }
     
     SDLSetCallback(NULL);
     */
    
    nBurnSoundRate = 44100;
    nBurnSoundLen = nAudSegLen;
    
    return YES;
}

- (void)exitCore
{
    NSLog(@"audio/exit");
    
    [self cleanup];
}

- (void)setCallback:(int(*)(int))callback
{
    NSLog(@"audio/setCallback");
    
    self->audioCallback = callback;
    
    /*
     if (pCallback == NULL) {
     GetNextSound = SDLSoundGetNextSoundFiller;
     } else {
     GetNextSound = pCallback;
     dprintf(_T("SDL callback set\n"));
     }
     */
}

- (BOOL)play
{
    NSLog(@"audio/play");
    
    /*
     SDL_PauseAudio(0);
     */
    bAudPlaying = 1;
    
    return YES;
}

- (BOOL)stop
{
    NSLog(@"audio/stop");
    
    /*
     SDL_PauseAudio(1);
     */
    bAudPlaying = 0;
    
    return YES;
}

- (BOOL)clear
{
    NSLog(@"audio/clear");
    
    if (nAudNextSound) {
        memset(nAudNextSound, 0, nAudSegLen << 2);
    }
    
    return YES;
}

#define WRAP_INC(x) { x++; if (x >= nAudSegCount) x = 0; }

- (BOOL)checkAudio
{
    if (!bAudPlaying) {
        return YES;
    }
    
    // Since the SDL buffer is smaller than a segment, only fill the buffer up to the start of the currently playing segment
    int playSegment = self->playPosition / (nAudSegLen << 2) - 1;
    if (playSegment >= nAudSegCount) {
        playSegment -= nAudSegCount;
    }
    if (playSegment < 0) {
        playSegment = nAudSegCount - 1;
    }
    
    if (self->fillSegment == playSegment) {
        [NSThread sleepForTimeInterval:.001];
        return YES;
    }
    
    // work out which seg we will fill next
    int followingSegment = self->fillSegment;
    WRAP_INC(followingSegment);
    
    while (self->fillSegment != playSegment) {
        int draw = (followingSegment == playSegment);
        self->audioCallback(draw);
        
        memcpy((char *)self->soundBuffer + self->fillSegment * (nAudSegLen << 2),
               nAudNextSound, nAudSegLen << 2);
        
        self->fillSegment = followingSegment;
        WRAP_INC(followingSegment);
    }
    
    return YES;
}

#pragma mark - Etc

- (void)cleanup
{
    free(self->soundBuffer);
    self->soundBuffer = NULL;
}

@end

#pragma mark - FinalBurn callbacks

static int cocoaAudioBlankSound()
{
    FXAudio *audio = [[[AKAppDelegate sharedInstance] emulator] audio];
    return [audio clear] ? 0 : 1;
}

static int cocoaAudioCheck()
{
    FXAudio *audio = [[[AKAppDelegate sharedInstance] emulator] audio];
    return [audio checkAudio] ? 0 : 1;
}

static int cocoaAudioInit()
{
    FXAudio *audio = [[[AKAppDelegate sharedInstance] emulator] audio];
    return [audio initCore] ? 0 : 1;
}

static int cocoaAudioSetCallback(int (*callback)(int))
{
    FXAudio *audio = [[[AKAppDelegate sharedInstance] emulator] audio];
    [audio setCallback:callback];
    
	return 0;
}

static int cocoaAudioPlay()
{
    FXAudio *audio = [[[AKAppDelegate sharedInstance] emulator] audio];
    return [audio play] ? 0 : 1;
}

static int cocoaAudioStop()
{
    FXAudio *audio = [[[AKAppDelegate sharedInstance] emulator] audio];
    return [audio stop] ? 0 : 1;
}

static int cocoaAudioExit()
{
    FXAudio *audio = [[[AKAppDelegate sharedInstance] emulator] audio];
    [audio exitCore];
    
    return 0;
}

static int cocoaAudioSetVolume()
{
	return 1;
}

static int cocoaAudioGetSettings(InterfaceInfo *info)
{
	return 0;
}

struct AudOut AudOutCocoa = {
    cocoaAudioBlankSound,
    cocoaAudioCheck,
    cocoaAudioInit,
    cocoaAudioSetCallback,
    cocoaAudioPlay,
    cocoaAudioStop,
    cocoaAudioExit,
    cocoaAudioSetVolume,
    cocoaAudioGetSettings,
    "Cocoa audio output"
};
