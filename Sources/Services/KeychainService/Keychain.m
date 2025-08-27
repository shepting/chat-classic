#import "Keychain.h"

static Keychain *sharedInstance = nil;

@implementation Keychain

+ (Keychain *)sharedKeychain {
    if (sharedInstance == nil) {
        sharedInstance = [[Keychain alloc] init];
    }
    return sharedInstance;
}

- (NSString *)getAPIKeyForService:(NSString *)serviceName account:(NSString *)accountName {
    if (!serviceName || !accountName) {
        return nil;
    }
    
    const char *serviceNameC = [serviceName UTF8String];
    const char *accountNameC = [accountName UTF8String];
    
    void *passwordData = NULL;
    UInt32 passwordLength = 0;
    
    OSStatus status = SecKeychainFindGenericPassword(
        NULL,                           // Default keychain
        strlen(serviceNameC),          // Service name length
        serviceNameC,                  // Service name
        strlen(accountNameC),          // Account name length
        accountNameC,                  // Account name
        &passwordLength,               // Password length
        &passwordData,                 // Password data
        NULL                           // Keychain item reference
    );
    
    if (status == errSecSuccess && passwordData != NULL) {
        NSString *apiKey = [[[NSString alloc] 
            initWithBytes:passwordData 
            length:passwordLength 
            encoding:NSUTF8StringEncoding] autorelease];
        
        SecKeychainItemFreeContent(NULL, passwordData);
        return apiKey;
    }
    
    return nil;
}

- (BOOL)setAPIKey:(NSString *)apiKey forService:(NSString *)serviceName account:(NSString *)accountName {
    if (!apiKey || [apiKey length] == 0 || !serviceName || !accountName) {
        return NO;
    }
    
    const char *serviceNameC = [serviceName UTF8String];
    const char *accountNameC = [accountName UTF8String];
    const char *passwordData = [apiKey UTF8String];
    UInt32 passwordLength = strlen(passwordData);
    
    // Try to update existing keychain item first
    SecKeychainItemRef itemRef = NULL;
    OSStatus findStatus = SecKeychainFindGenericPassword(
        NULL,
        strlen(serviceNameC),
        serviceNameC,
        strlen(accountNameC),
        accountNameC,
        NULL,
        NULL,
        &itemRef
    );
    
    OSStatus status;
    if (findStatus == errSecSuccess && itemRef != NULL) {
        // Update existing item
        status = SecKeychainItemModifyContent(
            itemRef,
            NULL,
            passwordLength,
            passwordData
        );
        CFRelease(itemRef);
    } else {
        // Create new keychain item with access control
        SecAccessRef access = NULL;
        OSStatus accessStatus = SecAccessCreate(CFSTR("ChatGPTClassic"), NULL, &access);
        
        if (accessStatus == errSecSuccess && access != NULL) {
            SecKeychainItemRef newItemRef = NULL;
            status = SecKeychainAddGenericPassword(
                NULL,                       // Default keychain
                strlen(serviceNameC),      // Service name length
                serviceNameC,              // Service name
                strlen(accountNameC),      // Account name length
                accountNameC,              // Account name
                passwordLength,            // Password length
                passwordData,              // Password data
                &newItemRef                // Keychain item reference
            );
            
            // Set access control on the item
            if (status == errSecSuccess && newItemRef != NULL) {
                SecKeychainItemSetAccess(newItemRef, access);
                CFRelease(newItemRef);
            }
            CFRelease(access);
        } else {
            // Fallback to standard creation
            status = SecKeychainAddGenericPassword(
                NULL,                       // Default keychain
                strlen(serviceNameC),      // Service name length
                serviceNameC,              // Service name
                strlen(accountNameC),      // Account name length
                accountNameC,              // Account name
                passwordLength,            // Password length
                passwordData,              // Password data
                NULL                       // Keychain item reference
            );
        }
    }
    
    return (status == errSecSuccess);
}

@end