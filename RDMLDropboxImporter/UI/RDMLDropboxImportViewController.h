//
//  RDMLViewController.h
//  RDMLDropboxBookImporter
//
//  Created by Martin Hwasser on 04/03/14.
//  Copyright (c) 2014 Readmill. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RDMLDropboxImportViewController;
@class DBMetadata;
@class DBSession;

extern NSString * const RDMLDropboxSessionAuthorizationDidChangeNotification;

@protocol RDMLDropboxImportViewControllerDelegate <NSObject>

@optional

- (void)dropboxImportViewController:(RDMLDropboxImportViewController *)dropboxImportViewController
          willStartDownloadingFiles:(NSArray *)files;
- (void)dropboxImportViewController:(RDMLDropboxImportViewController *)dropboxImportViewController
                    didDownloadFile:(DBMetadata *)file
                             toPath:(NSString *)path;
- (void)dropboxImportViewController:(RDMLDropboxImportViewController *)dropboxImportViewController
          didFinishDownloadingFiles:(NSArray *)files;
- (void)dropboxImportViewController:(RDMLDropboxImportViewController *)dropboxImportViewController
       didFailToImportFileWithError:(NSError *)error;

- (BOOL)dropboxImportViewControllerShouldDismiss:(RDMLDropboxImportViewController *)dropboxImportViewController;

- (NSURL *)urlForDropboxImportViewController:(RDMLDropboxImportViewController *)dropboxImportViewController;

@end

@interface RDMLDropboxImportViewController : UIViewController

@property (strong, nonatomic, readonly) NSMutableDictionary *selectionDictionary;
@property (weak, nonatomic) id<RDMLDropboxImportViewControllerDelegate> delegate;
@property (strong, nonatomic, readonly) DBSession *session;

+ (void)sessionAuthorizationDidChange;

- (instancetype)initWithSession:(DBSession *)session;

// Call this method if session becomes linked/unlinked to update the UI
- (void)sessionAuthorizationDidChange;

// Cancels any ongoing import (download)
- (void)cancelImport;

@end
