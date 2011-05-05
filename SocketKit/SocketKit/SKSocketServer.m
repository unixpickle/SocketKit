//
//  SKSocketServer.m
//  SocketKit
//
//  Created by Alex Nichol on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SKSocketServer.h"


@implementation SKSocketServer

- (void)listen {
	NSString * reason = [NSString stringWithFormat:@"The class %@ is abstract and must be subclassed.", NSStringFromClass([self class])];
	@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
}

- (SKSocket *)acceptConnection {
	NSString * reason = [NSString stringWithFormat:@"The class %@ is abstract and must be subclassed.", NSStringFromClass([self class])];
	@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
}

- (void)stopServer {
	NSString * reason = [NSString stringWithFormat:@"The class %@ is abstract and must be subclassed.", NSStringFromClass([self class])];
	@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
}

@end
