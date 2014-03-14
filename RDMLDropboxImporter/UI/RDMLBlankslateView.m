//
//  RDMLLibraryBlankslateView.m
//  Readmill
//
//  Created by Martin Hwasser on 07/03/14.
//  Copyright (c) 2014 Readmill. All rights reserved.

#import "RDMLBlankslateView.h"

#define kMaxTextWidthPhone 320
#define kMaxTextWidthPad 640

@implementation RDMLBlankslateView

- (id)initWithImage:(UIImage *)image titleText:(NSString *)titleText detailText:(NSString *)detailText
{
    self = [super initWithFrame:CGRectMake(0, 0, (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? kMaxTextWidthPad : kMaxTextWidthPhone, 300)];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

        CGFloat margin = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 40 : 20;
        self.contentInset = UIEdgeInsetsMake(margin, margin, margin, margin);

        self.contentView = [UIView new];
        [self addSubview:self.contentView];
        
        // Initialization code
        self.imageView = [[UIImageView alloc] initWithImage:image];
                
        self.titleLabel = [UILabel new];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont systemFontOfSize:25];
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text = titleText;
        
        self.detailLabel = [UILabel new];
        self.detailLabel.backgroundColor = [UIColor clearColor];
        self.detailLabel.font = [UIFont systemFontOfSize:17];
        self.detailLabel.textColor = [UIColor blackColor];
        self.detailLabel.numberOfLines = 0;

        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:detailText];
        NSInteger strLength = detailText.length;
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineSpacing:self.detailLabel.font.pointSize * 0.5f];
        [style setAlignment:NSTextAlignmentCenter];
        [attributedString addAttribute:NSParagraphStyleAttributeName
                                 value:style
                                 range:NSMakeRange(0, strLength)];
        self.detailLabel.attributedText = attributedString;
        
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.detailLabel];
    }
    return self;
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    [self willChangeValueForKey:@"contentInset"];
    _contentInset = contentInset;
    [self didChangeValueForKey:@"contentInset"];
    [self setNeedsLayout];
}

- (void)setBottomView:(UIView *)bottomView
{
    [_bottomView removeFromSuperview];
    [self willChangeValueForKey:@"bottomView"];
    _bottomView = bottomView;
    [self didChangeValueForKey:@"bottomView"];
    [self.contentView addSubview:_bottomView];
    [self setNeedsLayout];
}

- (void)sizeToFit
{
    [super sizeToFit];

    [self setNeedsLayout];
    [self layoutIfNeeded];

    CGRect frame = self.frame;
    frame.size.height = CGRectGetMaxY(self.contentView.frame);
    self.frame = CGRectIntegral(frame);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = CGRectZero;

    CGFloat width = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? kMaxTextWidthPad : kMaxTextWidthPhone);
    width = MIN(CGRectGetWidth(self.bounds), width)-self.contentInset.left-self.contentInset.right;

    [self.imageView sizeToFit];
    frame = self.imageView.bounds;
    frame.origin.x = width / 2 - CGRectGetWidth(frame) / 2;
    self.imageView.frame = CGRectIntegral(frame);
    
    CGSize sizeConstraint = [self.titleLabel sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    frame.size = sizeConstraint;
    frame.origin.y = CGRectGetMaxY(self.imageView.frame) + (CGRectGetHeight(self.imageView.frame) > 0.0f ? 20 : 0);
    frame.origin.x = width / 2 - CGRectGetWidth(frame) / 2;
    self.titleLabel.frame = CGRectIntegral(frame);
    
    sizeConstraint = [self.detailLabel sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    frame.size = CGSizeMake(sizeConstraint.width, sizeConstraint.height);
    frame.origin.y = CGRectGetMaxY(self.titleLabel.frame) + 20;
    frame.origin.x = width / 2 - CGRectGetWidth(frame) / 2;
    self.detailLabel.frame = CGRectIntegral(frame);
    
    if (self.bottomView.superview == self.contentView) {
        frame = self.bottomView.bounds;
        if ([self.bottomView isKindOfClass:[UIButton class]]) {
            frame = [(UIButton *)self.bottomView titleRectForContentRect:self.bottomView.frame];
        }
        frame.origin.y = CGRectGetMaxY(self.detailLabel.frame) + 25;
        frame.origin.x = width / 2 - CGRectGetWidth(frame) / 2;
        self.bottomView.frame = CGRectIntegral(frame);
    }
    
    frame.size.width = width;
    frame.size.height = CGRectGetMaxY(frame);
    frame.origin.x = self.contentInset.left/2.0f+CGRectGetMidX(self.bounds)-width/2.0f-self.contentInset.right/2.0f;
    frame.origin.y = self.contentInset.top/2.0f+CGRectGetMidY(self.bounds)-CGRectGetHeight(frame)/2.0f-self.contentInset.bottom/2.0f;
    self.contentView.frame = CGRectIntegral(frame);
}

@end
