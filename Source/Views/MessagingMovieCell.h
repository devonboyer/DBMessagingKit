//
//  MessagingMovieCell.h
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2014-12-06.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "MessagingImageCell.h"

#import <MediaPlayer/MediaPlayer.h>

@protocol MessagingMovieCellDelegate <MessagingImageCellDelegate>

@optional
- (void)messageCell:(MessagingParentCell *)cell didTapMoviePlayer:(MPMoviePlayerController *)moviePlayer;

@end

@interface MessagingMovieCell : MessagingImageCell

@property (weak, nonatomic) id<MessagingMovieCellDelegate> delegate;
@property (strong, nonatomic) NSData *movieData;

@end
