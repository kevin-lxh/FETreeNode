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

- (void)insertChildNode:(FETreeNode *)childNode atIndexPath:(NSIndexPath*)indexPath {
    NSUInteger indexes[indexPath.length];
    [indexPath getIndexes:indexes range:NSMakeRange(0, indexPath.length)];
    
    @try {
        NSUInteger lastIndex = indexes[indexPath.length - 1];
        NSIndexPath *parentNodeIndexPath = [indexPath indexPathByRemovingLastIndex];
        FETreeNode *parentNode = [self nodeAtIndexPath:parentNodeIndexPath];
        [parentNode insertChildNode:childNode atIndex:lastIndex];
    }
    @catch (NSException *exception) {
        //
    }
}

- (void)deleteChildNodeAtIndex:(NSUInteger)index {
    @try {
        FETreeNode *childNode = self.innerChildNodes[index];
        [self.innerChildNodes removeObjectAtIndex:index];
        childNode.innerParentNode = nil;
    }
    @catch (NSException *exception) {
        //
    }
}

- (void)deleteFromParentNode {
    [self.innerParentNode.innerChildNodes removeObject:self];
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
    NSUInteger cursor = 0;
    if (searchType == FETreeNodeSearchTypeDepthFirst) {
        return [self depthFirstSearchNodeAtIndex:index cursor:&cursor];
    }
    
    return [self breadthFirstSearchNodeAtIndex:index nodes:@[self] cursor:&cursor];
}

- (NSUInteger)indexOfNode:(FETreeNode*)node searchType:(FETreeNodeSearchType)searchType {
    NSUInteger cursor = 0;
    if (searchType == FETreeNodeSearchTypeDepthFirst) {
        return [self depthFirstSearchIndexOfNode:node cursor:&cursor];
    }
    
    return [self breadthFirstSearchIndexOfNode:node inNodes:@[self] cursor:&cursor];
}

- (void)enumerateNodesWithSearchType:(FETreeNodeSearchType)searchType usingBlock:(FETreeNodeEnumerationBlock)aBlock {
    NSUInteger cursor = 0;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    if (searchType == FETreeNodeSearchTypeDepthFirst) {
        [self depthFirstEnumerateNodesUsingBlock:aBlock indexPath:indexPath cursor:&cursor];
    }
    
    [self breadthFirstEnumerateNodesUsingBlock:aBlock nodes:@[self] indexPaths:@[indexPath] cursor:&cursor];
}

#pragma mark - Private
- (FETreeNode*)depthFirstSearchNodeAtIndex:(NSUInteger)index cursor:(NSUInteger*)cursor {
    if (*cursor == index) {
        return self;
    }
    else {
        NSInteger numberOfDescendantNodes = [self numberOfDescendantNodes];
        
        if (*cursor + numberOfDescendantNodes >= index) {
            for (FETreeNode *childNode in self.innerChildNodes) {
                *cursor += 1;
                FETreeNode *result = [childNode depthFirstSearchNodeAtIndex:index cursor:cursor];
                if (result) {
                    return result;
                }
            }
        }
        else {
            *cursor += numberOfDescendantNodes;
        }
    }
    
    return nil;
}

- (FETreeNode*)breadthFirstSearchNodeAtIndex:(NSUInteger)index nodes:(NSArray*)nodes cursor:(NSUInteger*)cursor {
    if (nodes.count == 0) {
        return nil;
    }
    
    if (*cursor + nodes.count - 1 >= index) {
        return nodes[index - *cursor];
    }

    NSMutableArray *allChildNodes = [NSMutableArray array];
    for (FETreeNode *node in nodes) {
        [allChildNodes addObjectsFromArray:node.innerChildNodes];
    }

    *cursor += nodes.count;
    return [self breadthFirstSearchNodeAtIndex:index nodes:allChildNodes cursor:cursor];
}

- (NSUInteger)depthFirstSearchIndexOfNode:(FETreeNode*)node cursor:(NSUInteger*)cursor {
    if (self == node) {
        return *cursor;
    }
    else {
        for (FETreeNode *childNode in self.innerChildNodes) {
            *cursor += 1;
            NSUInteger index = [childNode depthFirstSearchIndexOfNode:node cursor:cursor];
            if (index != NSNotFound) {
                return index;
            }
        }
    }
    
    return NSNotFound;
}

- (NSUInteger)breadthFirstSearchIndexOfNode:(FETreeNode*)node inNodes:(NSArray*)nodes cursor:(NSUInteger*)cursor {
    if (nodes.count == 0) {
        return NSNotFound;
    }
    
    NSUInteger index = [nodes indexOfObject:node];
    if (index != NSNotFound) {
        return *cursor + index;
    }
    else {
        NSMutableArray *allChildNodes = [NSMutableArray array];
        for (FETreeNode *n in nodes) {
            [allChildNodes addObjectsFromArray:n.innerChildNodes];
        }
        
        *cursor += nodes.count;
        return [self breadthFirstSearchIndexOfNode:node inNodes:allChildNodes cursor:cursor];
    }
}

- (void)depthFirstEnumerateNodesUsingBlock:(FETreeNodeEnumerationBlock)aBlock indexPath:(NSIndexPath*)indexPath cursor:(NSUInteger*)cursor {
    aBlock(self, indexPath, *cursor);
    
    for (NSInteger i=0; i<self.innerChildNodes.count; i++) {
        FETreeNode *childNode = self.innerChildNodes[i];
        NSIndexPath *childNodeIndexPath = [indexPath indexPathByAddingIndex:i];
        *cursor += 1;
        [childNode depthFirstEnumerateNodesUsingBlock:aBlock indexPath:childNodeIndexPath cursor:cursor];
    }
}

- (void)breadthFirstEnumerateNodesUsingBlock:(FETreeNodeEnumerationBlock)aBlock nodes:(NSArray*)nodes indexPaths:(NSArray*)indexPaths cursor:(NSUInteger*)cursor {
    
    if (nodes.count == 0) {
        return;
    }
    
    NSMutableArray *allChildNodes = [NSMutableArray array];
    NSMutableArray *allChildNodeIndexPaths = [NSMutableArray array];
    
    for (NSInteger i=0; i<nodes.count; i++) {
        FETreeNode *node = nodes[i];
        NSIndexPath *indexPath = indexPaths[i];
        
        aBlock(node, indexPath, *cursor + i);
        
        [allChildNodes addObjectsFromArray:node.innerChildNodes];
        for (NSInteger j=0; j<node.innerChildNodes.count; j++) {
            NSIndexPath *childNodeIndexPath = [indexPath indexPathByAddingIndex:i];
            [allChildNodeIndexPaths addObject:childNodeIndexPath];
        }
    }
    
    *cursor += nodes.count;
    [self breadthFirstEnumerateNodesUsingBlock:aBlock nodes:allChildNodes indexPaths:allChildNodeIndexPaths cursor:cursor];
}

@end
