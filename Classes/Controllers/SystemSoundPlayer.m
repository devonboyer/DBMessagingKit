//
//  SystemSoundPlayer.m
//  MessagingKit
//
//  Created by Devon Boyer on 2014-09-28.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import "SystemSoundPlayer.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface SystemSoundPlayer ()

- (void)_playSoundWithName:(NSString *)filename
                 extension:(NSString *)extension
                   isAlert:(BOOL)isAlert;

- (SystemSoundID)_createSoundIDWithName:(NSString *)filename
                             extension:(NSString *)extension;

- (void)_logError:(OSStatus)error withMessage:(NSString *)message;

@end

@implementation SystemSoundPlayer

+ (SystemSoundPlayer *)sharedPlayer
{
    static SystemSoundPlayer *sharedPlayer;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPlayer = [[SystemSoundPlayer alloc] init];
    });
    
    return sharedPlayer;
}

#pragma mark - Public

- (void)playSoundWithName:(NSString *)filename fileExtension:(NSString *)extension
{
    [self _playSoundWithName:filename
                  extension:extension
                    isAlert:NO];
}

- (void)playAlertSoundWithName:(NSString *)filename fileExtension:(NSString *)extension
{
    [self _playSoundWithName:filename
                  extension:extension
                    isAlert:YES];
}

- (void)playVibrateSound
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

#pragma mark - Private

- (void)_playSoundWithName:(NSString *)filename
                 extension:(NSString *)extension
                   isAlert:(BOOL)isAlert
{
    if (!filename || !extension) {
        return;
    }

    SystemSoundID soundID = [self _createSoundIDWithName:filename extension:extension];
    
    if (soundID) {
        if (isAlert) {
            AudioServicesPlayAlertSound(soundID);
        }
        else {
            AudioServicesPlaySystemSound(soundID);
        }
    }
    else {
        NSLog(@"Sound could not be played");
    }
}

#pragma mark - Managing sounds

- (SystemSoundID)_createSoundIDWithName:(NSString *)filename
                              extension:(NSString *)extension
{
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:filename
                                             withExtension:extension];

    if ([[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]]) {
        SystemSoundID soundID;
        OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &soundID);

        if (error) {
            [self _logError:error withMessage:@"Warning! SystemSoundID could not be created."];
            return 0;
        }
        else {
            return soundID;
        }
    }

    NSLog(@"[%@] Error: audio file not found at URL: %@", [self class], fileURL);
    return 0;
}

- (void)_logError:(OSStatus)error withMessage:(NSString *)message
{
    NSString *errorMessage = nil;
    
    switch (error) {
        case kAudioServicesUnsupportedPropertyError:
            errorMessage = @"The property is not supported.";
            break;
        case kAudioServicesBadPropertySizeError:
            errorMessage = @"The size of the property data was not correct.";
            break;
        case kAudioServicesBadSpecifierSizeError:
            errorMessage = @"The size of the specifier data was not correct.";
            break;
        case kAudioServicesSystemSoundUnspecifiedError:
            errorMessage = @"An unspecified error has occurred.";
            break;
        case kAudioServicesSystemSoundClientTimedOutError:
            errorMessage = @"System sound client message timed out.";
            break;
    }
    
    NSLog(@"[%@] %@ Error: (code %d) %@", [self class], message, (int)error, errorMessage);
}

@end
