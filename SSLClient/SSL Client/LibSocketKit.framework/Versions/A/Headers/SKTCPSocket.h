//
//  SKTCPSocket.h
//  SocketKit
//
//  Created by Alex Nichol on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h> 
#include <sys/types.h>
#include <stdlib.h>
#include <unistd.h>

#import <Foundation/Foundation.h>
#import "SKSocket.h"

#define SKTCPSocketConnectException @"SKTCPSocketConnectException"

typedef enum {
	SKTCPSocketStateUnopen,
	SKTCPSocketStateOpen,
	SKTCPSocketStateClosed
} SKTCPSocketState;

@interface SKTCPSocket : SKSocket {
    int _fileDescriptor;
	int _port;
	NSString * _host;
	SKTCPSocketState socketState;
}

/**
 * Creates a socket from an open file descriptor with the specified information.
 * @param fileDescriptor The file descriptor that this socket will wrap.
 * @param host The remote host to which the file descriptor is connected.
 * @param port The remote port through which the file descriptor is connected.
 * @return A new SKTCPSocket object.
 */
- (id)initWithFileDescriptor:(int)fileDescriptor remoteHost:(NSString *)host port:(int)port;

/**
 * Creates a socket that is connected to a specified host on a specified port.
 * @param host The host to which the socket will connect itself.
 * @param port The port through which the socket will connect itself.
 * @return A new SKTCPSocket object.
 * @throws SKTCPSocketConnectException When the socket cannot be opened, or 
 * when the remote host is not available on the specified port.
 */
- (id)initWithRemoteHost:(NSString *)host port:(int)port;

/**
 * @return The remote address.
 */
- (NSString *)remoteHost;

/**
 * @return The remote port.
*/
- (int)remotePort;

/**
 * Gets the file descriptor.
 * @return The underlying file descriptor for the socket.
 */
- (int)fileDescriptor;

@end
