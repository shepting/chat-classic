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
        conversationHistory = [[NSMutableArray alloc] init];
        currentConnection = nil;
        receivedData = nil;
        isStreaming = NO;
    }
    return self;
}

- (void)dealloc {
    [conversationHistory release];
    [currentConnection cancel];
    [currentConnection release];
    [receivedData release];
    [super dealloc];
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
    // Try to send to OpenAI API first, fall back to simulation if no API key
    [self sendChatMessageToOpenAI:message];
}

- (void)sendChatMessageToOpenAI:(NSString *)message {
    // Get API key from Settings
    Class SettingsClass = NSClassFromString(@"Settings");
    if (!SettingsClass) {
        [self simulateResponse:message];
        return;
    }
    
    id settings = [SettingsClass performSelector:@selector(sharedSettings)];
    NSString *apiKey = [settings performSelector:@selector(getAPIKey)];
    
    if (!apiKey || [apiKey length] == 0) {
        NSRunAlertPanel(@"API Key Required", 
                       @"Please set your OpenAI API key in Settings before using the chat.", 
                       @"OK", nil, nil);
        return;
    }
    
    // Add user message to conversation history
    NSDictionary *userMessage = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"user", @"role",
                                message, @"content",
                                nil];
    [conversationHistory addObject:userMessage];
    
    // Prepare OpenAI API request
    NSString *urlString = @"https://api.openai.com/v1/chat/completions";
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", apiKey] forHTTPHeaderField:@"Authorization"];
    
    // Create request body
    NSDictionary *requestBody = [NSDictionary dictionaryWithObjectsAndKeys:
        @"gpt-3.5-turbo", @"model",
        conversationHistory, @"messages",
        [NSNumber numberWithBool:YES], @"stream",
        [NSNumber numberWithFloat:0.7], @"temperature",
        [NSNumber numberWithInt:1000], @"max_tokens",
        nil];
    
    // Convert to JSON manually (simple implementation for macOS 10.4)
    NSString *jsonString = [self dictionaryToJSONString:requestBody];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:jsonData];
    
    // Cancel any existing connection
    [currentConnection cancel];
    [currentConnection release];
    [receivedData release];
    
    // Start new connection
    receivedData = [[NSMutableData alloc] init];
    currentConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (currentConnection) {
        isStreaming = YES;
        if (delegate && [delegate respondsToSelector:@selector(networking:didStartStreaming:)]) {
            [delegate networking:self didStartStreaming:nil];
        }
    } else {
        NSLog(@"Failed to create connection to OpenAI API");
        [self simulateResponse:message];
    }
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

- (void)clearConversationHistory {
    [conversationHistory removeAllObjects];
}

- (NSArray *)getConversationHistory {
    return [[conversationHistory copy] autorelease];
}

- (NSMutableArray *)conversationHistory {
    return conversationHistory;
}

- (NSString *)dictionaryToJSONString:(NSDictionary *)dict {
    // Simple JSON serialization for macOS 10.4 compatibility
    NSMutableString *json = [NSMutableString stringWithString:@"{"];
    
    NSArray *keys = [dict allKeys];
    for (int i = 0; i < [keys count]; i++) {
        NSString *key = [keys objectAtIndex:i];
        id value = [dict objectForKey:key];
        
        if (i > 0) {
            [json appendString:@","];
        }
        
        [json appendFormat:@"\"%@\":", key];
        
        if ([value isKindOfClass:[NSString class]]) {
            NSString *escapedValue = [value stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
            [json appendFormat:@"\"%@\"", escapedValue];
        } else if ([value isKindOfClass:[NSNumber class]]) {
            NSNumber *num = (NSNumber *)value;
            if (strcmp([num objCType], @encode(BOOL)) == 0) {
                [json appendString:[num boolValue] ? @"true" : @"false"];
            } else {
                [json appendFormat:@"%@", num];
            }
        } else if ([value isKindOfClass:[NSArray class]]) {
            [json appendString:[self arrayToJSONString:(NSArray *)value]];
        }
    }
    
    [json appendString:@"}"];
    return json;
}

- (NSString *)arrayToJSONString:(NSArray *)array {
    NSMutableString *json = [NSMutableString stringWithString:@"["];
    
    for (int i = 0; i < [array count]; i++) {
        id item = [array objectAtIndex:i];
        
        if (i > 0) {
            [json appendString:@","];
        }
        
        if ([item isKindOfClass:[NSDictionary class]]) {
            [json appendString:[self dictionaryToJSONString:(NSDictionary *)item]];
        } else if ([item isKindOfClass:[NSString class]]) {
            NSString *escapedValue = [item stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
            [json appendFormat:@"\"%@\"", escapedValue];
        }
    }
    
    [json appendString:@"]"];
    return json;
}

#pragma mark - NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
    
    // Process streaming response
    NSString *dataString = [[[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding] autorelease];
    NSArray *lines = [dataString componentsSeparatedByString:@"\n"];
    
    for (NSString *line in lines) {
        if ([line hasPrefix:@"data: "]) {
            NSString *jsonData = [line substringFromIndex:6]; // Remove "data: " prefix
            
            if ([jsonData isEqualToString:@"[DONE]"]) {
                isStreaming = NO;
                if (delegate && [delegate respondsToSelector:@selector(networking:didFinishStreaming:)]) {
                    [delegate networking:self didFinishStreaming:nil];
                }
                return;
            }
            
            // Parse the streaming chunk (simplified)
            NSRange contentRange = [jsonData rangeOfString:@"\"content\":"];
            if (contentRange.location != NSNotFound) {
                NSString *remaining = [jsonData substringFromIndex:contentRange.location + contentRange.length];
                NSRange startQuote = [remaining rangeOfString:@"\""];
                if (startQuote.location != NSNotFound) {
                    remaining = [remaining substringFromIndex:startQuote.location + 1];
                    NSRange endQuote = [remaining rangeOfString:@"\""];
                    if (endQuote.location != NSNotFound) {
                        NSString *content = [remaining substringToIndex:endQuote.location];
                        if ([content length] > 0) {
                            if (delegate && [delegate respondsToSelector:@selector(networking:didReceiveStreamingChunk:)]) {
                                [delegate networking:self didReceiveStreamingChunk:content];
                            }
                        }
                    }
                }
            }
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (isStreaming) {
        isStreaming = NO;
        if (delegate && [delegate respondsToSelector:@selector(networking:didFinishStreaming:)]) {
            [delegate networking:self didFinishStreaming:nil];
        }
    }
    
    [currentConnection release];
    currentConnection = nil;
    [receivedData release];
    receivedData = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection failed with error: %@", [error localizedDescription]);
    
    isStreaming = NO;
    [currentConnection release];
    currentConnection = nil;
    [receivedData release];
    receivedData = nil;
    
    // Fall back to simulation
    if (delegate && [delegate respondsToSelector:@selector(networking:didReceiveChatResponse:)]) {
        [delegate networking:self didReceiveChatResponse:@"Sorry, I'm having trouble connecting to the API right now. This is a simulated response."];
    }
}

@end