//
//  RDMLLoadingView.m
//  RDMLDropboxBookImporter
//
//  Created by Martin Hwasser on 07/03/14.
//  Copyright (c) 2014 Readmill. All rights reserved.
//

#import "RDMLLoadingView.h"

@interface RDMLLoadingView ()

@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation RDMLLoadingView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor whiteColor];

        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_spinner startAnimating];
        [self addSubview:_spinner];
    }
    return self;
}

#pragma mark -
#pragma mark - Methods

- (void)startAnimating
{
    [self.spinner startAnimating];
}

- (void)stopAnimating
{
    [self.spinner stopAnimating];
}

#pragma mark -
#pragma mark UIView

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self.spinner sizeToFit];
    self.spinner.center = self.center;
}

@end
