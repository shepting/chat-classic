#import "Networking.h"

@implementation NetworkRequest

@synthesize url, method, headers, body;

- (id)initWithURL:(NSString *)requestURL method:(NSString *)requestMethod {
    self = [super init];
    if (self) {
        self.url = requestURL;
        self.method = requestMethod ? requestMethod : @"GET";
        self.headers = [NSDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    [url release];
    [method release];
    [headers release];
    [body release];
    [super dealloc];
}

- (void)setJSONBody:(NSDictionary *)jsonDict {
    NSError *error;
    NSData *jsonData = [NSPropertyListSerialization dataFromPropertyList:jsonDict
                                                                  format:NSPropertyListXMLFormat_v1_0
                                                        errorDescription:nil];
    if (jsonData) {
        self.body = jsonData;
        // Update headers for JSON content
        NSMutableDictionary *newHeaders = [[self.headers mutableCopy] autorelease];
        [newHeaders setObject:@"application/json" forKey:@"Content-Type"];
        self.headers = newHeaders;
    }
}

@end

@implementation NetworkResponse

@synthesize statusCode, headers, data, error;

- (void)dealloc {
    [headers release];
    [data release];
    [error release];
    [super dealloc];
}

- (NSString *)bodyAsString {
    if (data) {
        return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    }
    return nil;
}

- (NSDictionary *)bodyAsJSON {
    if (data) {
        NSString *jsonString = [self bodyAsString];
        if (jsonString) {
            // For macOS 10.4 compatibility, we'll use a simple JSON parser simulation
            // In a real implementation, you might use a third-party JSON library
            // For now, return nil since JSON parsing wasn't native in 10.4
            return nil;
        }
    }
    return nil;
}

@end

static Networking *sharedInstance = nil;

@implementation Networking

+ (Networking *)sharedNetworking {
    if (sharedInstance == nil) {
        sharedInstance = [[Networking alloc] init];
    }
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        delegate = nil;
    }
    return self;
}

- (void)setDelegate:(id<NetworkingDelegate>)newDelegate {
    delegate = newDelegate;
}

- (void)sendRequest:(NetworkRequest *)request {
    // For macOS 10.4 compatibility, we'll simulate network requests
    // In a real implementation, you would use NSURLConnection (available in 10.4)
    
    // Simulate a delay and response
    [self performSelector:@selector(simulateNetworkResponse:) 
               withObject:request 
               afterDelay:1.0];
}

- (void)simulateNetworkResponse:(NetworkRequest *)request {
    NetworkResponse *response = [[NetworkResponse alloc] init];
    response.statusCode = 200;
    response.headers = [NSDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"];
    
    NSString *responseBody = @"Simulated response from server";
    response.data = [responseBody dataUsingEncoding:NSUTF8StringEncoding];
    
    if (delegate && [delegate respondsToSelector:@selector(networking:didReceiveResponse:forRequest:)]) {
        [delegate networking:self didReceiveResponse:response forRequest:request];
    }
    
    [response release];
}

- (void)sendChatMessage:(NSString *)message {
    // Simulate sending a chat message and receiving a response
    [self performSelector:@selector(simulateResponse:) 
               withObject:message 
               afterDelay:0.5];
}

- (void)simulateResponse:(NSString *)userMessage {
    // Generate a simple simulated response based on the user message
    NSString *response = nil;
    
    NSString *lowerMessage = [userMessage lowercaseString];
    
    if ([lowerMessage rangeOfString:@"hello"].location != NSNotFound || 
        [lowerMessage rangeOfString:@"hi"].location != NSNotFound) {
        response = @"Hello! How can I help you today?";
    } else if ([lowerMessage rangeOfString:@"bazel"].location != NSNotFound) {
        response = @"Bazel is a great build system! This application was built using Bazel with rules_apple.";
    } else if ([lowerMessage rangeOfString:@"legacy"].location != NSNotFound || 
               [lowerMessage rangeOfString:@"tiger"].location != NSNotFound) {
        response = @"This application targets macOS 10.4 Tiger for maximum legacy compatibility while using modern build tools.";
    } else if ([lowerMessage rangeOfString:@"objective-c"].location != NSNotFound || 
               [lowerMessage rangeOfString:@"objc"].location != NSNotFound) {
        response = @"This app is written in Objective-C using manual memory management (retain/release) for 10.4 compatibility.";
    } else {
        NSArray *responses = [NSArray arrayWithObjects:
            @"That's an interesting question! Let me think about that...",
            @"I understand what you're asking. Here's my thoughts on that topic.",
            @"Thanks for your message! I'm a simulated ChatGPT running on legacy macOS.",
            @"This is a demo response. In a real implementation, this would connect to an actual API.",
            nil];
        
        NSInteger randomIndex = arc4random() % [responses count];
        response = [responses objectAtIndex:randomIndex];
    }
    
    if (delegate && [delegate respondsToSelector:@selector(networking:didReceiveChatResponse:)]) {
        [delegate networking:self didReceiveChatResponse:response];
    }
}

@end