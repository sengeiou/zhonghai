//
//  DTObjectBlockExecutor.h
//  DTFoundation
//
//  Created by Oliver Drobnik on 12.02.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

/**
 This class is used by [NSObject addDeallocBlock:] to execute blocks on dealloc
 */

@interface DTObjectBlockExecutor : NSObject

/**
 Convenience method to create a block executor with a deallocation block
 */
+ (id)blockExecutorWithDeallocBlock:(void(^)())block;

/**
 Block to execute when dealloc of the receiver is called
 */
@property (nonatomic, copy) void (^deallocBlock)();

@end
