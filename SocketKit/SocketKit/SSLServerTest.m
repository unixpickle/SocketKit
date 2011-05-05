//
//  SSLServerTest.m
//  SocketKit
//
//  Created by Alex Nichol on 5/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SSLServerTest.h"


@implementation SSLServerTest

- (void)testServer {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	SKTCPSocket * aSocket = nil;
	SKTCPSocketServer * server = [[SKTCPSocketServer alloc] initListeningOnPort:1337];
	@try {
		[server listen];
		while ((aSocket = (SKTCPSocket *)[server acceptConnection]) != nil) {
			NSLog(@"Connected from %@:%d", [aSocket remoteHost], [aSocket remotePort]);
			@try {
				NSString * combo = @"mycert.pem";
				SKTCPSSLSocket * sslSocket = [[[SKTCPSSLSocket alloc] initWithServerTCPSocket:aSocket publicKey:combo privateKey:combo] autorelease];
				[self handleSocket:sslSocket];
				[sslSocket close];
			} @catch (NSException * sslExc) {
				NSLog(@"SSL exception: %@", sslExc);
			}
		}
	} @catch (NSException * e) {
		NSLog(@"Exception : %@", e);
	}
	[server stopServer];
	[server release];
	
	[pool drain];
}
- (void)handleSocket:(SKTCPSSLSocket *)sslSocket {
	[sslSocket writeData:[@"Welcome to the fancy SSL server!\n" dataUsingEncoding:NSASCIIStringEncoding]];
	NSMutableString * message = [NSMutableString string];
	while (true) {
		@try {
			NSData * aByte = [sslSocket readData:1];
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
}

@end
