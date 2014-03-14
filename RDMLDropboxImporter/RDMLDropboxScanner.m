//
//  RDMLDropboxScanner.m
//  Readmill
//
//  Created by Martin Hwasser on 07/03/14.
//  Copyright (c) 2014 Readmill. All rights reserved.
//

#import "RDMLDropboxScanner.h"
#import <DropboxSDK/DropboxSDK.h>

@interface RDMLDropboxScanner () <DBRestClientDelegate>

@property (nonatomic, getter = isScanning) BOOL scanning;
@property (strong, nonatomic) NSMutableDictionary *items;
@property (strong, nonatomic) DBSession *session;
@property (strong, nonatomic) DBRestClient *client;
@property (nonatomic) dispatch_group_t scanningGroup;

@end

@implementation RDMLDropboxScanner

#pragma mark -
#pragma mark Initialization

- (instancetype)initWithSession:(DBSession *)session
{
    if (self = [super init]) {
        _session = session;
        [self initRDMLDropboxScanner];
    }
    return self;
}

- (void)initRDMLDropboxScanner
{
    if (!_session) {
        _session = [DBSession sharedSession];
    }
    NSAssert([_session isLinked], @"DBSession must be linked before creating DBRestClient objects");
    _client = [[DBRestClient alloc] initWithSession:_session];
    _client.delegate = self;
    _items = [NSMutableDictionary dictionary];
}

#pragma mark -
#pragma mark Data source methods

- (void)resetDataSource
{
    [self.items removeAllObjects];
}

- (NSUInteger)numberOfFileTypes
{
    return [[self.items allKeys] count];
}

- (NSUInteger)numberOfFilesForFileType:(RDMLDropboxScannerFileType)fileType
{
    NSArray *files = [self.items objectForKey:@(fileType)];
    return [files count];
}

- (NSArray *)filesForFileType:(RDMLDropboxScannerFileType)fileType
{
    return [self.items objectForKey:@(fileType)];
}

- (DBMetadata *)fileType:(RDMLDropboxScannerFileType)fileType fileAtIndex:(NSUInteger)itemIndex
{
    NSArray *files = [self.items objectForKey:@(fileType)];
    return [files objectAtIndex:itemIndex];
}

- (void)addFile:(DBMetadata *)file forFileType:(RDMLDropboxScannerFileType)fileType
{
    NSMutableArray *files = [self.items objectForKey:@(fileType)];
    if (!files) {
        files = [NSMutableArray array];
        [self.items setObject:files forKey:@(fileType)];
    }
    [files addObject:file];
}

- (void)addFiles:(NSArray *)addFiles forFileType:(RDMLDropboxScannerFileType)fileType
{
    NSMutableArray *files = [self.items objectForKey:@(fileType)];
    if (!files) {
        files = [NSMutableArray array];
        [self.items setObject:files forKey:@(fileType)];
    }
    [files addObjectsFromArray:addFiles];
}

- (void)removeAllFilesForFileType:(RDMLDropboxScannerFileType)fileType
{
    [self.items setObject:[NSMutableArray array] forKey:@(fileType)];
}

#pragma mark -
#pragma mark Scanning methods

- (void)searchForKeyword:(NSString *)keyword
{
    [self searchPath:@"/" forKeyword:keyword];
}

- (void)searchPath:(NSString *)path forKeyword:(NSString *)keyword
{
    if (self.scanning) {
        return;
    }

    self.scanning = YES;
    self.scanningGroup = dispatch_group_create();
    [self resetDataSource];

    if ([self.delegate respondsToSelector:@selector(dropboxScannerDidStartScanning:)]) {
        [self.delegate dropboxScannerDidStartScanning:self];
    }

    dispatch_group_enter(self.scanningGroup);
    [self.client searchPath:path forKeyword:keyword];

    dispatch_group_notify(self.scanningGroup, dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(dropboxScannerDidFinishScanning:)]) {
            [self.delegate dropboxScannerDidFinishScanning:self];
        }
    });
}

- (void)listContentsAtPath:(NSString *)path
{
    if (self.scanning) {
        return;
    }

    self.scanning = YES;
    self.scanningGroup = dispatch_group_create();
    [self resetDataSource];

    if ([self.delegate respondsToSelector:@selector(dropboxScannerDidStartScanning:)]) {
        [self.delegate dropboxScannerDidStartScanning:self];
    }

    dispatch_group_enter(self.scanningGroup);
    [self.client loadMetadata:path];

    dispatch_group_notify(self.scanningGroup, dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(dropboxScannerDidFinishScanning:)]) {
            [self.delegate dropboxScannerDidFinishScanning:self];
        }
    });
}

- (void)stop
{
    self.scanning = NO;
    self.scanningGroup = nil;
    [self.client cancelAllRequests];
}


#pragma mark -
#pragma mark DBRestClientDelegate


#pragma mark - Search

- (void)restClient:(DBRestClient *)restClient loadedSearchResults:(NSArray *)results forPath:(NSString *)path keyword:(NSString *)keyword
{    
    // Sort results by last modified date.
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastModifiedDate" ascending:NO];
    results = [results sortedArrayUsingDescriptors:@[sortDescriptor]];

    for (DBMetadata *metadata in results) {
        [self addFile:metadata forFileType:[metadata isDirectory] ? RDMLDropboxScannerFileTypeDirectory : RDMLDropboxScannerFileTypeFile];
    }

    if ([self.delegate respondsToSelector:@selector(dropboxScanner:didLoadFiles:)]) {
        [self.delegate dropboxScanner:self didLoadFiles:results];
    }

    dispatch_group_leave(self.scanningGroup);
}

- (void)restClient:(DBRestClient *)client searchFailedWithError:(NSError *)error
{
    dispatch_group_leave(self.scanningGroup);
    
    if ([self.delegate respondsToSelector:@selector(dropboxScanner:didFailLoadingFilesWithError:)]) {
        [self.delegate dropboxScanner:self didFailLoadingFilesWithError:error];
    }
}


#pragma mark - List

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata
{
    for (DBMetadata *subMetadata in metadata.contents) {
        RDMLDropboxScannerFileType fileType = [subMetadata isDirectory] ? RDMLDropboxScannerFileTypeDirectory : RDMLDropboxScannerFileTypeFile;
        [self addFile:subMetadata forFileType:fileType];
    }

    self.scanning = NO;
    dispatch_group_leave(self.scanningGroup);
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error
{
    self.scanning = NO;
    dispatch_group_leave(self.scanningGroup);

    if ([self.delegate respondsToSelector:@selector(dropboxScanner:didFailLoadingFilesWithError:)]) {
        [self.delegate dropboxScanner:self didFailLoadingFilesWithError:error];
    }
}

@end
