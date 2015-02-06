//
//  SystemSoundPlayer.h
//  MessagingKit
//
//  GitHub
//  https://github.com/DevonBoyer/MessagingKit
//
//  Created by Devon Boyer on 2014-09-28.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  An instance of 'SystemSoundPlayer' allows for the playing simple sounds, such as when sending
 *  or recieving a message.
 */
@interface SystemSoundPlayer : NSObject

+ (SystemSoundPlayer *)sharedPlayer;

- (void)playSoundWithName:(NSString *)filename fileExtension:(NSString *)extension;
- (void)playAlertSoundWithName:(NSString *)filename fileExtension:(NSString *)extension;
- (void)playVibrateSound;

@end
