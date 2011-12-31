//
//  NSIndexSet+Additions.m
//  Chatter
//
//  Created by Jones Curtis on 2011.06.23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSIndexSet+Additions.h"

@implementation NSIndexSet (Additions)

/**
 *
 *
 */
- (NSIndexSet *)intersectionWithIndexes:(NSIndexSet *)aSet
{
	NSMutableIndexSet *intersectingSet = [NSMutableIndexSet indexSet];
	
	[intersectingSet addIndexes:[self indexesPassingTest:(^ BOOL (NSUInteger index, BOOL *stop) {
		return [aSet containsIndex:index];
	})]];
	
	[intersectingSet addIndexes:[aSet indexesPassingTest:(^ BOOL (NSUInteger index, BOOL *stop) {
		return [self containsIndex:index];
	})]];
	
	return intersectingSet;
}

@end
