//
//  RDMLDropboxBrowserViewController.m
//  RDMLDropboxBookImporter
//
//  Created by Martin Hwasser on 06/03/14.
//  Copyright (c) 2014 Readmill. All rights reserved.
//

#import "RDMLDropboxBrowserViewController.h"
#import "RDMLDropboxScanner.h"
#import "RDMLDropboxDirectoryCell.h"
#import "RDMLDropboxFileCell.h"
#import "NSDate+RDMLAdditions.h"
#import "UIColor+RDMLAdditions.h"
#import "RDMLLoadingView.h"
#import "RDMLBlankslateView+RDMLAdditions.h"
#import "RDMLDropboxMetadataViewModel.h"
#import <DropboxSDK/DropboxSDK.h>

#define kRDMLDropboxBrowserCellHeight 50
#define kRDMLHeaderViewHeight 40

@interface RDMLDropboxBrowserViewController ()
<
RDMLDropboxScannerDelegate,
UITableViewDataSource,
UITableViewDelegate,
UISearchBarDelegate,
UISearchDisplayDelegate
>

@property (strong, nonatomic, readwrite) RDMLDropboxScanner *dropboxScanner;
@property (strong, nonatomic, readwrite) RDMLDropboxScanner *dropboxSearcher;

@property (nonatomic) BOOL hasScanned;
@property (strong, nonatomic) UISearchDisplayController *dropboxSearchDisplayController;

@property (strong, nonatomic) RDMLBlankslateView *blankslateNetworkError;
@property (strong, nonatomic) UIButton *selectAllButton;

@end

@implementation RDMLDropboxBrowserViewController

- (instancetype)initWithCurrentPath:(NSString *)currentPath
                            session:(DBSession *)session
                           delegate:(id<RDMLDropboxBrowserViewControllerDelegate>)delegate
{
    if (self = [self init]) {
        _currentPath = currentPath;
        _delegate = delegate;
        _session = session;
    }
    return self;
}


#pragma mark -
#pragma mark - UIView lifecycle


- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

   [self.view addSubview:self.tableView];

    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.delegate = self;

    UISearchDisplayController *dropboxSearchDisplayController;
    dropboxSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar
                                                                       contentsController:self];

    dropboxSearchDisplayController.searchResultsDataSource = self;
    dropboxSearchDisplayController.searchResultsDelegate = self;
    dropboxSearchDisplayController.delegate = self;

    NSArray *tableViews = @[self.tableView, dropboxSearchDisplayController.searchResultsTableView];
    for (UITableView *tableView in tableViews) {
        [tableView registerClass:[RDMLDropboxDirectoryCell class]
          forCellReuseIdentifier:RDMLDropboxDirectoryCellIdentifier];
        [tableView registerClass:[RDMLDropboxFileCell class]
          forCellReuseIdentifier:RDMLDropboxFileCellIdentifier];
        tableView.delegate = self;
        tableView.allowsMultipleSelection = YES;
        tableView.rowHeight = kRDMLDropboxBrowserCellHeight;
    }

    self.dropboxSearchDisplayController = dropboxSearchDisplayController;
    self.tableView.tableHeaderView = searchBar;

    if ([self.currentPath isEqualToString:@"/"]) {
        // TODO ugly hack
        self.title = @"Dropbox";
    } else {
        self.title = self.currentPath.lastPathComponent;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self scanIfNeeded];
    [self toggleSelectionButton];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [self.delegate dropboxBrowserViewControllerDidGoBack:self];
    }
}

#pragma mark -
#pragma mark - Properties

- (RDMLBlankslateView *)blankslateNetworkError
{
    if (!_blankslateNetworkError) {
        self.blankslateNetworkError = [RDMLBlankslateView blankslateNetworkError];
        _blankslateNetworkError.backgroundColor = [UIColor whiteColor];
        CGRect frame = self.tableView.frame;
        _blankslateNetworkError.frame = frame;
        _blankslateNetworkError.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return _blankslateNetworkError;
}

- (UIActivityIndicatorView *)loadingView
{
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_loadingView startAnimating];
    }
    return _loadingView;
}

- (void)addLoadingView
{
    UITableView *activeTableView;
    if (self.searchDisplayController.isActive) {
        activeTableView = self.searchDisplayController.searchResultsTableView;
    } else {
        activeTableView = self.tableView;
    }
    CGRect frame = self.loadingView.frame;
    frame.origin.x = CGRectGetMidX(activeTableView.frame) - CGRectGetWidth(self.loadingView.frame) / 2.0f;
    frame.origin.y = CGRectGetMinY(activeTableView.tableHeaderView.frame);

    if (activeTableView != self.searchDisplayController.searchResultsTableView) {
        frame.origin.y += self.searchDisplayController.searchBar.frame.size.height;
    }
    frame.origin.y += 1.5f * kRDMLDropboxBrowserCellHeight - CGRectGetHeight(self.loadingView.frame) / 2.0f;
    self.loadingView.frame = frame;
    [activeTableView addSubview:self.loadingView];
}

- (RDMLDropboxScanner *)dropboxScanner
{
    if (!_dropboxScanner && self.session.isLinked) {
        _dropboxScanner = [[RDMLDropboxScanner alloc] initWithSession:self.session];
        _dropboxScanner.delegate = self;
    }
    return _dropboxScanner;
}

- (RDMLDropboxScanner *)dropboxSearcher
{
    if (!_dropboxSearcher && self.session.isLinked) {
        _dropboxSearcher = [[RDMLDropboxScanner alloc] initWithSession:self.session];
        _dropboxSearcher.delegate = self;
    }
    return _dropboxSearcher;
}


#pragma mark - 
#pragma mark - Methods

- (void)scanIfNeeded
{
    if ([self.session isLinked] && !self.hasScanned && !self.dropboxScanner.isScanning) {
        self.hasScanned = YES;
        [self.dropboxScanner listContentsAtPath:self.currentPath];
    }
}


#pragma mark - Events

- (void)didTapBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)toggleSelectionButton
{
    NSInteger selectedRows = self.tableView.indexPathsForSelectedRows.count;
    NSInteger possibleSelections = [self.dropboxScanner numberOfFilesForFileType:RDMLDropboxScannerFileTypeFile];

    self.selectAllButton.selected = selectedRows == possibleSelections && 0 < selectedRows && possibleSelections != 0;
}

- (void)didTapSelectAllButton:(id)sender
{
    self.selectAllButton.selected = !self.selectAllButton.selected;

    if (self.selectAllButton.selected) {
        [self selectAllFiles];
    } else {
        [self deselectAllFiles];
    }

    [self toggleSelectionButton];
}

- (void)selectAllFiles
{
    RDMLDropboxScannerFileType fileType;
    NSUInteger numberOfFiles;

    fileType = RDMLDropboxScannerFileTypeFile;
    numberOfFiles = [self.dropboxScanner numberOfFilesForFileType:fileType];

    for (NSInteger i = 0; i < numberOfFiles; i++) {
        DBMetadata *metadata = [self.dropboxScanner fileType:fileType fileAtIndex:i];
        [self.delegate dropboxBrowserViewController:self didSelectMetadata:metadata];

        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:fileType];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)deselectAllFiles
{
    NSArray *indexPaths = self.tableView.indexPathsForSelectedRows;
    for (NSIndexPath *indexPath in indexPaths) {
        DBMetadata *metadata = [self.dropboxScanner fileType:indexPath.section fileAtIndex:indexPath.row];
        [self.delegate dropboxBrowserViewController:self didDeselectMetadata:metadata];
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark -
#pragma mark RDMLDropboxScannerDelegate

- (void)dropboxScannerDidStartScanning:(RDMLDropboxScanner *)dropboxScanner
{
    [self addLoadingView];
    [self.blankslateNetworkError removeFromSuperview];
}

- (void)dropboxScanner:(RDMLDropboxScanner *)dropboxScanner didLoadFiles:(NSArray *)files
{

}

- (void)dropboxScannerDidFinishScanning:(RDMLDropboxScanner *)dropboxScanner
{
    if (dropboxScanner == self.dropboxSearcher) {
        [self.searchDisplayController.searchResultsTableView reloadData];
    } else {
        [self.tableView reloadData];
    }

    [self.loadingView removeFromSuperview];
}

- (void)dropboxScanner:(RDMLDropboxScanner *)dropboxScanner didFailLoadingFilesWithError:(NSError *)error
{
    [self.view addSubview:self.blankslateNetworkError];
}

#pragma mark -
#pragma mark - UICollectionView

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return RDMLDropboxScannerFileTypeNumberOfFileTypes;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count;
    if (self.searchDisplayController.searchResultsTableView == tableView) {
        count = [self.dropboxSearcher numberOfFilesForFileType:section];
    } else {
        count = [self.dropboxScanner numberOfFilesForFileType:section];
        if (count) {
            [self toggleSelectionButton];
        }
    }

    return count;
}

- (RDMLDropboxMetadataViewModel *)dropboxMetadataViewModelAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView
{
    DBMetadata *metadata = [self metadataAtIndexPath:indexPath inTableView:tableView];
    RDMLDropboxMetadataViewModel *viewModel = [[RDMLDropboxMetadataViewModel alloc] initWithMetadata:metadata
                                                                                         currentPath:self.currentPath];
    return viewModel;
}

- (DBMetadata *)metadataAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView
{
    DBMetadata *metadata;
    if (self.tableView == tableView) {
        metadata = [self.dropboxScanner fileType:indexPath.section fileAtIndex:indexPath.row];
    } else {
        metadata = [self.dropboxSearcher fileType:indexPath.section fileAtIndex:indexPath.row];
    }
    return metadata;
}

- (void)configureCell:(UITableViewCell *)cell withViewModel:(RDMLDropboxMetadataViewModel *)viewModel
{
    cell.textLabel.text = viewModel.text;
    cell.detailTextLabel.text = viewModel.detailText;
    cell.imageView.image = viewModel.image;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBMetadata *metadata = [self metadataAtIndexPath:indexPath inTableView:tableView];

    if (indexPath.section == RDMLDropboxScannerFileTypeFile) {
        RDMLDropboxFileCell *cell;
        cell = (RDMLDropboxFileCell *)[tableView dequeueReusableCellWithIdentifier:RDMLDropboxFileCellIdentifier
                                                                      forIndexPath:indexPath];
        RDMLDropboxMetadataViewModel *viewModel = [self dropboxMetadataViewModelAtIndexPath:indexPath
                                                                                inTableView:tableView];
        [self configureCell:cell withViewModel:viewModel];
        BOOL selected = [self.delegate dropboxBrowserViewController:self isMetadataSelected:metadata];
        if (selected) {
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        return cell;
    } else {
        RDMLDropboxDirectoryCell *cell;
        cell = (RDMLDropboxDirectoryCell *)[tableView dequeueReusableCellWithIdentifier:RDMLDropboxDirectoryCellIdentifier
                                                                           forIndexPath:indexPath];

        RDMLDropboxMetadataViewModel *viewModel = [self dropboxMetadataViewModelAtIndexPath:indexPath
                                                                                inTableView:tableView];
        [self configureCell:cell withViewModel:viewModel];
        if (viewModel.hidesDisclosureIndicator) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) return 0;
    return kRDMLHeaderViewHeight;
}

static CGFloat tableViewHeaderInsetX = 15;

- (UIButton *)selectAllButton
{
    if (!_selectAllButton) {
        UIButton *selectAllButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.selectAllButton = selectAllButton;
        selectAllButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [selectAllButton setTitle:[NSLocalizedString(@"Select files", nil) uppercaseString] forState:UIControlStateNormal];
        [selectAllButton setTitle:[NSLocalizedString(@"Deselect files", nil) uppercaseString] forState:UIControlStateSelected];
        [selectAllButton setTitleColor:[UIColor blueDropboxColor] forState:UIControlStateNormal];
        [selectAllButton addTarget:self action:@selector(didTapSelectAllButton:) forControlEvents:UIControlEventTouchUpInside];
        [selectAllButton sizeToFit];
        CGFloat inset = tableViewHeaderInsetX;
        CGRect selectAllButtonFrame = CGRectInset(self.selectAllButton.frame, -inset, -inset);
        self.selectAllButton.frame = selectAllButtonFrame;
        [self toggleSelectionButton];
    }
    return _selectAllButton;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat headerHeight = [tableView.delegate tableView:tableView heightForHeaderInSection:section];
    if (headerHeight == 0) return nil;

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, headerHeight)];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];

    UILabel *label = [UILabel new];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:12];
    if (section == RDMLDropboxScannerFileTypeFile) {
        label.text = [NSLocalizedString(@"Files", nil) uppercaseString];
        CGSize selectAllButtonSize = self.selectAllButton.frame.size;
        CGRect selectAllButtonFrame;
        selectAllButtonFrame = CGRectMake(CGRectGetWidth(tableView.frame) - selectAllButtonSize.width,
                                          CGRectGetHeight(view.frame) / 2.0f - selectAllButtonSize.height / 2.0f,
                                          selectAllButtonSize.width, selectAllButtonSize.height);
        self.selectAllButton.frame = selectAllButtonFrame;
        [view addSubview:self.selectAllButton];
    } else {
        label.text = [NSLocalizedString(@"Folders", nil) uppercaseString];
    }

    [label sizeToFit];
    CGRect frame = label.frame;
    frame.origin.x = tableViewHeaderInsetX;
    frame.origin.y = headerHeight / 2.0f - frame.size.height / 2.0f;
    label.frame = frame;
    [view addSubview:label];

    CGFloat dividerHeight = 1.0f / [UIScreen mainScreen].scale;

    if (0 < section) {
        frame = view.frame;
        frame.origin.y = 0;
        frame.size.height = dividerHeight;
        UIView *topDividerView = [[UIView alloc] initWithFrame:frame];
        topDividerView.backgroundColor = tableView.separatorColor;
        [view addSubview:topDividerView];
    }

    frame = view.frame;
    frame.origin.y = CGRectGetHeight(frame) - dividerHeight;
    frame.size.height = dividerHeight;
    UIView *bottomDividerView = [[UIView alloc] initWithFrame:frame];
    bottomDividerView.backgroundColor = tableView.separatorColor;
    [view addSubview:bottomDividerView];

    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBMetadata *metadata = [self metadataAtIndexPath:indexPath inTableView:tableView];
    [self.delegate dropboxBrowserViewController:self didSelectMetadata:metadata];

    if (![metadata isDirectory]) {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }

    [self toggleSelectionButton];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBMetadata *metadata = [self metadataAtIndexPath:indexPath inTableView:tableView];
    [self.delegate dropboxBrowserViewController:self didDeselectMetadata:metadata];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self toggleSelectionButton];
}


#pragma mark - 
#pragma mark - UISearchDisplayController

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self.dropboxSearcher stop];
    self.dropboxSearcher = nil;
    [self.searchDisplayController.searchResultsTableView reloadData];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.dropboxSearcher searchForKeyword:searchBar.text];
}


@end
