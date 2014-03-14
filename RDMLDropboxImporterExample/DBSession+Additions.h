//
//  DBSession+Readmill.h
//  Readmill
//
//  Created by Tomaz Nedeljko on 10/10/13.
//
//

#import <DropboxSDK/DropboxSDK.h>

@interface DBSession (Additions)

+ (NSString *)dropboxAppId;
+ (NSString *)dropboxAppSecret;

+ (void)setSharedSessionIfNeeded;

@end
