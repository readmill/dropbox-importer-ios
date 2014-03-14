//
//  RDMLDropboxMetadataViewModel.h
//  RDMLDropboxImporter
//
//  Created by Martin Hwasser on 11/03/14.
//  Copyright (c) 2014 Readmill. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBMetadata;

@interface RDMLDropboxMetadataViewModel : NSObject

- (instancetype)initWithMetadata:(DBMetadata *)metadata currentPath:(NSString *)currentPath;

@property (copy, nonatomic) NSString *text;
@property (copy, nonatomic) NSString *detailText;
@property (strong, nonatomic) UIImage *image;

@property (nonatomic) BOOL hidesDisclosureIndicator;

@property (strong, nonatomic) NSNumberFormatter *numberFormatter;

@end
