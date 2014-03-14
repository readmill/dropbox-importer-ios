Dropbox Importer for iOS
====================

This Dropbox Importer uses Dropbox Core API allowing for easy browsing, searching and downloading of files using the Dropbox SDK.
There are primarily two classes for communicating with the Dropbox SDK: `RDMLDropboxScanner` and `RDMLDropboxDownloader`

There's also a complete package with UI leveraging `RDMLDropboxScanner` and `RDMLDropboxDownloader` which can be used as is or for inspiration.

* `RDMLDropboxScanner` is responsible for scanning / searching the Dropbox file structure. 
* `RDMLDropboxDownloader` takes a set of `DBMetadata` objects and downloads to the specified path using `-downloadFiles:toPath:`.

###Using the UI (aka `RDMLDropboxImportViewController`)

Import `RDMLDropboxImportViewController.h` in the presenting view controller. Initialize it with a `DBSession` (linked or not) and present it using `presentViewController:animated:completion:`. If the `DBSession` is not linked, the `RDMLDropboxImportViewController` will display a blank slate with options to link a Dropbox account. `RDMLDropboxImportViewController` allows you to browse and search for files to import, depending on what kind of file types your specific Dropbox app has permissions for.

The protocol `RDMLDropboxImportViewControllerDelegate` allows for specifying download path, and informs about the general flow.

####Notes about DBSession

Your app is responsible for setting up a `DBSession` and handling the redirect URL in your app delegate. Dropbox has of yet no documentation for their iOS SDK but please check out the example project in this repository.

##Installation

1. Download and link to the [Core Dropbox SDK for iOS](https://www.dropbox.com/developers/core/sdks/ios)
2. Create a Dropbox API app at [https://www.dropbox.com/developers/apps](https://www.dropbox.com/developers/apps) and specify your file types
3. Add your app's redirect URL (db-YOUR-APP-ID) to your project's target as URL type
4. Include the necessary files in your project as described below

####Using [CocoaPods](http://cocoapods.org)
Install the `RDMLDropboxImporter` pod.

####Using git submodules

1. Run `git submodule add git@github.com:readmill/dropbox-importer-ios.git` in your project's folder
2. Drag the files from the `RDMLDropboxImporter folder` inside `dropbox-importer-ios` to your project (with or without the UI folder depending on your needs) and chose not to copy items into destination group's folder.
