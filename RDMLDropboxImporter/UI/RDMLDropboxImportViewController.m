//
//  RDMLDropboxImportViewController.m
//  RDMLDropboxBookImporter
//
//  Created by Martin Hwasser on 04/03/14.
//  Copyright (c) 2014 Readmill. All rights reserved.
//

#import "RDMLDropboxImportViewController.h"
#import "RDMLDropboxDownloader.h"
#import "RDMLDropboxScanner.h"
#import "RDMLBlankslateView.h"
#import "RDMLDropboxBrowserViewController.h"
#import "RDMLLockedLoadingView.h"
#import "UIColor+RDMLAdditions.h"
#import "UIImage+RDMLAdditions.h"
#import <DropboxSDK/DropboxSDK.h>

NSString * const RDMLDropboxSessionAuthorizationDidChangeNotification = @"RDMLDropboxSessionAuthorizationDidChangeNotification";

@interface RDMLDropboxImportViewController ()
<
RDMLDropboxBrowserViewControllerDelegate,
RDMLDropboxDownloaderDelegate,
UIActionSheetDelegate
>

@property (strong, nonatomic) RDMLDropboxDownloader *dropboxDownloader;

@property (strong, nonatomic) RDMLLockedLoadingView *downloadingView;
@property (strong, nonatomic) RDMLBlankslateView *blankslateView;
@property (strong, nonatomic) UIButton *connectAccountButton;

@property (strong, nonatomic, readwrite) NSMutableDictionary *selectionDictionary;

@property (strong, nonatomic) UIView *importView;
@property (strong, nonatomic) UIButton *importButton;
@property (strong, nonatomic) UIButton *cancelButton;

@property (copy, nonatomic) NSArray *filesToDownload;
@property (nonatomic) NSUInteger remainingFilesCount;

@property (strong, nonatomic) UINavigationController *navigationBrowserController;
@property (strong, nonatomic) UIActionSheet *actionSheet;

@property (strong, nonatomic) DBSession *session;

@end

@implementation RDMLDropboxImportViewController

+ (void)sessionAuthorizationDidChange
{
    [[NSNotificationCenter defaultCenter] postNotificationName:RDMLDropboxSessionAuthorizationDidChangeNotification
                                                        object:nil];
}

- (void)initRDMLViewController
{
    NSAssert(self.session, @"DBSession is nil");
    self.navigationItem.title = NSLocalizedString(@"Dropbox Import", nil);

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sessionAuthorizationDidChangeNotification:)
                                                 name:RDMLDropboxSessionAuthorizationDidChangeNotification
                                               object:nil];
}

- (instancetype)initWithSession:(DBSession *)session
{
    if (self = [super initWithNibName:nil bundle:nil]) {
        _session = session;
    }
    return self;
}

- (id)init
{
    if (self = [super init]) {
        [self initRDMLViewController];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initRDMLViewController];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self initRDMLViewController];
    }
    return self;
}


#pragma mark -
#pragma mark UIViewController

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.view.backgroundColor = [UIColor whiteColor];

    RDMLDropboxBrowserViewController *dropboxBrowserViewController;
    dropboxBrowserViewController = [[RDMLDropboxBrowserViewController alloc] initWithCurrentPath:@"/"
                                                                                         session:self.session
                                                                                        delegate:self];
    [self setupNavigationItemsForDropboxBrowserViewController:dropboxBrowserViewController];

    self.navigationBrowserController = [[UINavigationController alloc] initWithRootViewController:dropboxBrowserViewController];
    [self addChildViewController:self.navigationBrowserController];
//    CGRect frame = self.view.bounds;
//    self.navigationBrowserController.view.frame = frame;
    [self.view addSubview:self.navigationBrowserController.view];
    [self.navigationBrowserController didMoveToParentViewController:self];

    [self toggleImportView];
    [self.view addSubview:self.importView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self sessionAuthorizationDidChange];
}


#pragma mark -
#pragma mark - Properties

#pragma mark - Selection Dictionary 

- (NSMutableDictionary *)selectionDictionary
{
    if (!_selectionDictionary) {
        _selectionDictionary = [@{} mutableCopy];
    }
    return _selectionDictionary;
}

- (void)clearSelectedFiles
{
    [self.selectionDictionary removeAllObjects];
    [self toggleImportView];
}

#pragma mark -
#pragma mark - Events

- (void)showSettings
{
    if (self.actionSheet.isVisible) {
        [self.actionSheet dismissWithClickedButtonIndex:self.actionSheet.cancelButtonIndex animated:YES];
        return;
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                               destructiveButtonTitle:NSLocalizedString(@"Unlink Dropbox account", nil)
                                                    otherButtonTitles:nil];

    if (!(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
        [actionSheet showInView:self.view];
    } else {
        [actionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    }

    self.actionSheet = actionSheet;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        [self unlinkAccount];
    }
}

- (void)sessionAuthorizationDidChangeNotification:(NSNotification *)notification
{
    [self sessionAuthorizationDidChange];
}

- (void)didTapEditButtonItem:(id)sender
{
    [self showSettings];
}

- (void)didTapCloseButton:(id)sender
{
    BOOL shouldDismiss = YES;
    if ([self.delegate respondsToSelector:@selector(dropboxImportViewControllerShouldDismiss:)]) {
        shouldDismiss = [self.delegate dropboxImportViewControllerShouldDismiss:self];
    }
    if (shouldDismiss) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didTapImportItem:(id)sender
{
    [self importSelectedFiles];
}

- (void)didTapCancelButton:(id)sender
{
    [self cancelImport];
}

- (void)setBlankslateHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (hidden) {
        [self.blankslateView removeFromSuperview];
    } else {
        if (self.blankslateView.superview) return;
        UIView *view = self.navigationBrowserController.topViewController.view;
        CGRect frame = view.bounds;
        CGFloat inset = CGRectGetMaxY(self.navigationBrowserController.navigationBar.frame);
        inset += MIN([UIApplication sharedApplication].statusBarFrame.size.width,
                     [UIApplication sharedApplication].statusBarFrame.size.height);
        frame.origin.y = inset;
        frame.size.height -= inset;
        self.blankslateView.frame = frame;
        [view addSubview:self.blankslateView];
    }
}


#pragma mark -
#pragma mark - Dropbox

- (void)unlinkAccount
{
    [self.session unlinkAll];
    [self sessionAuthorizationDidChange];
}

- (void)sessionAuthorizationDidChange
{
    BOOL linked = [self.session isLinked];
    [self setBlankslateHidden:linked animated:NO];
    [self toggleEditButton];
    if (!linked) {
        [self.navigationBrowserController popToRootViewControllerAnimated:YES];
    } else {
        RDMLDropboxBrowserViewController *rootViewController;
        rootViewController = (RDMLDropboxBrowserViewController *)self.navigationBrowserController.topViewController;
        [rootViewController scanIfNeeded];
    }
}


- (void)didTapLinkAccountButton:(id)sender
{
    [self.session linkFromController:self];
}

- (void)cancelImport
{
    [self setDownloadingViewHidden:YES];
    [self.dropboxDownloader cancelDownloading];
}


#pragma mark - 
#pragma mark - Properties

- (RDMLDropboxDownloader *)dropboxDownloader
{
    if (!_dropboxDownloader && self.session.isLinked) {
        _dropboxDownloader = [[RDMLDropboxDownloader alloc] initWithSession:self.session];
        _dropboxDownloader.delegate = self;
    }
    return _dropboxDownloader;
}


#pragma mark -
#pragma mark - Views

- (RDMLBlankslateView *)blankslateView
{
    if (!_blankslateView) {
        CGFloat inset = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 40.0f : 20.0f;
        _blankslateView = [[RDMLBlankslateView alloc] initWithImage:[UIImage imageNamed:@"rdml-db-importer-logo"]
                                                          titleText:NSLocalizedString(@"Connect to Dropbox", nil)
                                                         detailText:NSLocalizedString(@"You need to connect your Dropbox account before you can continue.", nil)];
        _blankslateView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _blankslateView.contentInset = UIEdgeInsetsMake(0.0f, inset, 0.0f, inset);
        _blankslateView.bottomView = self.connectAccountButton;
        [_blankslateView sizeToFit];
    }
    return _blankslateView;
}

- (UIButton *)connectAccountButton
{
    if (!_connectAccountButton) {
        NSString *title = NSLocalizedString(@"Connect to Dropbox", nil);
        _connectAccountButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _connectAccountButton.titleLabel.font = [UIFont systemFontOfSize:17];
        _connectAccountButton.titleLabel.textColor = [UIColor blueDropboxColor];
        [_connectAccountButton addTarget:self action:@selector(didTapLinkAccountButton:) forControlEvents:UIControlEventTouchUpInside];
        [_connectAccountButton setTitle:title forState:UIControlStateNormal];

        [_connectAccountButton sizeToFit];
        CGRect frame = _connectAccountButton.bounds;
        frame.size.width = MIN(300.0f, CGRectGetWidth(frame)+30.0f);
        frame.size.height = 50;
        _connectAccountButton.bounds = frame;
    }
    return _connectAccountButton;
}


#pragma mark - Downloading View

- (RDMLLockedLoadingView *)downloadingView
{
    if (!_downloadingView) {
        _downloadingView = [RDMLLockedLoadingView new];
    }
    return _downloadingView;
}

- (void)setDownloadingViewHidden:(BOOL)hidden
{
    if (!hidden) {
        [self.view addSubview:self.downloadingView];

        CGRect frame = CGRectZero;
        frame.size = self.importButton.bounds.size;
        frame.origin.x = CGRectGetMidX(self.downloadingView.bounds)-CGRectGetMidX(frame);
        frame.origin.y = CGRectGetHeight(self.downloadingView.bounds)-CGRectGetHeight(frame);
        self.cancelButton.frame = CGRectIntegral(frame);
        [self.downloadingView addSubview:self.cancelButton];
    } else {
        [self.downloadingView removeFromSuperview];
    }
}

- (void)updateDownloadingViewLabelWithRemainingFilesCount:(NSUInteger)count
{
    NSString *text = nil;
    if (count) {
        NSString *fileOrFiles = count > 1 ? @"files" : @"file";
        text = [NSString stringWithFormat:NSLocalizedString(@"Sit tight, %d %@ remaining...", nil), count, fileOrFiles];
    } else {
        text = [NSString stringWithFormat:NSLocalizedString(@"Sit tight, downloading files from Dropbox...", nil), count];
    }

    self.downloadingView.text = text;
}


#pragma mark - Import View

- (UIView *)importView
{
    if (!_importView) {
        _importView = [UIView new];
        _importView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _importView.backgroundColor = [UIColor blueDropboxColor];
        [_importView addSubview:self.importButton];
    }
    return _importView;
}

- (UIButton *)cancelButton
{
    if (!_cancelButton) {
        NSString *title = NSLocalizedString(@"Cancel", nil);
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.backgroundColor = [UIColor whiteColor];
        _cancelButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _cancelButton.titleLabel.font = self.importButton.titleLabel.font;
        [_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(didTapCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        [_cancelButton setTitle:title forState:UIControlStateNormal];
    }
    return _cancelButton;
}


#pragma mark - Import View

- (NSString *)importButtonTitleWithNumberOfItems:(NSUInteger)numberOfItems
{
    NSString *title = NSLocalizedString(@"Import (%d)", nil);
    return [NSString stringWithFormat:title, numberOfItems];
}

- (UIButton *)importButton
{
    if (!_importButton) {
        NSString *title = [self importButtonTitleWithNumberOfItems:self.selectionDictionary.count];
        _importButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_importButton setBackgroundImage:[UIImage imageWithColor:[UIColor blueDropboxColor]] forState:UIControlStateNormal];
        [_importButton setBackgroundImage:[UIImage imageWithColor:[UIColor blackColor]] forState:UIControlStateHighlighted];
        _importButton.titleLabel.textColor = [UIColor whiteColor];
        _importButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _importButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [_importButton addTarget:self action:@selector(didTapImportItem:)
                forControlEvents:UIControlEventTouchUpInside];
        [_importButton setTitle:title forState:UIControlStateNormal];
    }
    return _importButton;
}

- (void)toggleImportView
{
    NSUInteger selectedFiles = self.selectionDictionary.count;
    [self toggleImportViewWithNumberOfItems:selectedFiles animated:YES];
}

- (void)toggleImportViewWithNumberOfItems:(NSUInteger)numberOfItems animated:(BOOL)animated
{
    CGFloat inset = 0.0f;
    CGRect frame = CGRectZero;
    CGRect bounds = self.view.bounds;
    BOOL hidden = numberOfItems == 0;

    NSString *title = [self importButtonTitleWithNumberOfItems:self.selectionDictionary.count];
    [self.importButton setTitle:title forState:UIControlStateNormal];

    [self.importButton sizeToFit];
    frame = self.importButton.bounds;

    frame.size.width = CGRectGetWidth(bounds)-2.0f*inset;
    frame.size.height = 50.0f;
    frame.origin.x = inset;
    frame.origin.y = inset;
    self.importButton.frame = frame;

    frame = CGRectZero;
    frame.size.width = CGRectGetWidth(self.view.bounds);
    frame.size.height = CGRectGetHeight(self.importButton.bounds)+2.0f*inset;
    frame.origin.y = hidden ? CGRectGetHeight(bounds)+self.importView.layer.borderWidth : CGRectGetHeight(bounds)-CGRectGetHeight(frame);

    void(^animationsBlock)(void) = ^ {
        self.importView.frame = CGRectIntegral(frame);
        CGRect frame = self.view.bounds;
        if (!hidden) {
            frame.size.height -= CGRectGetHeight(self.importView.frame);
        }
        self.navigationBrowserController.view.frame = frame;
    };

    if (animated) {
        [UIView animateWithDuration:0.2f animations:animationsBlock];
    } else {
        animationsBlock();
    }
}


#pragma mark -
#pragma mark - RDMLDropboxBrowserViewController

- (RDMLDropboxBrowserViewController *)activeDropboxBrowserViewController
{
    return (RDMLDropboxBrowserViewController *)self.navigationBrowserController.topViewController;
}

- (void)setupNavigationItemsForDropboxBrowserViewController:(RDMLDropboxBrowserViewController *)dropboxBrowserViewController
{
    dropboxBrowserViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                                                  target:self
                                                                                                                  action:@selector(didTapCloseButton:)];
    dropboxBrowserViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                                                   target:self
                                                                                                                   action:@selector(didTapEditButtonItem:)];
    dropboxBrowserViewController.navigationItem.rightBarButtonItem.tintColor = [UIColor blueDropboxColor];
    dropboxBrowserViewController.navigationItem.leftBarButtonItem.tintColor = [UIColor blueDropboxColor];
    [self toggleEditButton];
}

- (void)toggleEditButton
{
    NSArray *viewControllers = self.navigationBrowserController.viewControllers;

    if (viewControllers.count) {
        RDMLDropboxBrowserViewController *rootViewController = self.navigationBrowserController.viewControllers[0];
        rootViewController.navigationItem.rightBarButtonItem.enabled = self.session.isLinked;
    }
}

#pragma mark - RDMLDropboxBrowserViewControllerDelegate

- (void)pushNextDropboxBrowserControllerWithPath:(NSString *)path
{
    [self clearSelectedFiles];

    RDMLDropboxBrowserViewController *nextViewController;
    nextViewController = [[RDMLDropboxBrowserViewController alloc] initWithCurrentPath:path
                                                                               session:self.session
                                                                              delegate:self];
    [self.navigationBrowserController pushViewController:nextViewController animated:YES];
}

- (void)dropboxBrowserViewController:(RDMLDropboxBrowserViewController *)dropboxBrowserViewController
                   didSelectMetadata:(DBMetadata *)metadata
{
    if ([metadata isDirectory]) {
        if ([metadata.path isEqualToString:dropboxBrowserViewController.currentPath]) {
            [self.navigationBrowserController popViewControllerAnimated:YES];
        } else {
            [self pushNextDropboxBrowserControllerWithPath:metadata.path];
        }
    } else {
        [self.selectionDictionary setObject:metadata forKey:metadata.path];
        [self toggleImportView];
    }
}

- (void)dropboxBrowserViewController:(RDMLDropboxBrowserViewController *)dropboxBrowserViewController
                 didDeselectMetadata:(DBMetadata *)metadata
{
    [self.selectionDictionary setValue:nil forKey:metadata.path];
    [self toggleImportView];
}

- (BOOL)dropboxBrowserViewController:(RDMLDropboxBrowserViewController *)dropboxBrowserViewController
                  isMetadataSelected:(DBMetadata *)metadata
{
    return [self.selectionDictionary valueForKey:metadata.path] != nil;
}

- (void)dropboxBrowserViewControllerDidGoBack:(RDMLDropboxBrowserViewController *)dropboxBrowserViewController
{
    [self cancelImport];
    [self clearSelectedFiles];
}


#pragma mark -
#pragma mark Downloading

- (void)importSelectedFiles
{
    self.remainingFilesCount = self.selectionDictionary.count;

    NSMutableArray *files = [NSMutableArray new];
    for (NSString *key in self.selectionDictionary.allKeys) {
        DBMetadata *metadata = [self.selectionDictionary objectForKey:key];
        [files addObject:metadata];
    }

    self.filesToDownload = [files copy];

    NSURL *importURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    if ([self.delegate respondsToSelector:@selector(urlForDropboxImportViewController:)]) {
        NSURL *potentialImportURL = [self.delegate urlForDropboxImportViewController:self];
        BOOL isDir;
        if ([potentialImportURL isKindOfClass:[NSURL class]] && [[NSFileManager defaultManager] fileExistsAtPath:potentialImportURL.path
                                                                                                     isDirectory:&isDir] && isDir) {
            importURL = potentialImportURL;
        }
    }
    [self.dropboxDownloader downloadFiles:files toPath:importURL.path];
}

#pragma mark -
#pragma mark RDMLDropboxDownloaderDelegate

- (void)dropboxDownloaderDidStartDownloading:(RDMLDropboxDownloader *)dropboxDownloader
{
    [self setDownloadingViewHidden:NO];
    [self updateDownloadingViewLabelWithRemainingFilesCount:self.remainingFilesCount];

    if ([self.delegate respondsToSelector:@selector(dropboxImportViewController:willStartDownloadingFiles:)]) {
        [self.delegate dropboxImportViewController:self willStartDownloadingFiles:self.filesToDownload];
    }
}

- (void)dropboxDownloaderDidFinishDownloading:(RDMLDropboxDownloader *)dropboxDownloader
{
    [self setDownloadingViewHidden:YES];

    if ([self.delegate respondsToSelector:@selector(dropboxImportViewController:didFinishDownloadingFiles:)]) {
        [self.delegate dropboxImportViewController:self didFinishDownloadingFiles:self.filesToDownload];
    }

    [self.selectionDictionary removeAllObjects];
    [self toggleImportView];
}

- (void)dropboxDownloader:(RDMLDropboxDownloader *)dropboxDownloader didDownloadFile:(DBMetadata *)file atPath:(NSString *)path
{
    self.remainingFilesCount--;
    [self updateDownloadingViewLabelWithRemainingFilesCount:self.remainingFilesCount];

    if ([self.delegate respondsToSelector:@selector(dropboxImportViewController:didDownloadFile:toPath:)]) {
        [self.delegate dropboxImportViewController:self didDownloadFile:file toPath:path];
    }
}

- (void)dropboxDownloader:(RDMLDropboxDownloader *)dropboxDownloader didFailDownloadingFileWithError:(NSError *)error
{
    self.remainingFilesCount--;
    [self updateDownloadingViewLabelWithRemainingFilesCount:self.remainingFilesCount];

    if ([self.delegate respondsToSelector:@selector(dropboxImportViewController:didFailToImportFileWithError:)]) {
        [self.delegate dropboxImportViewController:self didFailToImportFileWithError:error];
    }
}

@end
