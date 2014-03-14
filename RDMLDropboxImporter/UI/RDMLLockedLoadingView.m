//
//  RDMLLockedLoadingView.m
//  Readmill
//
//  Created by Martin Hwasser on 07/03/14.
//  Copyright (c) 2014 Readmill. All rights reserved.
//

#import "RDMLLockedLoadingView.h"

@interface RDMLLockedLoadingView ()

@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIView *infoView;

@end

@implementation RDMLLockedLoadingView

- (id)init
{
    CGRect bounds = [UIScreen mainScreen].bounds;
    return [self initWithFrame:bounds];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        // Initialization code

        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.85];
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;

        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [spinner startAnimating];
        self.spinner = spinner;
        
        UILabel *label = [UILabel new];
        self.label = label;
        label.font = [UIFont systemFontOfSize:17                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        ];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;

        _text = @"Sit tight...";

        UIView *infoView = [[UIView alloc] init];
        self.infoView = infoView;
        [infoView addSubview:spinner];
        [infoView addSubview:label];
        infoView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;

        [self addSubview:infoView];

        [self updateView];
    }
    return self;
}

- (void)setText:(NSString *)text
{
    if (_text != text) {
        _text = [text copy];
        [self updateView];
    }
}

- (void)updateView
{
    self.label.text = self.text;

    CGSize sizeConstraint = CGSizeMake(self.frame.size.width - 2 * 20, CGFLOAT_MAX);
    CGSize size = [self.label sizeThatFits:sizeConstraint];
    self.label.frame = CGRectMake(0, 0, size.width, size.height);

    CGRect labelFrame = self.label.frame;
    CGFloat infoViewFrameWidth = CGRectGetWidth(labelFrame);

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        labelFrame.origin.x = CGRectGetWidth(self.spinner.frame) + 20;
        labelFrame.origin.y = CGRectGetMidY(self.spinner.frame) - CGRectGetHeight(labelFrame) / 2;
        infoViewFrameWidth = CGRectGetMaxX(labelFrame);
    } else {
        self.spinner.center = CGPointMake(infoViewFrameWidth / 2, CGRectGetMidY(self.spinner.bounds));
        labelFrame.origin.y = CGRectGetMaxY(self.spinner.frame) + 20;
    }
    self.label.frame = CGRectIntegral(labelFrame);

    CGRect infoViewFrame = CGRectMake(CGRectGetMidX(self.bounds) - infoViewFrameWidth / 2,
                                      CGRectGetHeight(self.bounds) / 2 - CGRectGetMaxY(labelFrame) / 2,
                                      infoViewFrameWidth, MAX(CGRectGetHeight(self.spinner.bounds), CGRectGetHeight(labelFrame)));
    self.infoView.frame = CGRectIntegral(infoViewFrame);
}

@end
