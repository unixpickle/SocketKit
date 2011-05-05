//
//  SKSocket.h
//  SocketKit
//
//  Created by Alex Nichol on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SKSocketNotOpenException @"SKSocketNotOpenException"
#define SKSocketWriteFailedException @"SKSocketWriteFailedException"
#define SKSocketReadFailedException @"SKSocketReadFailedException"

/**
 * This is an abstraction of what one has to implement
 * for a socket class.
 */
@interface SKSocket : NSObject {
    
}

/* NOTE: you will want initializers for creating a socket
 * that uses a network address, or a file descriptor, or
 * something of that nature. */
// e.g: -initWithHost:(NSString *)host port:(int)port;

/**
 * @return YES if the socket is open, NO if the socket is not.
 */
- (BOOL)isOpen;

/**
 * Writes data to the socket.
 * @param theData The data to write to the socket.
 * @throws SKSocketWriteFailedException Thrown when the data could not be written.
 * @throws SKSocketNotOpenException Thrown when the socket is not open for writing.
 */
- (void)writeData:(NSData *)theData;

/**
 * Reads a certain amount of bytes from the socket.
 * @param length The length to read from the socket.
 * @return The data of the specified length.  If the socket hits
 * EOF before the data is filled, this returns the data that was
 * read.
 * @throws SKSocketReadFailedException Thrown when the read fails.
 * @throws SKSocketNotOpenException Thrown when the socket is not open for reading.
 */
- (NSData *)readData:(UInt32)length;

/**
 * Closes the socket if it is open.
 * @throws SKSocketNotOpenException Thrown if the socket is already closed, or simply
 * not open.
 */
- (void)close;

@end
