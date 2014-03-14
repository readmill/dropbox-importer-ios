//
//  RDMLDropboxFileCell.m
//  Readmill
//
//  Created by Martin Hwasser on 07/03/14.
//  Copyright (c) 2014 Readmill. All rights reserved.

#import "RDMLDropboxFileCell.h"

NSString * const RDMLDropboxFileCellIdentifier = @"RDMLDropboxFileCell";

@implementation RDMLDropboxFileCell

#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
        [self initRDMLSelectCollectionViewCell];
    }
    return self;
}

- (void)initRDMLSelectCollectionViewCell
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.textLabel.font = [UIFont systemFontOfSize:17.0f];
    self.textLabel.textColor = [UIColor blackColor];
    self.textLabel.highlightedTextColor = self.textLabel.textColor;
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.textAlignment = NSTextAlignmentLeft;
    self.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.textLabel.numberOfLines = 1;

    self.detailTextLabel.font = [UIFont systemFontOfSize:12.0f];
    self.detailTextLabel.textColor = [UIColor grayColor];
    self.detailTextLabel.highlightedTextColor = self.detailTextLabel.textColor;
    self.detailTextLabel.backgroundColor = [UIColor clearColor];
    self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
    self.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.detailTextLabel.numberOfLines = 1;
}


#pragma mark -
#pragma mark Properties

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self toggleSelection];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self toggleSelection];
}

- (void)toggleSelection
{
    self.accessoryType = self.selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

@end
