//
//  MessagingKit.h
//  MessagingKit
//
//  GitHub
//  https://github.com/DevonBoyer/MessagingKit
//
//  Created by Devon Boyer on 2014-10-12.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

//! Project version number for MessagingKit.
FOUNDATION_EXPORT double MessagingKitVersionNumber;

//! Project version string for MessagingKit.
FOUNDATION_EXPORT const unsigned char MessagingKitVersionString[];

#ifndef MessagingKit_MessagingKit_h
#define MessagingKit_MessagingKit_h

#import "MessagingKitConstants.h"

// Protocols
#import "MessagingInputUtility.h"
#import "MessagingCollectionViewDataSource.h"
#import "MessagingCollectionViewDelegateFlowLayout.h"

// Factories
#import "MessageBubbleFactory.h"
#import "MessagingTimestampFormatter.h"

// Controllers
#import "MessagingViewController.h"
#import "MessageBubbleController.h"
#import "InteractiveKeyboardController.h"
#import "SystemSoundPlayer.h"

// Layout
#import "MessagingCollectionViewFlowLayout.h"
#import "MessagingCollectionViewFlowLayoutInvalidationContext.h"
#import "MessagingCollectionViewLayoutAttributes.h"

// Views
#import "MessageInputView.h"
#import "MessagingCollectionView.h"
#import "MessagingTextCell.h"
#import "MessagingImageCell.h"
#import "MessagingMovieCell.h"
#import "MessagingLocationCell.h"
#import "MessagingGIFCell.h"
#import "MessagingInputTextView.h"
#import "MessagingTimestampSupplementaryView.h"
#import "MessagingLoadEarlierMessagesHeaderView.h"
#import "MessagingTypingIndicatorFooterView.h"

// Categories
#import "NSAttributedString+Messaging.h"
#import "UIColor+Messaging.h"
#import "UIImage+Messaging.h"
#import "UIImage+AnimatedGIF.h"

#endif
