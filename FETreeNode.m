//
//  FETreeNode.m
//  Account
//
//  Created by Tina on 16/3/26.
//  Copyright © 2016年 Tracy. All rights reserved.
//

#import "FETreeNode.h"

@interface FETreeNode ()
@property (nonatomic, weak) FETreeNode *innerParentNode;
@property (nonatomic, strong) NSMutableArray *innerChildNodes;
@end

@implementation FETreeNode

+ (id)nodeWithRepresentedObject:(id)representedObject {
    return [[FETreeNode alloc] initWithRepresentedObject:representedObject];
}

- (id)initWithRepresentedObject:(id)representedObject {
    self = [self init];
    if (self) {
        self.represenedObject = representedObject;
    }
    
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        self.innerChildNodes = [NSMutableArray array];
    }
    return self;
}

- (NSIndexPath*)indexPath {
    NSMutableArray *wrappedIndexes = [NSMutableArray array];
    
    FETreeNode *node = self;
    while (YES) {
        if (node.parentNode) {
            NSUInteger index = [node.innerParentNode.innerChildNodes indexOfObject:node];
            [wrappedIndexes insertObject:@(index) atIndex:0];
            node = node.parentNode;
        }
        else {
            [wrappedIndexes insertObject:@0 atIndex:0];
            break;
        }
    }
    
    NSUInteger indexes[wrappedIndexes.count];
    for (NSInteger i=0; i<wrappedIndexes.count; i++) {
        indexes[i] = [wrappedIndexes[i] integerValue];
    }
    
    return [NSIndexPath indexPathWithIndexes:indexes length:wrappedIndexes.count];
}

- (NSUInteger)level {
    return [self indexPath].length;
}

- (BOOL)isLeaf {
    return (self.innerParentNode != nil);
}

- (FETreeNode*)parentNode {
    return self.innerParentNode;
}

- (NSArray<FETreeNode*>*)childNodes {
    return [self.innerChildNodes copy];
}

- (NSUInteger)numberOfDescendantNodes {
    NSUInteger number = 0;
    for (FETreeNode *childNode in self.innerChildNodes) {
        number += [childNode numberOfDescendantNodes] + 1;
    }
    
    return number;
}

- (void)appendChildNode:(FETreeNode *)childNode {
    [self.innerChildNodes addObject:childNode];
    childNode.innerParentNode = self;
}

- (void)insertChildNode:(FETreeNode*)childNode atIndex:(NSUInteger)index {
    [self.innerChildNodes insertObject:childNode atIndex:index];
    childNode.innerParentNode = self;
}

- (void)deleteChildNodeAtIndex:(NSUInteger)index {
    FETreeNode *childNode = self.innerChildNodes[index];
    [self.innerChildNodes removeObjectAtIndex:index];
    childNode.innerParentNode = nil;
}

- (void)deleteFromParent {
    [self.innerChildNodes removeObject:self];
    self.innerParentNode = nil;
}

- (FETreeNode*)nodeAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.length == 0) {
        return nil;
    }
    
    if (indexPath.length == 1 && [indexPath indexAtPosition:0] == 0) {
        return self;
    }
    
    NSUInteger indexes[indexPath.length];
    [indexPath getIndexes:indexes range:NSMakeRange(0, indexPath.length)];
    
    @try {
        FETreeNode *node = self;
        for (NSInteger i=1; i<indexPath.length; i++) {
            NSUInteger index = indexes[i];
            node = node.innerChildNodes[index];
        }
        
        return node;
    }
    @catch (NSException *exception) {
        return nil;
    }
}

- (FETreeNode*)nodeAtIndex:(NSUInteger)index searchType:(FETreeNodeSearchType)searchType {
    NSUInteger numberOfPreviousNodes = 0;
    if (searchType == FETreeNodeSearchTypeDepthFirst) {
        return [self depthFirstSearchNodeAtIndex:index numberOfPreviousNodes:&numberOfPreviousNodes];
    }
    
    return [self breadthFirstSearchNodeAtIndex:index nodes:@[self] numberOfPreviousNodes:&numberOfPreviousNodes];
}

- (NSUInteger)indexOfNode:(FETreeNode*)node searchType:(FETreeNodeSearchType)searchType {
    NSUInteger numberOfPreviousNodes = 0;
    if (searchType == FETreeNodeSearchTypeDepthFirst) {
        return [self depthFirstSearchIndexOfNode:node numberOfPreviousNodes:&numberOfPreviousNodes];
    }
    
    return [self breadthFirstSearchIndexOfNode:node inNodes:@[self] numberOfPreviousNodes:&numberOfPreviousNodes];
}

#pragma mark - Private
- (FETreeNode*)depthFirstSearchNodeAtIndex:(NSUInteger)index numberOfPreviousNodes:(NSUInteger*)numberOfPreviousNodes {
    if (*numberOfPreviousNodes + 1 == index + 1) {
        return self;
    }
    else {
        NSInteger numberOfDescendantNodes = [self numberOfDescendantNodes];
        
        if (*numberOfPreviousNodes + numberOfDescendantNodes + 1 >= index + 1) {
            
            *numberOfPreviousNodes += 1;
            
            for (FETreeNode *childNode in self.innerChildNodes) {
                FETreeNode *result = [childNode depthFirstSearchNodeAtIndex:index numberOfPreviousNodes:numberOfPreviousNodes];
                if (result) {
                    return result;
                }
            }
        }
        else {
            *numberOfPreviousNodes += 1 + numberOfDescendantNodes;
        }
    }
    
    return nil;
}

- (FETreeNode*)breadthFirstSearchNodeAtIndex:(NSUInteger)index nodes:(NSArray*)nodes numberOfPreviousNodes:(NSUInteger*)numberOfPreviousNodes {
    if (nodes.count == 0) {
        return nil;
    }
    
    if (*numberOfPreviousNodes + nodes.count >= index + 1) {
        return nodes[index - *numberOfPreviousNodes];
    }

    NSMutableArray *allChildNodes = [NSMutableArray array];
    for (FETreeNode *node in nodes) {
        [allChildNodes addObjectsFromArray:node.innerChildNodes];
    }

    *numberOfPreviousNodes += nodes.count;
    return [self breadthFirstSearchNodeAtIndex:index nodes:allChildNodes numberOfPreviousNodes:numberOfPreviousNodes];
}

- (NSUInteger)depthFirstSearchIndexOfNode:(FETreeNode*)node numberOfPreviousNodes:(NSUInteger*)numberOfPreviousNodes {
    if (self == node) {
        return *numberOfPreviousNodes;
    }
    else {
        *numberOfPreviousNodes += 1;
        for (FETreeNode *childNode in self.innerChildNodes) {
            NSUInteger index = [childNode depthFirstSearchIndexOfNode:node numberOfPreviousNodes:numberOfPreviousNodes];
            if (index != NSNotFound) {
                return index;
            }
        }
    }
    
    return NSNotFound;
}

- (NSUInteger)breadthFirstSearchIndexOfNode:(FETreeNode*)node inNodes:(NSArray*)nodes numberOfPreviousNodes:(NSUInteger*)numberOfPreviousNodes {
    if (nodes.count == 0) {
        return NSNotFound;
    }
    
    NSUInteger index = [nodes indexOfObject:node];
    if (index != NSNotFound) {
        return *numberOfPreviousNodes + index;
    }
    else {
        NSMutableArray *allChildNodes = [NSMutableArray array];
        for (FETreeNode *n in nodes) {
            [allChildNodes addObjectsFromArray:n.innerChildNodes];
        }
        
        *numberOfPreviousNodes += nodes.count;
        return [self breadthFirstSearchIndexOfNode:node inNodes:allChildNodes numberOfPreviousNodes:numberOfPreviousNodes];
    }
}

@end
