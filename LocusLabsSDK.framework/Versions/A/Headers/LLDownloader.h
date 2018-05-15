//
//  LLDownloader.h
//  Downloader
//
//  Created by Glenn Dierkes on 1/17/15.
//  Copyright (c) 2015 LocusLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _LLDownloaderError
{
    ACCOUNT_NOT_FOUND = 0,
    VENUE_NOT_FOUND,
    CORRUPTED_VENUE_DATA,
    UNABLE_TO_STORE_FILE_LOCALLY,
    FILE_NOT_DOWNLOADED_CORRECTEDLY,
    DOWNLOAD_FAILURE
} LLDownloaderError;

static NSString * const kLLDownloaderErrorMessage[] = {
    @"Account Id provided not found.",
    @"Venue Id provided not found.",
    @"Venue Data appears corrupted.  Purge then download again.",
    @"Unable to store file locally.",
    @"File not downloaded correctly.  Try again",
    @"General Download Failure. Try again.",
};

@class LLDownloader;

@protocol LLDownloaderDelegate <NSObject>

- (void)loadCompleted:(LLDownloader *)downloader;
- (void)loadFailed:(LLDownloader *)downloader errorCode:(LLDownloaderError)code errorMessage:(NSString*)message;
- (void)loadStatus:(LLDownloader *)downloader percentComplete:(int)percent;

- (void)allBackgroundTasksComplete:(LLDownloader *)downloader;

@end

@interface LLDownloader : NSObject<NSURLSessionDownloadDelegate>

@property (strong,nonatomic) NSString *baseUrl;
@property (strong,nonatomic) NSString *venueId;
@property (strong,nonatomic) NSString *accountId;
@property (atomic) BOOL isDownloadingInBackground;
@property (atomic) BOOL doBackgroundDownload;

- (id)initForAccount:(NSString*)accountId andVersion:(NSString*)assetsFormatVersion andDelegate:(id<LLDownloaderDelegate>)delegate;
- (id)init:(NSString*)venueId forAccount:(NSString*)accountId andVersion:(NSString*)assetsFormatVersion andDelegate:(id<LLDownloaderDelegate>)delegate;

- (NSString*)loadLocalVenueList;
- (void)load;
- (BOOL)purge;
- (NSString*)getVenueList;
- (NSString*)getVenueData;
- (NSString*)getMapData;
- (NSString*)getNavData;
- (NSString*)getPoiData;
- (NSString*)getBeaconData;

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;

@end