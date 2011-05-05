//
//  SKTCPSSLSocket.h
//  SocketKit
//
//  Created by Alex Nichol on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <openssl/rand.h>
#include <openssl/ssl.h>
#include <openssl/err.h>
#import "SKTCPSocket.h"

#define SKTCPSSLSocketSSLException @"SKTCPSSLSocketSSLException"
#define SKPublicKeyInvalid @"SKPublicKeyInvalid"
#define SKPrivateKeyInvalid @"SKPrivateKeyInvalid"

/**
 * This encloses a socket using OpenSSL.  That means that you only
 * need to call -close on this object, not on the object
 * that it encloses.
 */
@interface SKTCPSSLSocket : SKSocket {
    SKTCPSocket * tcpSocket;
	SSL * sslHandle;
    SSL_CTX * sslContext;
}

/**
 * Creates an OpenSSL socket with a TCP socket.
 * @param aSocket The TCP socket to wrap using OpenSSL.
 * @throws SKTCPSSLSocketSSLException Thrown when OpenSSL has an internal error,
 * or the remote host fails to negotiate correctly.
 * @discussion This method will block either until the SSL
 * handshake has been completed, or the SSL handshake fails.
 */
- (id)initWithTCPSocket:(SKTCPSocket *)aSocket;

/**
 * Creates an OpenSSL socket with a TCP socket.
 * This method runs an accept for the SSL handshake, which
 * is the job of the server.
 * @param aSocket The TCP socket to wrap using OpenSSL.
 * @param pKey A path to a public key file (must be a certificate.)
 * @param privateKey A path to a private key file that matches the public key.
 * @throws SKTCPSSLSocketSSLException Thrown when OpenSSL has an internal error,
 * or the remote host fails to negotiate correctly.
 * @throws SKPublicKeyInvalid Thrown when OpenSSL cannot load the public key.
 * @throws SKPrivateKeyInvalid Thrown when OpenSSL cannot load the private key, or
 * when the private key doesn't match the public key.
 * @discussion This method will block either until the SSL
 * handshake has been completed, or the SSL handshake fails.
 * It is important to note that if your certificate or
 * private key is password protected, this will prompt for a password
 * through standard input.  This is why you should use an unencrypted
 * key and certificate for this function.
 */
- (id)initWithServerTCPSocket:(SKTCPSocket *)aSocket publicKey:(NSString *)pKey privateKey:(NSString *)privateKey;

/**
 * Returns the internal OpenSSL handle.
 */
- (SSL *)sslHandle;

@end
