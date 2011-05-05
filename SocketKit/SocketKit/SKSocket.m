//
//  SKSocket.m
//  SocketKit
//
//  Created by Alex Nichol on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SKSocket.h"


@implementation SKSocket

- (BOOL)isOpen {
	NSString * reason = [NSString stringWithFormat:@"The class %@ is abstract and must be subclassed.", NSStringFromClass([self class])];
	@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
}

- (void)writeData:(NSData *)theData {
	NSString * reason = [NSString stringWithFormat:@"The class %@ is abstract and must be subclassed.", NSStringFromClass([self class])];
	@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
}

- (NSData *)readData:(UInt32)length {
	NSString * reason = [NSString stringWithFormat:@"The class %@ is abstract and must be subclassed.", NSStringFromClass([self class])];
	@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
}

- (void)close {
	NSString * reason = [NSString stringWithFormat:@"The class %@ is abstract and must be subclassed.", NSStringFromClass([self class])];
	@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
}

@end
