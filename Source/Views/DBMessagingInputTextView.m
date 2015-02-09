//
//  DBMessagingInputTextView.m
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2014-09-18.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBMessagingInputTextView.h"

#import "DBMessagingKitConstants.h"
#import "UIImage+Messaging.h"
#import "NSAttributedString+Messaging.h"
#import "NSMutableAttributedString+Messaging.h"

// Manually-selected label offsets to align placeholder label with text entry.
static CGFloat const kLabelLeftOffset = 10.0f;

@interface DBMessagingInputTextView ()
{
    NSArray *_messageParts;
}

@property (strong, nonatomic) UILabel *placeholderLabel;
@property (assign, nonatomic) CGRect initialFrame;

@end

@implementation DBMessagingInputTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    _attatchmentRanges = [[NSMutableArray alloc] init];
    _messageParts = [[NSArray alloc] init];
    
    _maximumHeight = 200.0;
    
    self.font = [UIFont systemFontOfSize:17.0];
    
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setScrollEnabled:NO];
    [self setTextContainerInset:UIEdgeInsetsMake(CGRectGetHeight(self.frame) / 2.0 - self.font.lineHeight / 2.0, 5, 0, 5)];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    [self addObserver:self forKeyPath:@"frame" options:0 context:nil];
    
    CGFloat labelLeftOffset = kLabelLeftOffset;
    // Use our calculated label offset from initWith…:
    CGFloat labelTopOffset = self.textContainerInset.top;
    
    CGSize labelOffset = CGSizeMake(labelLeftOffset, labelTopOffset);
    CGRect labelFrame = [self placeholderLabelFrameWithOffset:labelOffset];
    
    self.placeholderLabel = [[UILabel alloc] initWithFrame:labelFrame];
    self.placeholderLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.placeholderLabel.numberOfLines = 0;
    self.placeholderLabel.font = self.font;
    self.placeholderLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.placeholderLabel];
    
    self.borderWidth = 1.0;
    self.cornerRadius = 5.0;
    self.borderColor = [UIColor colorWithWhite:0.88f alpha:1.0f];
    self.placeholderColor = [UIColor colorWithWhite:0.80f alpha:1.0f];
    self.placeholderText = NSLocalizedString(@"iMessage", @"ChatInputView default placeholder text");
    
    _initialFrame = self.frame;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self removeObserver:self forKeyPath:@"frame"];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"frame"]) {
        
        CGFloat labelLeftOffset = kLabelLeftOffset;
        // Use our calculated label offset from initWith…:
        CGFloat labelTopOffset = self.textContainerInset.top;
        
        CGSize labelOffset = CGSizeMake(labelLeftOffset, labelTopOffset);
        CGRect labelFrame = [self placeholderLabelFrameWithOffset:labelOffset];
        
        // Reset the frame of the placeholder
        [self.placeholderLabel setFrame:labelFrame];
    }
}

#pragma mark - Getters

- (NSArray *)messageParts {
    // This is wrong, possibility for duplicate parts
    
    
    // Append the last message part
    NSString *currentlyComposedText = [self currentlyComposedText];
    NSMutableArray *mutableMessageParts = _messageParts.mutableCopy;
    if (![currentlyComposedText isEqualToString:@""]) {
        [mutableMessageParts addObject:@{@"mime": @"text/plain", @"value" : currentlyComposedText}];
    }
    _messageParts = mutableMessageParts;
    
    return _messageParts;
}

#pragma mark - Setters

- (void)setBorderWidth:(NSInteger)borderWidth
{
    _borderWidth = borderWidth;
    [self.layer setBorderWidth:_borderWidth];
}

- (void)setCornerRadius:(NSInteger)cornerRadius
{
    _cornerRadius = cornerRadius;
    [self.layer setCornerRadius:_cornerRadius];
}

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    [self.layer setBorderColor:_borderColor.CGColor];
}

- (void)setPlaceholderText:(NSString *)placeholderText
{
    _placeholderText = placeholderText;
    _placeholderText = [placeholderText copy];
    self.placeholderLabel.text = placeholderText;
    
    CGFloat labelLeftOffset = kLabelLeftOffset;
    CGFloat labelTopOffset = self.textContainerInset.top;
    CGSize labelOffset = CGSizeMake(labelLeftOffset, labelTopOffset);
    CGRect labelFrame = [self placeholderLabelFrameWithOffset:labelOffset];
    
    [self.placeholderLabel setFrame:labelFrame];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    _placeholderColor = placeholderColor;
    _placeholderLabel.textColor = placeholderColor;
}

// Keep the placeholder label font in sync with the view's text font.
- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    self.placeholderLabel.font = self.font;
}

// Keep placeholder label alignment in sync with the view's text alignment.
- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    [super setTextAlignment:textAlignment];
    
    self.placeholderLabel.textAlignment = textAlignment;
}

// Todo: override setAttributedText to capture changes
// in text alignment?

#pragma mark - Actions

- (void)addImageAttatchment:(UIImage *)image {

    CGSize imageSize = image.size;
    imageSize.width = self.textContainer.size.width - self.textContainerInset.left - self.textContainerInset.right;
    imageSize.height /= (image.size.width / imageSize.width);
    
    NSTextAttachment *imageAttatchment = [[NSTextAttachment alloc] init];
    imageAttatchment.image = [UIImage imageByRoundingCorners:34.0 ofImage:image];
    imageAttatchment.bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
    
    // Add line height to attatchment to give it some padding
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    
    NSMutableAttributedString *attachmentString = [NSMutableAttributedString mutableAttributedStringWithAttachment:imageAttatchment];
    [attachmentString addAttributes:@{NSParagraphStyleAttributeName: style} range:NSMakeRange(0, attachmentString.length)];

    NSMutableAttributedString *replacementString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    
    // Get the range of the attatchment to use a key
    NSRange range = NSMakeRange(replacementString.length, attachmentString.length);
    
    [replacementString appendAttributedString:attachmentString];    
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:17.0]};
    [replacementString addAttributes:attributes range:NSMakeRange(0, replacementString.length)];

    self.attributedText = replacementString;
    [self adjustFrame];
    [self updatePlaceholderLabelVisibility];
    [self scrollTextViewToBottomAnimated:YES];
    
    // Create the message parts
    NSString *currentlyComposedText = [self currentlyComposedText];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray *mutableMessageParts = _messageParts.mutableCopy;

        if (![currentlyComposedText isEqualToString:@""]) {
            [mutableMessageParts addObject:@{@"mime": @"text/plain", @"value" : currentlyComposedText}];
        }
        
        [mutableMessageParts addObject:@{@"mime": @"image/jpeg", @"value" : image.encodeToBase64String}];
        _messageParts = mutableMessageParts;
    });
    
    [_attatchmentRanges addObject:[NSValue valueWithRange:range]];
}

- (void)removeImageAttatchmentAtRange:(NSRange)range {
    
    NSValue *rangeValue = [NSValue valueWithRange:range];    
    [_attatchmentRanges removeObject:rangeValue];
    
    // Update the message parts to reflect the deleted attatchment
    NSMutableArray *mutableMessageParts = _messageParts.mutableCopy;
    [mutableMessageParts removeLastObject];
    
    NSDictionary *previousPart = [mutableMessageParts lastObject];
    if ([previousPart[@"mime"] isEqualToString:@"text/plain"]) {
        [mutableMessageParts removeLastObject];
    }
    
    _messageParts = mutableMessageParts;
}

// Possibly misleading...?
- (NSString *)currentlyComposedText {
    
    NSRange rangeOfLastImage = ((NSValue *)_attatchmentRanges.lastObject).rangeValue;
    NSRange targetRange = NSMakeRange(rangeOfLastImage.location, self.attributedText.length - rangeOfLastImage.location);
    
    NSString *stringByTrimmingWhitespace = [[self.attributedText.string substringWithRange:targetRange] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return [stringByTrimmingWhitespace stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\ufffc"]];
}

- (void)clear {
    
    _attatchmentRanges = [[NSMutableArray alloc] init];
    _messageParts = [[NSArray alloc] init];
    
    [self setText:@""];
    [self updatePlaceholderLabelVisibility];
    [self adjustFrame];
}

#pragma mark - Notifications

- (void)textDidChange:(NSNotification *)notification
{
    if ([self.attributedText length] < 2) {
        [self setNeedsDisplay]; // placeholder may need to be displayed
    }
    
    if (self.attributedText.length == 0) {
        [self clear];
    }
    
    [self updatePlaceholderLabelVisibility];
    [self adjustFrame];
}

- (void)orientationDidChange:(NSNotification *)notification
{
    [self adjustFrame];
    [self setNeedsDisplay]; // redraw placeholder if orientation changes
}

- (void)adjustFrame
{
    CGRect stringRect = [self.attributedText boundingRectWithSize:CGSizeMake(self.frame.size.width - 20, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    
    CGRect frame = self.frame;
    
    CGFloat proposedHeight = MAX(stringRect.size.height + (CGRectGetHeight(_initialFrame) / 2.0 - self.font.lineHeight / 2.0) * 2, _initialFrame.size.height);
    
    if (proposedHeight < _maximumHeight) {
        self.scrollEnabled = NO;
        self.showsVerticalScrollIndicator = NO;
        self.alwaysBounceVertical = NO;
        
        frame.size.height = proposedHeight;
        
    } else {
        self.scrollEnabled = YES;
        self.showsVerticalScrollIndicator = YES;
        self.alwaysBounceVertical = YES;
        
        frame.size.height = _maximumHeight;
    }
    
    if (round(frame.size.height) != round(self.frame.size.height)) {
        CGFloat change = round(frame.size.height - self.frame.size.height);
        
        if ([self.delegate respondsToSelector:@selector(textViewDidChangeFrame:delta:)]) {
            [self.delegate textViewDidChangeFrame:self delta:change];
        }
        
        self.frame = frame;
    }
}

- (void)scrollTextViewToBottomAnimated:(BOOL)animated
{
    CGPoint contentOffsetToShowLastLine = CGPointMake(0.0f, self.contentSize.height - self.bounds.size.height);
    
    if (!animated) {
        self.contentOffset = contentOffsetToShowLastLine;
        return;
    }
    
    [UIView animateWithDuration:0.01
                          delay:0.01
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.contentOffset = contentOffsetToShowLastLine;
                     }
                     completion:nil];
}

#pragma mark - UIResponder

- (void)paste:(id)sender
{
    [super paste:sender];
    
    if ([self.text length] > 0) {
        [self setNeedsDisplay]; // remove placeholder for pasted text
    }
}

#pragma mark - Utility

- (CGRect)placeholderLabelFrameWithOffset:(CGSize)labelOffset
{
    return CGRectMake(labelOffset.width,
                      labelOffset.height,
                      self.bounds.size.width  - (2 * labelOffset.width),
                      self.bounds.size.height - (2 * labelOffset.height));
}

#pragma mark - UITextInput

// Listen to dictation events to hide the placeholder as is appropriate.

// Hide when there's a dictation result placeholder
- (id)insertDictationResultPlaceholder
{
    id placeholder = [super insertDictationResultPlaceholder];
    
    // Use -[setHidden] here instead of setAlpha:
    // these events also trigger -[textChanged],
    // which has a different criteria by which it shows the label,
    // but we undeniably know we want this placeholder hidden.
    self.placeholderLabel.hidden = YES;
    return placeholder;
}

// Update visibility when dictation ends.
- (void)removeDictationResultPlaceholder:(id)placeholder willInsertResult:(BOOL)willInsertResult
{
    [super removeDictationResultPlaceholder:placeholder willInsertResult:willInsertResult];
    
    // Unset the hidden flag from insertDictationResultPlaceholder.
    self.placeholderLabel.hidden = NO;
    
    // Update our text label based on the entered text.
    [self updatePlaceholderLabelVisibility];
}

#pragma mark - Text change listeners

- (void)updatePlaceholderLabelVisibility
{
    if ([self.attributedText length] == 0) {
        self.placeholderLabel.alpha = 1.f;
    } else {
        self.placeholderLabel.alpha = 0.f;
    }
}

// When text is set or changed, update the label's visibility.
- (void)setText:(NSString *)text {
    
    NSDictionary *attributes = @{NSFontAttributeName: self.font};
    self.attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    
    [self updatePlaceholderLabelVisibility];
}

@end
