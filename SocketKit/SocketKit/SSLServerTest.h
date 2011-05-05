//
//  SSLServerTest.h
//  SocketKit
//
//  Created by Alex Nichol on 5/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKTCPSocketServer.h"
#import "SKTCPSSLSocket.h"


@interface SSLServerTest : NSObject {
    
}

- (void)testServer;
- (void)handleSocket:(SKTCPSSLSocket *)sslSocket;

@end
