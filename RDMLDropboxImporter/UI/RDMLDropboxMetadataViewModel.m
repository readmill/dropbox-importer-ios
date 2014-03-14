//
//  RDMLDropboxMetadataViewModel.m
//  RDMLDropboxImporter
//
//  Created by Martin Hwasser on 11/03/14.
//  Copyright (c) 2014 Readmill. All rights reserved.
//

#import "RDMLDropboxMetadataViewModel.h"
#import <DropboxSDK/DropboxSDK.h>
#import "NSDate+RDMLAdditions.h"

@implementation RDMLDropboxMetadataViewModel

- (instancetype)initWithMetadata:(DBMetadata *)metadata
                     currentPath:(NSString *)currentPath
{
    if (self = [super init]) {
        NSString *text = nil;
        UIImage *image = nil;
        if (![metadata isDirectory]) {
            text = metadata.filename;
            CGFloat fileSize = ((CGFloat)metadata.totalBytes)/1000000.0f;
            NSString *detailText = [NSString stringWithFormat:@"%@MB \u2022 modified %@",
                                    [self.numberFormatter stringFromNumber:@(fileSize)], [metadata.lastModifiedDate timeAgo]];
            self.detailText = detailText;
            image = [UIImage imageNamed:@"rdml-db-importer-file"];
        } else {
            text = metadata.filename;
            image = [UIImage imageNamed:@"rdml-db-importer-folder"];
        }
        self.text = text;
        self.image = image;
    }
    return self;
}

- (NSNumberFormatter *)numberFormatter
{
    static NSNumberFormatter *numberFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        numberFormatter = [NSNumberFormatter new];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [numberFormatter setMaximumFractionDigits:1];
        [numberFormatter setLocale:[NSLocale currentLocale]];
    });

    return numberFormatter;
}

@end
