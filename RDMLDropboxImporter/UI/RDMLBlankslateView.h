//
//  RDMLLibraryBlankslateView.h
//  Readmill
//
//  Created by Martin Hwasser on 07/03/14.
//  Copyright (c) 2014 Readmill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RDMLBlankslateView : UIView

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic) UIEdgeInsets contentInset;

- (id)initWithImage:(UIImage *)image
          titleText:(NSString *)titleText
         detailText:(NSString *)detailText;


@end
