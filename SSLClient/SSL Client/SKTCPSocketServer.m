//
//  SKTCPSocketServer.m
//  SocketKit
//
//  Created by Alex Nichol on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SKTCPSocketServer.h"


@implementation SKTCPSocketServer

- (id)initListeningOnPort:(int)port {
	NSAssert((port > 0 && port < 65536), @"The port must be valid for TCP/IP.");
	if ((self = [super init])) {
		_port = port;
		_fileDescriptor = -1;
		state = SKTCPSocketServerStateUnopened;
	}
	return self;
}

- (int)listeningPort {
	return _port;
}

- (BOOL)isListening {
	if (state == SKTCPSocketServerStateListening) return YES;
	else return NO;
}

#pragma mark SKSocketServer

- (void)listen {
	if ([self isListening]) {
		@throw [NSException exceptionWithName:SKSocketServerListenFailedException reason:@"The socket server is already listening." userInfo:nil];
	}
	struct sockaddr_in serv_addr;
	int option_value = 1;
	
	_fileDescriptor = socket(AF_INET, SOCK_STREAM, 0);
	if (_fileDescriptor < 0) {
		@throw [NSException exceptionWithName:SKSocketServerListenFailedException reason:@"The socket could not be created." userInfo:nil];
	}
	bzero((char *)&serv_addr, sizeof(serv_addr));
	serv_addr.sin_family = AF_INET;
	serv_addr.sin_addr.s_addr = INADDR_ANY;
	serv_addr.sin_port = htons(_port);
	
	if (setsockopt(_fileDescriptor, SOL_SOCKET, SO_REUSEPORT, (char *)&option_value, 
				   sizeof(option_value)) < 0) {
		NSLog(@"%@: WARNING: setsockopt failed.", NSStringFromClass([self class]));
	}
	
	if (setsockopt(_fileDescriptor, SOL_SOCKET, SO_REUSEADDR, (char *)&option_value, 
				   sizeof(option_value)) < 0) {
		NSLog(@"%@: WARNING: setsockopt failed.", NSStringFromClass([self class]));
	}
	
	if (bind(_fileDescriptor, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0) {
		@throw [NSException exceptionWithName:SKSocketServerListenFailedException reason:@"Failed to bind() socket." userInfo:nil];
	}
	
	listen(_fileDescriptor, 5);
	
	/* Switch SO_LONGER and SO_KEEPALIVE to off. */
	struct linger l;
	l.l_onoff = 1;
	l.l_linger = 0;
	setsockopt(_fileDescriptor, SOL_SOCKET, SO_KEEPALIVE|SO_LINGER, (char *)&l, sizeof(l));
	
	state = SKTCPSocketServerStateListening;
}

- (SKSocket *)acceptConnection {
	if (![self isListening]) {
		@throw [NSException exceptionWithName:SKSocketServerNotOpenException reason:@"The server socket is not open." userInfo:nil];
	}
	int clilen, newsockfd;
	struct sockaddr_in cli_addr;
	clilen = sizeof(cli_addr);
	newsockfd = accept(_fileDescriptor, 
					   (struct sockaddr *)&cli_addr, 
					   (unsigned int *)&clilen);
	if (newsockfd < 0) {
		@throw [NSException exceptionWithName:SKSocketServerAcceptFailedException reason:@"The accept() call failed." userInfo:nil];
	} else {
		NSString * hostString = [NSString stringWithFormat:@"%s", inet_ntoa(cli_addr.sin_addr)];
		SKTCPSocket * socket = [[SKTCPSocket alloc] initWithFileDescriptor:newsockfd remoteHost:hostString port:cli_addr.sin_port];
		return [socket autorelease];
	}
}

- (void)stopServer {
	if (![self isListening]) {
		@throw [NSException exceptionWithName:SKSocketServerNotOpenException reason:@"The server socket is not open." userInfo:nil];
	}
	close(_fileDescriptor);
	_fileDescriptor = -1;
	state = SKTCPSocketServerStateClosed;
}

@end
