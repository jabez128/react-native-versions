#import "UpdateDownloader.h"

@implementation UpdateDownloader

static NSString *VERSION_LIST = @"https://api.staging.rnplay.org/bundled_apps/%@/versions";
static NSString *SINGLE_VERSION_PATH = @"https://api.staging.rnplay.org/bundled_apps/%@/versions/%@";
static NSString *LOCAL_DIR = @"versions";

static NSString *token;
static NSString *appId;

@synthesize bridge = _bridge;
RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(configure:(NSDictionary*)config) {
  token = [config objectForKey:@"token"];
  appId = [config objectForKey:@"appId"];
}

RCT_EXPORT_METHOD(downloadVersionAsync:(NSString *)version
                             resolver:(RCTPromiseResolveBlock)resolve
                             rejecter:(RCTPromiseRejectBlock)reject) {

  NSString *versionFile = [version stringByAppendingPathExtension:@"js"];
  NSString *remotePath = [NSString stringWithFormat:SINGLE_VERSION_PATH, appId, version];

  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsPath = [paths objectAtIndex:0];
  NSString *localPath = [[documentsPath stringByAppendingPathComponent:LOCAL_DIR]
                                        stringByAppendingPathComponent:versionFile];

  [UpdateDownloader downloadFileAtURL:remotePath ToPath:localPath Completion:^(NSError *err) {
    if (err) {
      reject(err);
    } else {
      resolve(localPath);
    }
  }];
}

+ (void) downloadFileAtURL:(NSString *)urlPath ToPath:(NSString *)path Completion:(void (^)(NSError *))completion {
  NSURL *url = [NSURL URLWithString:urlPath];
  NSURLSessionDataTask *updateDownload = [[NSURLSession sharedSession]
    dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if (error != nil) {
      return completion(error);
    }
    
    NSString *localPath = [path stringByDeletingLastPathComponent];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager createDirectoryAtPath:localPath withIntermediateDirectories:YES attributes:nil error:nil];
    BOOL success = [manager createFileAtPath:path contents:data attributes:nil];
    
    if (!success) {
      return completion([NSError errorWithDomain:@"UpdateDownloader" code:1000 userInfo:nil]);
    }
    
    completion(nil);
  }];
  
  [updateDownload resume];
}

@end
