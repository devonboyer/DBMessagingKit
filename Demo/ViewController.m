//
//  ViewController.m
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2014-12-04.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "ViewController.h"
#import "Message.h"

@interface ViewController ()
{
    NSDictionary *_boldAttributes;
    NSDictionary *_normalAttributes;
    NSDictionary *_timestampAttributes;
}

@property (strong, nonatomic) DBMessageBubbleController *messageBubbleController;
@property (strong, nonatomic) NSMutableArray *messages;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup the demo
    _messages = [[NSMutableArray alloc] init];
    [_messages addObject:[Message messageWithText:@"Welcome to DBMessagingKit. A messaging, UI framework for iOS." sentByUserID:@"Outgoing" sentAt:[NSDate date]]];
    [_messages addObject:[Message messageWithText:@"It is simple to use and very customizable." sentByUserID:@"Incoming" sentAt:[NSDate date]]];
    [_messages addObject:[Message messageWithText:@"There is no dependency on model objects." sentByUserID:@"Outgoing" sentAt:[NSDate date]]];
    [_messages addObject:[Message messageWithText:@"You can even register a custom messaging input view, or use the one built-in you see here!" sentByUserID:@"Outgoing" sentAt:[NSDate date]]];
    [_messages addObject:[Message messageWithText:@"Also supports all data detectors like phone numbers 123-456-7890 and websites https://github.com/DevonBoyer/DBMessagingKit." sentByUserID:@"Incoming" sentAt:[NSDate date]]];
    
    // Configure a message bubble controller with template images
    _messageBubbleController = [[DBMessageBubbleController alloc] initWithCollectionView:self.collectionView outgoingBubbleColor:[UIColor iMessageBlueColor] incomingBubbleColor:[UIColor iMessageGrayColor]];
    [_messageBubbleController setTopTemplateForConsecutiveGroup:[UIImage imageNamed:@"MessageBubbleTop"]];
    [_messageBubbleController setMiddleTemplateForConsecutiveGroup:[UIImage imageNamed:@"MessageBubbleMid"]];
    [_messageBubbleController setBottomTemplateForConsecutiveGroup:[UIImage imageNamed:@"MessageBubbleBottom"]];
    [_messageBubbleController setDefaultTemplate:[UIImage imageNamed:@"MessageBubbleDefault"]];
        
    // Customize layout attributes
    self.collectionView.collectionViewLayout.messageBubbleFont = [UIFont systemFontOfSize:18.0];
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeMake(0.0,0.0);
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeMake(0.0, 0.0);
    
    // Customize the input toolbar and add bar button items
    UIBarButtonItem *cameraBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"camera_button"] style:UIBarButtonItemStylePlain target:self action:@selector(cameraButtonTapped:)];
    UIBarButtonItem *sendBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:@selector(sendButtonTapped:)];
    sendBarButtonItem.tintColor = [UIColor iMessageBlueColor];
    [self.messageInputToolbar addItem:cameraBarButtonItem position:DBMessagingInputToolbarItemPositionLeft animated:false];
    [self.messageInputToolbar addItem:sendBarButtonItem position:DBMessagingInputToolbarItemPositionRight animated:false];
    
    // Specify which bar button will be the send button
    self.messageInputToolbar.sendBarButtonItem = sendBarButtonItem;
    
    // Setup atrributes for labels
    _boldAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:14.0],
                            NSForegroundColorAttributeName:[UIColor lightGrayColor]};
    
    _normalAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14.0],
                        NSForegroundColorAttributeName:[UIColor lightGrayColor]};
    
    _timestampAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:12.0],
                             NSForegroundColorAttributeName:[UIColor lightGrayColor]};
    
    [[DBMessagingTimestampFormatter sharedFormatter] setDateTextAttributes:_boldAttributes];
    [[DBMessagingTimestampFormatter sharedFormatter] setTimeTextAttributes:_normalAttributes];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)sendMessageWithData:(NSData *)data MIMEType:(MIMEType)MIMEType {
    
    /**
     *  This you should do when sending a message:
     *
     *  1. Play sound (optional)
     *  2. Add new message model object to your data source
     *  3. Call 'finishSendingMessage'
     */
    
    Message *newMessage = [Message messageWithData:data MIMEType:MIMEType sentByUserID:[self senderUserID] sentAt:[NSDate date]];
    [_messages addObject:newMessage];
    // [SystemSoundPlayer playMessageSentSound];
    [self finishSendingMessage];
}

- (void)sendButtonTapped:(id)sender {
    
    [self sendCurrentlyComposedText];
}

- (void)cameraButtonTapped:(id)sender {
    
    NSLog(@"Camera tapped");
}

#pragma mark - DBMessagingCollectionViewDataSource

- (NSString *)senderUserID {
    return @"Outgoing";
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _messages.count;
}

- (NSString *)collectionView:(UICollectionView *)collectionView sentByUserIDForMessageAtIndexPath:(NSIndexPath *)indexPath {
    Message *message = [_messages objectAtIndex:indexPath.row];
    return message.sentByUserID;
}

- (MIMEType)collectionView:(UICollectionView *)collectionView MIMETypeForMessageAtIndexPath:(NSIndexPath *)indexPath {
    Message *message = [_messages objectAtIndex:indexPath.row];
    return message.MIMEType;
}

- (NSData *)collectionView:(UICollectionView *)collectionView dataForMessageAtIndexPath:(NSIndexPath *)indexPath {
    Message *message = [_messages objectAtIndex:indexPath.row];
    return message.data;
}

- (CLLocation *)collectionView:(UICollectionView *)collectionView locationForMessageAtIndexPath:(NSIndexPath *)indexPath {
    Message *message = [_messages objectAtIndex:indexPath.row];
    return message.location;
}

- (NSAttributedString *)collectionView:(UICollectionView *)collectionView messageTopLabelAttributedTextForItemAtIndexPath:(NSIndexPath *)indexPath {
    Message *message = [_messages objectAtIndex:indexPath.row];
    
    // Add some logic to displaying sender's name
    
    NSString *sentByUserID = [self collectionView:collectionView sentByUserIDForMessageAtIndexPath:indexPath];
    
    if (sentByUserID == nil ) { return nil; }
    
    if (indexPath.row == 0) {
        return [[NSAttributedString alloc] initWithString:message.sentByUserID attributes:_normalAttributes];
    }
    else {
        NSString *previousSentByUserID = [self collectionView:collectionView sentByUserIDForMessageAtIndexPath:[NSIndexPath indexPathForItem:indexPath.row - 1 inSection:indexPath.section]];
        
        if (![previousSentByUserID isEqualToString:sentByUserID]) {
            return  [[NSAttributedString alloc] initWithString:message.sentByUserID attributes:_normalAttributes];
        }
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(UICollectionView *)collectionView cellTopLabelAttributedTextForItemAtIndexPath:(NSIndexPath *)indexPath {
    Message *message = [_messages objectAtIndex:indexPath.row];

    if (indexPath.row % 3 == 0) {
        return [[DBMessagingTimestampFormatter sharedFormatter] attributedTimestampForDate:message.sentAt];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(UICollectionView *)collectionView cellBottomLabelAttributedTextForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (NSAttributedString *)collectionView:(UICollectionView *)collectionView timestampAttributedTextForSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath {
    Message *message = [_messages objectAtIndex:indexPath.row];
    NSString *formatterTimestamp = [[DBMessagingTimestampFormatter sharedFormatter] verboseTimestampForDate:message.sentAt];
    return  [[NSAttributedString alloc] initWithString:formatterTimestamp attributes:_timestampAttributes];
}

- (UIImageView *)collectionView:(UICollectionView *)collectionView messageBubbleForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_messageBubbleController messageBubbleForIndexPath:indexPath];
}

- (void)collectionView:(DBMessagingCollectionView *)collectionView wantsAvatarForImageView:(UIImageView *)imageView atIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionView:(DBMessagingCollectionView *)collectionView wantsImageForImageView:(UIImageView *)imageView atIndexPath:(NSIndexPath *)indexPath {
    Message *message = [_messages objectAtIndex:indexPath.row];
    UIImage *photo = [UIImage imageWithData:message.data];
    imageView.image = photo;
}

#pragma mark - DBMessagingCollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Avatar Tapped");
}

- (void)collectionView:(UICollectionView *)collectionView didTapMessageBubbleImageView:(UIImageView *)messageBubbleImageView atIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"Message Tapped");
}

- (void)collectionView:(UICollectionView *)collectionView didTapImageView:(UIImageView *)imageView atIndexPath:(NSIndexPath *)indexPath {
    Message *message = [_messages objectAtIndex:indexPath.row];
    
    switch (message.MIMEType) {
        case MIMETypeImage:
            NSLog(@"Image Tapped");
            break;
        case MIMETypeLocation:
            NSLog(@"Location Tapped");
            break;
        case MIMETypeGIF:
            NSLog(@"GIF Tapped");
            break;
        default:
            break;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didTapMoviePlayer:(MPMoviePlayerController *)moviePlayer atIndexPath:(NSIndexPath *)indexPath {
    
    if (moviePlayer.isPreparedToPlay) {
        switch (moviePlayer.playbackState) {
            case MPMoviePlaybackStatePlaying:
                [moviePlayer pause];
                break;
            case MPMoviePlaybackStateStopped: case MPMoviePlaybackStatePaused:
                [moviePlayer play];
                break;
            default:
                break;
        }
    }
}

@end
