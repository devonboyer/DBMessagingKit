//
//  SystemSoundPlayer.h
//  MessagingKit
//
//  Created by Devon Boyer on 2014-09-28.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SystemSoundPlayer : NSObject

+ (SystemSoundPlayer *)sharedPlayer;

- (void)playSoundWithName:(NSString *)filename fileExtension:(NSString *)extension;
- (void)playAlertSoundWithName:(NSString *)filename fileExtension:(NSString *)extension;
- (void)playVibrateSound;

@end
