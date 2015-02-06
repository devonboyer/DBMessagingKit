//
//  MessagingMovieCell.m
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

#import "MessagingMovieCell.h"
#import "MessagingCollectionViewLayoutAttributes.h"
#import "UIColor+Messaging.h"
#import "UIImage+Messaging.h"

#import <AVFoundation/AVFoundation.h>

@interface MessagingMovieCell () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;

@property (strong, nonatomic) NSURL *cachedMoviePath;
@property (strong, nonatomic) UIImage *cachedFrameImage;
@end

@implementation MessagingMovieCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _moviePlayer = [[MPMoviePlayerController alloc] init];
        _moviePlayer.controlStyle = MPMovieControlStyleNone;
        _moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
        _moviePlayer.shouldAutoplay = NO;
        _moviePlayer.view.layer.mask = self.imageView.layer.mask;
        [_moviePlayer.view setClipsToBounds:YES];
        [_moviePlayer.view setUserInteractionEnabled:YES];
        [_moviePlayer.view setFrame:self.messageBubbleImageView.frame];
        [_moviePlayer.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [_moviePlayer.view setBackgroundColor:[UIColor blackColor]];
        [self.messageBubbleImageView insertSubview:_moviePlayer.view aboveSubview:self.imageView];
        
        UITapGestureRecognizer *movieTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMovieTap:)];
        [movieTap setDelegate:self];
        [_moviePlayer.view addGestureRecognizer:movieTap];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [_moviePlayer pause];
}

#pragma mark - Setters

- (void)setMovieData:(NSData *)movieData {
    _movieData = movieData;
    
    if (_moviePlayer.contentURL != nil) {
        return;
    }
    
    if (!_cachedMoviePath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        //NSIndexPath *indexPath = [self.collectionView indexPathForCell:self];
        //NSString *movieName = [NSString stringWithFormat:@"MessagingKit-movie%d.m4v", indexPath.row];
        NSString *movieFilePath = [documentsDirectory stringByAppendingPathComponent:@"movie.m4v"];
        NSURL *movieFileURL = [NSURL fileURLWithPath:movieFilePath];
        if (movieFileURL) {
            [_moviePlayer setContentURL:movieFileURL];
            [_moviePlayer prepareToPlay];
        } else {
            // Movie data must be written to file before it can be played
            dispatch_async(dispatch_get_main_queue(), ^{
                [movieData writeToFile:movieFilePath atomically:YES];
                _cachedMoviePath = [NSURL fileURLWithPath:movieFilePath];
                
                [_moviePlayer setContentURL:_cachedMoviePath];
                [_moviePlayer prepareToPlay];
            });
        }
    } else {
        [_moviePlayer setContentURL:_cachedMoviePath];
        [_moviePlayer prepareToPlay];
    }
}

#pragma mark - Actions

- (void)handleMovieTap:(UITapGestureRecognizer *)tap
{
    if ([self.delegate respondsToSelector:@selector(messageCell:didTapMoviePlayer:)]) {
        [self.delegate messageCell:self didTapMoviePlayer:_moviePlayer];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
