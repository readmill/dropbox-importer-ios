//
//  RDMLDropboxDownloader.m
//  Readmill
//
//  Created by Martin Hwasser on 07/03/14.
//  Copyright (c) 2014 Readmill. All rights reserved.
//

#import <DropboxSDK/DropboxSDK.h>
#import "RDMLDropboxDownloader.h"

@interface RDMLDropboxDownloader () <DBRestClientDelegate>

@property (nonatomic, getter = isDownloading) BOOL downloading;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) DBSession *session;
@property (strong, nonatomic) DBRestClient *client;
@property (nonatomic) dispatch_group_t downloadingGroup;

@end

@implementation RDMLDropboxDownloader

- (id)init
{
    if (self = [super init]) {
        [self initRDMLDropboxDownloader];
    }
    return self;
}

- (instancetype)initWithSession:(DBSession *)session
{
    if (self = [super init]) {
        [self initRDMLDropboxDownloader];
    }
    return self;
}

- (void)initRDMLDropboxDownloader
{
    if (!_session) {
        _session = [DBSession sharedSession];
    }
    NSAssert([_session isLinked], @"DBSession must be linked before creating DBRestClient objects");
    _client = [[DBRestClient alloc] initWithSession:_session];
    _client.delegate = self;
}

#pragma mark -
#pragma mark Downloading

- (BOOL)downloadFiles:(NSArray *)files toPath:(NSString *)path
{
    if (self.downloading) {
        return NO;
    }
    
    self.downloading = YES;
    self.downloadingGroup = dispatch_group_create();
    self.path = path;
    
    if ([self.delegate respondsToSelector:@selector(dropboxDownloaderDidStartDownloading:)]) {
        [self.delegate dropboxDownloaderDidStartDownloading:self];
    }
    
    for (DBMetadata *file in files) {
        [self downloadFile:file toPath:path];
    }
    
    dispatch_group_notify(self.downloadingGroup, dispatch_get_main_queue(), ^{
        self.downloading = NO;
        if ([self.delegate respondsToSelector:@selector(dropboxDownloaderDidFinishDownloading:)]) {
            [self.delegate dropboxDownloaderDidFinishDownloading:self];
        }
    });
    
    return YES;
}

- (void)downloadFile:(DBMetadata *)file toPath:(NSString *)path
{
    dispatch_group_enter(self.downloadingGroup);
    
    NSString *fileName = file.filename.lastPathComponent;
    NSString *filePath = [self.path stringByAppendingPathComponent:fileName];
    
    [self.client loadFile:file.path intoPath:filePath];
}

- (void)cancelDownloading
{
    [self.client cancelAllRequests];
    self.downloading = NO;
}


#pragma mark -
#pragma mark DBRestClientDelegate

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath contentType:(NSString *)contentType metadata:(DBMetadata *)metadata
{
    dispatch_group_leave(self.downloadingGroup);
    if ([self.delegate respondsToSelector:@selector(dropboxDownloader:didDownloadFile:atPath:)]) {
        [self.delegate dropboxDownloader:self didDownloadFile:metadata atPath:destPath];
    }
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error
{
    dispatch_group_leave(self.downloadingGroup);
    if ([self.delegate respondsToSelector:@selector(dropboxDownloader:didFailDownloadingFileWithError:)]) {
        [self.delegate dropboxDownloader:self didFailDownloadingFileWithError:error];
    }
}

@end
