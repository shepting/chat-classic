#import <Cocoa/Cocoa.h>
#import <Security/Security.h>

@interface Keychain : NSObject

+ (Keychain *)sharedKeychain;

- (NSString *)getAPIKeyForService:(NSString *)serviceName account:(NSString *)accountName;
- (BOOL)setAPIKey:(NSString *)apiKey forService:(NSString *)serviceName account:(NSString *)accountName;

@end