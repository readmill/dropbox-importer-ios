//
//  RDMLViewController.m
//  RDMLDropboxImporter
//
//  Created by Martin Hwasser on 11/03/14.
//  Copyright (c) 2014 Readmill. All rights reserved.
//

#import "RDMLViewController.h"
#import "RDMLDropboxImportViewController.h"
#import "DBSession+Additions.h"

@interface RDMLViewController () <RDMLDropboxImportViewControllerDelegate>

@property (strong, nonatomic) RDMLDropboxImportViewController *dropboxImportViewController;

@end

@implementation RDMLViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dropboxSessionAuthorizationDidChange:)
                                                 name:RDMLDropboxSessionAuthorizationDidChangeNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (self.presentingViewController == nil) {
        RDMLDropboxImportViewController *dropboxImportViewController;
        [DBSession setSharedSessionIfNeeded];
        
        dropboxImportViewController = [[RDMLDropboxImportViewController alloc] initWithSession:[DBSession sharedSession]];
        dropboxImportViewController.delegate = self;

        self.dropboxImportViewController = dropboxImportViewController;
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:dropboxImportViewController];
        nc.navigationBarHidden = YES;
        [self presentViewController:nc animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark - Dropbox

- (void)dropboxSessionAuthorizationDidChange:(NSNotification *)notification
{
    [self.dropboxImportViewController sessionAuthorizationDidChange];
}

#pragma mark - 
#pragma mark - RDMLDropboxImportViewController

- (NSString *)pathToDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths.lastObject;
}

- (NSURL *)urlForDropboxImportViewController:(RDMLDropboxImportViewController *)dropboxImportViewController
{
    return [NSURL fileURLWithPath:[self pathToDocumentsDirectory]];
}

- (void)dropboxImportViewController:(RDMLDropboxImportViewController *)dropboxImportViewController
          didFinishDownloadingFiles:(NSArray *)files
{
    [self showImportFinishAlert];
}

- (void)dropboxImportViewController:(RDMLDropboxImportViewController *)dropboxImportViewController
                    didDownloadFile:(DBMetadata *)file
                             toPath:(NSString *)path
{
    NSLog(@"did download file: %@ to path: %@", [file filename], path);
}

- (void)dropboxImportViewController:(RDMLDropboxImportViewController *)dropboxImportViewController
       didFailToImportFileWithError:(NSError *)error
{
    [dropboxImportViewController cancelImport];
    [self showImportErrorAlert];
}

- (void)showImportErrorAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Import failed", nil)
                                                        message:NSLocalizedString(@"One or more selected files could not be imported.", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)showImportFinishAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Import completed", nil)
                                                        message:NSLocalizedString(@"Selected files have been imported.", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
    [alertView show];
}

@end
