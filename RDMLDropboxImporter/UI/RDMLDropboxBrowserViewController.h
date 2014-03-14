//
//  RDMLDropboxBrowserViewController.h
//  RDMLDropboxBookImporter
//
//  Created by Martin Hwasser on 06/03/14.
//  Copyright (c) 2014 Readmill. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RDMLDropboxScanner;
@class DBMetadata;
@class RDMLDropboxBrowserViewController;
@class RDMLLoadingView;
@class DBSession;

@protocol RDMLDropboxBrowserViewControllerDelegate <NSObject>

- (void)dropboxBrowserViewController:(RDMLDropboxBrowserViewController *)dropboxBrowserViewController
                   didSelectMetadata:(DBMetadata *)metadata;
- (void)dropboxBrowserViewController:(RDMLDropboxBrowserViewController *)dropboxBrowserViewController
                 didDeselectMetadata:(DBMetadata *)metadata;
- (BOOL)dropboxBrowserViewController:(RDMLDropboxBrowserViewController *)dropboxBrowserViewController
                  isMetadataSelected:(DBMetadata *)metadata;
- (void)dropboxBrowserViewControllerDidGoBack:(RDMLDropboxBrowserViewController *)dropboxBrowserViewController;

@end

@interface RDMLDropboxBrowserViewController : UIViewController

@property (copy, nonatomic) NSString *currentPath;
@property (strong, nonatomic) DBSession *session;
@property (strong, nonatomic, readonly) RDMLDropboxScanner *dropboxScanner;
@property (strong, nonatomic) UITableView *tableView;
@property (weak, nonatomic) id<RDMLDropboxBrowserViewControllerDelegate> delegate;
@property (strong, nonatomic) UIActivityIndicatorView *loadingView;

- (instancetype)initWithCurrentPath:(NSString *)currentPath
                            session:(DBSession *)session
                           delegate:(id<RDMLDropboxBrowserViewControllerDelegate>)delegate;
- (void)scanIfNeeded;

@end
