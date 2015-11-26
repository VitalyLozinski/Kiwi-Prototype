//
//  ImageCache.h
//  Kiwi
//
//  Created by Georgiy Kassabli on 27/05/14.
//  Copyright (c) 2014 Diversido. All rights reserved.

@interface ImageCache : NSCache

+ (instancetype)sharedCache;

- (void)getPhotoForUrl:(NSString *)url completion:(void (^)(UIImage *image, NSString *objectUrl))completionBlock;

@end

@interface NSString (RemoteStorage)

- (NSString *)fullUrlPath;

@end
