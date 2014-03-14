//
//  UIImage+RDMLAdditions.m
//  RDMLDropboxBookImporter
//
//  Created by Martin Hwasser on 07/03/14.
//  Copyright (c) 2014 Readmill. All rights reserved.
//

#import "UIImage+RDMLAdditions.h"

@implementation UIImage (RDMLAdditions)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect frame = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, frame);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
