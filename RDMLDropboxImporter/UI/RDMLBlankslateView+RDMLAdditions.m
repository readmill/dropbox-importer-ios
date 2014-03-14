//
//  RDMLBlankslateView+RDMLAdditions.m
//  RDMLDropboxImporter
//
//  Created by Martin Hwasser on 11/03/14.
//  Copyright (c) 2014 Readmill. All rights reserved.
//

#import "RDMLBlankslateView+RDMLAdditions.h"

@implementation RDMLBlankslateView (RDMLAdditions)

+ (instancetype)blankslateNetworkError
{
    return [[RDMLBlankslateView alloc] initWithImage:[UIImage imageNamed:@"rdml-db-importer-bs-noconnection"]
                                           titleText:NSLocalizedString(@"Network error", nil)
                                          detailText:NSLocalizedString(@"Your Internet connection might be offline. This could also happen if you are on a spotty mobile connection. Please try again later.", nil)];
}

@end
