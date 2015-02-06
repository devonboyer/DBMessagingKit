//
//  MessagingInputTextView.m
//  MessagingKit
//
//  GitHub
//  https://github.com/DevonBoyer/MessagingKit
//
//  Created by Devon Boyer on 2014-09-18.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import "MessagingInputTextView.h"

// Manually-selected label offsets to align placeholder label with text entry.
static CGFloat const kLabelLeftOffset = 10.0f;

@interface MessagingInputTextView ()

@property (strong, nonatomic) UILabel *placeholderLabel;
@property (assign, nonatomic) CGRect initialFrame;

@end

@implementation MessagingInputTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
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
    
    // Sign up for notifications for text changes:
    
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
    self.placeholderText = NSLocalizedString(@"iMessage", @"IGChatInputView default placeholder text");
    
    _initialFrame = self.frame;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (NSString *)currentlyComposedText
{
    return [self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

#pragma mark - Notifications

- (void)textDidChange:(NSNotification *)notification
{
    if ([self.text length] < 2) {
        [self setNeedsDisplay]; // placeholder may need to be displayed
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
    NSDictionary *attributes = @{NSFontAttributeName : self.font};
    
    CGRect boundingBox = [self.text boundingRectWithSize:CGSizeMake(self.frame.size.width - 20, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributes context:nil];
    
    if (boundingBox.size.height > self.frame.size.height) {
        CGRect rectInSuperview = [self convertRect:self.frame toView:self.superview.superview];
        if (rectInSuperview.origin.y < (self.topLayoutGuide + 20)) {
            self.scrollEnabled = YES;
            [self scrollTextViewToBottomAnimated:NO];
            return;
        }
        else {
            self.scrollEnabled = NO;
        }
    }
    
    CGRect frame = self.frame;
    frame.size.height = boundingBox.size.height + (CGRectGetHeight(_initialFrame) / 2.0 - self.font.lineHeight / 2.0) * 2;
    
    if (frame.size.height != CGRectGetHeight(self.frame)) {
        CGFloat delta = frame.size.height - CGRectGetHeight(self.frame);
        
        if ([self.delegate respondsToSelector:@selector(textViewDidChangeFrame:delta:)]) {
            [self.delegate textViewDidChangeFrame:self delta:delta];
        }
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        self.frame = frame;
    }];
}

- (void)scrollTextViewToBottomAnimated:(BOOL)animated
{
    CGPoint contentOffsetToShowLastLine = CGPointMake(0.0f, self.contentSize.height - CGRectGetHeight(self.bounds));
    
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
    if ([self.text length] == 0) {
        self.placeholderLabel.alpha = 1.f;
    } else {
        self.placeholderLabel.alpha = 0.f;
    }
}

// When text is set or changed, update the label's visibility.
- (void)setText:(NSString *)text
{
    [super setText:text];
    
    [self updatePlaceholderLabelVisibility];
}

@end
