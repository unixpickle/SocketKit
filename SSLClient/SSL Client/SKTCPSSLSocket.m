//
//  SKTCPSSLSocket.m
//  SocketKit
//
//  Created by Alex Nichol on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SKTCPSSLSocket.h"

#define SKTCPSSLSocketBufferSize 512

@implementation SKTCPSSLSocket

- (id)initWithTCPSocket:(SKTCPSocket *)aSocket {
	NSAssert(aSocket != nil, @"The socket provided is nil.");
	NSAssert([aSocket isOpen], @"The socket provided is not open.");
	if ((self = [super init])) {
		tcpSocket = [aSocket retain];
		
		SSL_load_error_strings();
		SSL_library_init();
		
		sslContext = SSL_CTX_new(SSLv23_client_method());
		if (sslContext == NULL) {
			ERR_print_errors_fp(stderr);
			@throw [NSException exceptionWithName:SKTCPSSLSocketSSLException reason:@"Failed to create context." userInfo:nil];
		}
		
		sslHandle = SSL_new(sslContext);
		if (sslHandle == NULL) {
			ERR_print_errors_fp(stderr);
			SSL_CTX_free(sslContext);
			@throw [NSException exceptionWithName:SKTCPSSLSocketSSLException reason:@"Failed to create context." userInfo:nil];
		}
		
		if (!SSL_set_fd(sslHandle, [aSocket fileDescriptor])) {
			SSL_shutdown(sslHandle);
			SSL_free(sslHandle);
			SSL_CTX_free(sslContext);
			ERR_print_errors_fp(stderr);
			@throw [NSException exceptionWithName:SKTCPSSLSocketSSLException reason:@"Failed to set file descriptor." userInfo:nil];
		}
		
		if (SSL_connect(sslHandle) != 1) {
			SSL_shutdown(sslHandle);
			SSL_free(sslHandle);
			SSL_CTX_free(sslContext);
			ERR_print_errors_fp(stderr);
			@throw [NSException exceptionWithName:SKTCPSSLSocketSSLException reason:@"Failed to perform SSL negotiation." userInfo:nil];
		}
	}
	return self;
}

- (id)initWithServerTCPSocket:(SKTCPSocket *)aSocket publicKey:(NSString *)pKey privateKey:(NSString *)privateKey {
	NSAssert(aSocket != nil, @"The socket provided is nil.");
	NSAssert([aSocket isOpen], @"The socket provided is not open.");
	if ((self = [super init])) {		
		tcpSocket = [aSocket retain];
		
		SSL_load_error_strings();
		SSL_library_init();
		OpenSSL_add_all_algorithms();
		
		sslContext = SSL_CTX_new(SSLv23_server_method());
		if (sslContext == NULL) {
			ERR_print_errors_fp(stderr);
			@throw [NSException exceptionWithName:SKTCPSSLSocketSSLException reason:@"Failed to create context." userInfo:nil];
		}
		
		if (SSL_CTX_use_certificate_file(sslContext, [pKey UTF8String], SSL_FILETYPE_PEM) <= 0) {
			ERR_print_errors_fp(stderr);
			SSL_CTX_free(sslContext);
			@throw [NSException exceptionWithName:SKPublicKeyInvalid reason:@"Failed to use the certificate chain file." userInfo:nil];
		}
		if (SSL_CTX_use_PrivateKey_file(sslContext, [privateKey UTF8String], SSL_FILETYPE_PEM) <= 0) {
			ERR_print_errors_fp(stderr);
			SSL_CTX_free(sslContext);
			@throw [NSException exceptionWithName:SKPrivateKeyInvalid reason:@"Failed to use the private key file." userInfo:nil];
		}
		if (!SSL_CTX_check_private_key(sslContext)) {
			SSL_CTX_free(sslContext);
			@throw [NSException exceptionWithName:SKPrivateKeyInvalid reason:@"The keys used do not go together." userInfo:nil];
		}
		
		sslHandle = SSL_new(sslContext);
		if (sslHandle == NULL) {
			ERR_print_errors_fp(stderr);
			SSL_CTX_free(sslContext);
			@throw [NSException exceptionWithName:SKTCPSSLSocketSSLException reason:@"Failed to create context." userInfo:nil];
		}
		
		SSL_set_accept_state(sslHandle);
		
		if (!SSL_set_fd(sslHandle, [aSocket fileDescriptor])) {
			SSL_shutdown(sslHandle);
			SSL_free(sslHandle);
			SSL_CTX_free(sslContext);
			ERR_print_errors_fp(stderr);
			@throw [NSException exceptionWithName:SKTCPSSLSocketSSLException reason:@"Failed to set file descriptor." userInfo:nil];
		}
		
		// the possible secret to safety!
		SSL_set_accept_state(sslHandle);
		
		int returnv = SSL_do_handshake(sslHandle);
		if (returnv != 1) {
			// int error = SSL_get_error(sslHandle, returnv);
			ERR_print_errors_fp(stderr);
			SSL_shutdown(sslHandle);
			SSL_free(sslHandle);
			SSL_CTX_free(sslContext);
			@throw [NSException exceptionWithName:SKTCPSSLSocketSSLException reason:@"Could not accept SSL negotiation." userInfo:nil];
		}
	}
	return self;
}

- (SSL *)sslHandle {
	return sslHandle;
}

#pragma mark SKSocket

- (BOOL)isOpen {
	if (!sslHandle) return NO;
	return [tcpSocket isOpen];
}

- (void)writeData:(NSData *)theData {
	if (![self isOpen]) {
		@throw [NSException exceptionWithName:SKSocketNotOpenException reason:@"The socket cannot be written to because it is not open." userInfo:nil];
	}
	const char * dataBytes = [theData bytes];
	size_t index = 0;
	while (index < [theData length]) {
		size_t toWrite = [theData length] - index;
		if (toWrite > SKTCPSSLSocketBufferSize) {
			toWrite = SKTCPSSLSocketBufferSize;
		}
		long wrote = SSL_write(sslHandle, &dataBytes[index], (int)toWrite);
		index += wrote;
		if (wrote <= 0) {
			@throw [NSException exceptionWithName:SKSocketWriteFailedException reason:@"Call to SSL_write() returned 0 or less." userInfo:nil];
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
		if (toRead > SKTCPSSLSocketBufferSize) {
			toRead = SKTCPSSLSocketBufferSize;
		}
		long justRead = SSL_read(sslHandle, &readData[hasRead], (int)toRead);
		hasRead += justRead;
		if (justRead <= 0) {
			free(readData);
			@throw [NSException exceptionWithName:SKSocketReadFailedException reason:@"Call to SSL_read() returned 0 or less." userInfo:nil];
		}
	}
	NSData * theData = [NSData dataWithBytesNoCopy:readData length:length freeWhenDone:YES];
	return theData;
}

- (void)close {
	if ([tcpSocket isOpen]) [tcpSocket close];
	if (sslHandle) {
		SSL_shutdown(sslHandle);
		SSL_free(sslHandle);
		sslHandle = NULL;
	}
	if (sslContext) {
		SSL_CTX_free(sslContext);
		sslContext = NULL;
	}
}

- (void)dealloc {
	[self close];
	[tcpSocket release];
	[super dealloc];
}

@end
