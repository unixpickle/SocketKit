//
//  SKTCPSocketServer.h
//  SocketKit
//
//  Created by Alex Nichol on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h> 
#include <sys/types.h>
#include <stdlib.h>
#include <unistd.h>

#import <Foundation/Foundation.h>
#import "SKSocketServer.h"
#import "SKTCPSocket.h"

typedef enum {
	SKTCPSocketServerStateUnopened,
	SKTCPSocketServerStateListening,
	SKTCPSocketServerStateClosed
} SKTCPSocketServerState;

@interface SKTCPSocketServer : SKSocketServer {
    int _fileDescriptor;
	int _port;
	SKTCPSocketServerState state;
}

/**
 * Create a socket server that will listen
 * on a TCP port.
 * @param port The TCP port number to listen on.
 * this must be from 1 to 65535.
 * @return A new TCP socket server.
 */
- (id)initListeningOnPort:(int)port;

/**
 * Get the port on which the server socket is listening.
 * @return The port number of the server socket.
 */
- (int)listeningPort;

/**
 * Checks if the socket is listening.
 * @return YES if the socket is listening, NO otherwise.
 */
- (BOOL)isListening;

@end
