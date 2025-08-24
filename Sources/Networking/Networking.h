#import <Cocoa/Cocoa.h>

@protocol NetworkingDelegate;

@interface NetworkRequest : NSObject {
    NSString *url;
    NSString *method;
    NSDictionary *headers;
    NSData *body;
}

@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *method;
@property (nonatomic, retain) NSDictionary *headers;
@property (nonatomic, retain) NSData *body;

- (id)initWithURL:(NSString *)url method:(NSString *)method;
- (void)setJSONBody:(NSDictionary *)jsonDict;

@end

@interface NetworkResponse : NSObject {
    NSInteger statusCode;
    NSDictionary *headers;
    NSData *data;
    NSError *error;
}

@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, retain) NSDictionary *headers;
@property (nonatomic, retain) NSData *data;
@property (nonatomic, retain) NSError *error;

- (NSString *)bodyAsString;
- (NSDictionary *)bodyAsJSON;

@end

@interface Networking : NSObject {
    id<NetworkingDelegate> delegate;
}

+ (Networking *)sharedNetworking;
- (void)setDelegate:(id<NetworkingDelegate>)delegate;
- (void)sendRequest:(NetworkRequest *)request;
- (void)sendChatMessage:(NSString *)message;
- (void)simulateResponse:(NSString *)userMessage;

@end

@protocol NetworkingDelegate <NSObject>
@optional
- (void)networking:(Networking *)networking didReceiveResponse:(NetworkResponse *)response forRequest:(NetworkRequest *)request;
- (void)networking:(Networking *)networking didFailWithError:(NSError *)error forRequest:(NetworkRequest *)request;
- (void)networking:(Networking *)networking didReceiveChatResponse:(NSString *)response;
@end