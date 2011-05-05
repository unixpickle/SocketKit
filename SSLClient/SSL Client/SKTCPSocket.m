//
//  SKTCPSocket.m
//  SocketKit
//
//  Created by Alex Nichol on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SKTCPSocket.h"

#define SKTCPSocketBufferSize 65536

@implementation SKTCPSocket

- (id)init {
	if ((self = [super init])) {
		socketState = SKTCPSocketStateUnopen;
		_host = nil;
		_port = 0;
		_fileDescriptor = -1;
	}
	return self;
}

- (id)initWithFileDescriptor:(int)fileDescriptor remoteHost:(NSString *)host port:(int)port {
	NSAssert(host != nil, @"The host cannot be nil and must be specified.");
	NSAssert((port > 0 && port < 65536), @"The port that was specified is not valid.");
	NSAssert(fileDescriptor >= 0, @"The file descriptor provided is invalid.");
	if ((self = [super init])) {
		_fileDescriptor = fileDescriptor;
		_host = [host retain];
		_port = port;
		socketState = SKTCPSocketStateOpen;
	}
	return self;
}

- (id)initWithRemoteHost:(NSString *)host port:(int)port {
	if ((self = [super init])) {
		struct sockaddr_in serv_addr;
		struct hostent * server;
		_fileDescriptor = socket(AF_INET, SOCK_STREAM, 0);
		if (_fileDescriptor < 0) {
			[super dealloc];
			@throw [NSException exceptionWithName:SKTCPSocketConnectException reason:@"The socket could not be created." userInfo:nil];
		}
		server = gethostbyname([host UTF8String]);
		if (!server) {
			[super dealloc];
			@throw [NSException exceptionWithName:SKTCPSocketConnectException reason:@"Invalid host." userInfo:nil];
		}
		
		/* Zero the $serv_addr, set its family, and 
		 * update its address from $server. */
		bzero((char *)&serv_addr, sizeof(serv_addr));
		serv_addr.sin_family = AF_INET;
		bcopy((char *)server->h_addr, 
			  (char *)&serv_addr.sin_addr.s_addr,
			  server->h_length);
		serv_addr.sin_port = htons(port);
		if (connect(_fileDescriptor, (const struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0) {
			[super dealloc];
			@throw [NSException exceptionWithName:SKTCPSocketConnectException reason:@"Failed to connect()." userInfo:nil];
		}
		socketState = SKTCPSocketStateOpen;
		_host = [host retain];
		_port = port;
	}
	return self;
}

- (NSString *)remoteHost {
	return [[_host copy] autorelease];
}

- (int)remotePort {
	return _port;
}

- (int)fileDescriptor {
	return _fileDescriptor;
}

#pragma mark SKSocket

- (BOOL)isOpen {
	if (socketState == SKTCPSocketStateOpen) return YES;
	else return NO;
}

- (void)writeData:(NSData *)theData {
	if (![self isOpen]) {
		@throw [NSException exceptionWithName:SKSocketNotOpenException reason:@"The socket cannot be written to because it is not open." userInfo:nil];
	}
	const char * dataBytes = [theData bytes];
	size_t index = 0;
	while (index < [theData length]) {
		size_t toWrite = [theData length] - index;
		if (toWrite > SKTCPSocketBufferSize) {
			toWrite = SKTCPSocketBufferSize;
		}
		long wrote = write(_fileDescriptor, &dataBytes[index], toWrite);
		index += wrote;
		if (wrote <= 0) {
			@throw [NSException exceptionWithName:SKSocketWriteFailedException reason:@"Call to write() returned 0 or less." userInfo:nil];
		}
	}
}

- (NSData *)readData:(UInt32)length {
	if (![self isOpen]) {
		@throw [NSException exceptionWithName:SKSocketNotOpenException reason:@"The socket cannot be written to because it is not open." userInfo:nil];
	}
	if (length == 0) return [NSData data];
	char * readData = (char *)malloc(length);
	size_t hasRead = 0;
	while (hasRead < length) {
		size_t toRead = (length - hasRead);
		if (toRead > SKTCPSocketBufferSize) {
			toRead = SKTCPSocketBufferSize;
		}
		long justRead = read(_fileDescriptor, &readData[hasRead], toRead);
		hasRead += justRead;
		if (justRead <= 0) {
			free(readData);
			@throw [NSException exceptionWithName:SKSocketReadFailedException reason:@"Call to read() returned 0 or less." userInfo:nil];
		}
	}
	NSData * theData = [NSData dataWithBytesNoCopy:readData length:length freeWhenDone:YES];
	return theData;
}

- (void)close {
	if (![self isOpen]) {
		@throw [NSException exceptionWithName:SKSocketNotOpenException reason:@"The socket is not open, and therefore cannot be closed." userInfo:nil];
	}
	socketState = SKTCPSocketStateClosed;
	close(_fileDescriptor);
	_fileDescriptor = -1;
	[_host release];
	_host = nil;
	_port = 0;
}

- (void)dealloc {
	if ([self isOpen]) [self close];
	[_host release];
	[super dealloc];
}

@end
