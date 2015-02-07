//
//  DBMessagingMovieCell.h
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

#import "DBMessagingImageCell.h"

#import <MediaPlayer/MediaPlayer.h>

@protocol DBMessagingMovieCellDelegate <DBMessagingImageCellDelegate>

@optional
- (void)messageCell:(DBMessagingParentCell *)cell didTapMoviePlayer:(MPMoviePlayerController *)moviePlayer;

@end

@interface DBMessagingMovieCell : DBMessagingImageCell

@property (weak, nonatomic) id<DBMessagingMovieCellDelegate> delegate;
@property (strong, nonatomic) NSData *movieData;

@end
