//
//  SKSocketServer.h
//  SocketKit
//
//  Created by Alex Nichol on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKSocket.h"

#define SKSocketServerListenFailedException @"SKSocketServerListenFailedException"
#define SKSocketServerAcceptFailedException @"SKSocketServerAcceptFailedException"
#define SKSocketServerNotOpenException @"SKSocketServerNotOpenException"

/**
 * This is an abstraction of what to implement for
 * a socket server.
 */
@interface SKSocketServer : NSObject {
    
}

/* NOTE: you will want initializers for creating a server
 * that uses a port or a file descriptor, or something of
 * that nature. */
// e.g: -initWithListeningPort:(int)port;

/**
 * This should be called to begin accepting connections.
 * @throws SKSocketServerListenFailedException Thrown when the socket could not listen
 * using the information that may have been supplied to it via init methods.
 */
- (void)listen;

/**
 * Accepts a connection on the socket server, returning the new
 * socket that has been established.
 * @return A new, autoreleased socket that is allows reading and writing to the remote
 * host that the server accepted the connection from.
 * @throws SKSocketServerAcceptFailedException Thrown when the server socket could not
 * open a new socket.  This will not be called due to a timeout (which should not be
 * an issue.)
 */
- (SKSocket *)acceptConnection;

/**
 * Stops the server.  This may only be called after a call
 * to the -listen method.
 * @throws SKSocketServerNotOpenException Thrown when the server is not listening
 * for connections, but has been closed anyway.
 */
- (void)stopServer;

@end
