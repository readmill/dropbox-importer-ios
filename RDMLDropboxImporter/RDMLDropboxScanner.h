//
//  RDMLDropboxScanner.h
//  Readmill
//
//  Created by Martin Hwasser on 07/03/14.
//  Copyright (c) 2014 Readmill. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBSession;
@class DBMetadata;
@class RDMLDropboxScanner;

typedef NS_ENUM(NSInteger, RDMLDropboxScannerFileType) {
    RDMLDropboxScannerFileTypeDirectory,
    RDMLDropboxScannerFileTypeFile,
    RDMLDropboxScannerFileTypeNumberOfFileTypes
};

@protocol RDMLDropboxScannerDelegate <NSObject>

@optional

- (void)dropboxScannerDidStartScanning:(RDMLDropboxScanner *)dropboxScanner;
- (void)dropboxScannerDidFinishScanning:(RDMLDropboxScanner *)dropboxScanner;
- (void)dropboxScanner:(RDMLDropboxScanner *)dropboxScanner didLoadFiles:(NSArray *)files;
- (void)dropboxScanner:(RDMLDropboxScanner *)dropboxScanner didFailLoadingFilesWithError:(NSError *)error;

@end

@interface RDMLDropboxScanner : NSObject

@property (weak, nonatomic) id<RDMLDropboxScannerDelegate> delegate;
@property (nonatomic, readonly, getter = isScanning) BOOL scanning;

- (instancetype)initWithSession:(DBSession *)session;

// Search a path for a keyword
- (void)searchPath:(NSString *)path forKeyword:(NSString *)keyword;
// Search the root "/" for a keyword
- (void)searchForKeyword:(NSString *)keyword;

// List contents at a given path
- (void)listContentsAtPath:(NSString *)path;

- (void)stop;

- (NSUInteger)numberOfFilesForFileType:(RDMLDropboxScannerFileType)fileType;
- (DBMetadata *)fileType:(RDMLDropboxScannerFileType)fileType fileAtIndex:(NSUInteger)itemIndex;

@end
