//
//  DBSession+Readmill.m
//  Readmill
//
//  Created by Tomaz Nedeljko on 10/10/13.
//
//

#import "DBSession+Additions.h"

#warning Enter your Dropbox App secret here
NSString * const RDMLDropboxAppSecret = @"YOUR_APP_SECRET";

@implementation DBSession (Additions)

+ (NSString *)dropboxAppId
{
    return [[[NSBundle mainBundle] infoDictionary] valueForKey:@"DropboxAppID"];
}

+ (NSString *)dropboxAppSecret
{
    return RDMLDropboxAppSecret;
}

+ (void)setSharedSessionIfNeeded
{
    if (![DBSession sharedSession]) {
        NSString *appId = [[self class] dropboxAppId];
        NSString *appSecret = [[self class] dropboxAppSecret];
        DBSession *session = [[DBSession alloc] initWithAppKey:appId appSecret:appSecret root:kDBRootDropbox];
        [DBSession setSharedSession:session];
    }
}

@end
