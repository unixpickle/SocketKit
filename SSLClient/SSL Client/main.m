//
//  main.m
//  SSL Client
//
//  Created by Alex Nichol on 5/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKTCPSocket.h"
#import "SKTCPSSLSocket.h"

int main (int argc, const char * argv[]) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	SKTCPSocket * socket = [[SKTCPSocket alloc] initWithRemoteHost:@"localhost" port:1337];
	SKTCPSSLSocket * sslSock = [[SKTCPSSLSocket alloc] initWithTCPSocket:socket];
	
	[sslSock writeData:[@"Hello, world!\n" dataUsingEncoding:NSASCIIStringEncoding]];
	
	NSMutableString * message = [NSMutableString string];
	while (true) {
		@try {
			NSData * aByte = [sslSock readData:1];
			NSString * pStr = [[NSString alloc] initWithData:aByte encoding:NSASCIIStringEncoding];
			if ([pStr isEqual:@"\n"]) {
				[pStr release];
				break;
			}
			[message appendFormat:@"%@", pStr];
			[pStr release];
		} @catch (NSException * readError) {
			break;
		}
	}
	NSLog(@"Message: %@", message);
	
	[sslSock close];
	[socket release];
	[sslSock release];

	[pool drain];
    return 0;
}

