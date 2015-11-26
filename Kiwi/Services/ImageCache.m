//
//  ImageCache.m
//  Kiwi
//
//  Created by Georgiy Kassabli on 27/05/14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "ImageCache.h"
#import "NetworkManager.h"

@implementation NSString (RemoteStorage)

- (NSString *)fullUrlPath
{
    return [NSString stringWithFormat:@"%@/%@",
            [NetworkManager baseResourceUrl],
            self];
}

@end

@implementation ImageCache

#pragma mark - lifecycle methods

+ (instancetype)sharedCache
{
    static ImageCache *sCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sCache = [ImageCache new];
    });
    return sCache;
}

- (id)init
{
    if (self = [super init]) {
        NSString *pathFolder = [[NSString alloc] initWithFormat:@"%@/images", [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]];
        BOOL directory;
        BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:pathFolder isDirectory:&directory];
        if (!exist || !directory) {
            [[NSFileManager defaultManager] createDirectoryAtPath:pathFolder withIntermediateDirectories:NO attributes:nil error:NULL];
        }
    }
    return self;
}

#pragma mark - public methods

- (void)getPhotoForUrl:(NSString *)urlString completion:(void (^)(UIImage *image, NSString *objectUrl))completionBlock
{
    NSURL *url = [NSURL URLWithString:urlString];
    UIImage *cachedImage = [self cachedImageForRequest:url];
    if (cachedImage) {
        completionBlock(cachedImage, urlString);
    } else {
        [self downloadImage:url completion:^(UIImage *image) {
            return completionBlock(image, urlString);
        }];
    }
}

- (void)downloadImage:(NSURL *)url completion:(void (^)(UIImage *image))completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        UIImage *img = [UIImage imageWithData:imageData];
        img = [UIImage imageWithCGImage:img.CGImage scale:[UIScreen mainScreen].scale orientation:img.imageOrientation];
        if (img) {
            [self setObject:img forKey:url.absoluteString];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            return completionBlock(img);
        });
    });
}

#pragma mark - NSCache methods

- (id)objectForKey:(id)key
{
    UIImage *object = [super objectForKey:key];
    if (!object) {
        object = [self savedObjectForKey:key];
    }
    return object;
}

- (BOOL)objectForKey:(id)key success:(void (^)(UIImage *image))success
{
    id object = [super objectForKey:key];
    if (object) {
        success(object);
        return YES;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:ImageSavePathFromKey(key)]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
            success([self savedObjectForKey:key]);
        });

        return YES;
    }
    return NO;
}

- (void)setObject:(id)obj forKey:(id)key
{
    dispatch_async(dispatch_queue_create("SaveImageQueue", DISPATCH_QUEUE_CONCURRENT), ^() {
        if (![[NSFileManager defaultManager] fileExistsAtPath:ImageSavePathFromKey(key)] && [obj isKindOfClass:[UIImage class]]) {
            [UIImagePNGRepresentation(obj) writeToFile:ImageSavePathFromKey(key) atomically:YES];
        }
    });
    [super setObject:obj forKey:key];
}

static inline NSString *ImageSavePathFromKey (NSString *key)
{
    return [[NSString alloc] initWithFormat:@"%@/images/%@", [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject], [[[key dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0] stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
}

- (id)savedObjectForKey:(id)key
{
    UIImage *object = nil;
    NSData *data = [NSData dataWithContentsOfFile:ImageSavePathFromKey(key)];
    if (data) {
        object = [UIImage imageWithData:data scale:[UIScreen mainScreen].scale];
    }
    return object;
}

- (UIImage *)cachedImageForRequest:(NSURL *)request
{
    return [self objectForKey:request.absoluteString];
}

@end
