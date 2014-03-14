//
//  RDMLDirectoryCell.m
//  RDMLDropboxBookImporter
//
//  Created by Martin Hwasser on 07/03/14.
//  Copyright (c) 2014 Readmill. All rights reserved.
//

#import "RDMLDropboxDirectoryCell.h"

NSString * const RDMLDropboxDirectoryCellIdentifier = @"RDMLDropboxDirectoryCell";

@implementation RDMLDropboxDirectoryCell

- (id)init
{
    if (self = [super init]) {
        [self initRDMLDropboxDirectoryCell];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self initRDMLDropboxDirectoryCell];
    }
    return self;
}

- (void)initRDMLDropboxDirectoryCell
{
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

@end
