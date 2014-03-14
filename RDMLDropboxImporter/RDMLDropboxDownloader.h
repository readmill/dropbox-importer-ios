//
//  RDMLDropboxDownloader.h
//  Readmill
//
//  Created by Martin Hwasser on 07/03/14.
//  Copyright (c) 2014 Readmill. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBSession;
@class DBMetadata;
@class RDMLDropboxDownloader;

@protocol RDMLDropboxDownloaderDelegate <NSObject>

@optional

- (void)dropboxDownloaderDidStartDownloading:(RDMLDropboxDownloader *)dropboxDownloader;
- (void)dropboxDownloaderDidFinishDownloading:(RDMLDropboxDownloader *)dropboxDownloader;
- (void)dropboxDownloader:(RDMLDropboxDownloader *)dropboxDownloader didDownloadFile:(DBMetadata *)file atPath:(NSString *)path;
- (void)dropboxDownloader:(RDMLDropboxDownloader *)dropboxDownloader didFailDownloadingFileWithError:(NSError *)error;

@end

@interface RDMLDropboxDownloader : NSObject

@property (weak, nonatomic) id<RDMLDropboxDownloaderDelegate> delegate;

- (instancetype)initWithSession:(DBSession *)session;

// Returns NO if currently downloading
- (BOOL)downloadFiles:(NSArray *)files toPath:(NSString *)path;
- (void)cancelDownloading;

@end
