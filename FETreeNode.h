//
//  FETreeNode.h
//  Account
//
//  Created by Tina on 16/3/26.
//  Copyright © 2016年 Tracy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FETreeNode;

typedef enum {
    FETreeNodeSearchTypeDepthFirst,
    FETreeNodeSearchTypeBreadthFirst
} FETreeNodeSearchType;

typedef void (^FETreeNodeEnumerationBlock) (FETreeNode *node, NSIndexPath *indexPath, NSUInteger index);

@interface FETreeNode : NSObject

@property (nonatomic, strong) id represenedObject;
@property (nonatomic, readonly) NSIndexPath *indexPath;
@property (nonatomic, readonly) NSUInteger level;
@property (nonatomic, readonly) BOOL isLeaf;
@property (nonatomic, readonly, weak) FETreeNode *parentNode;
@property (nonatomic, readonly) NSArray<FETreeNode*> *childNodes;
@property (nonatomic, readonly) NSUInteger numberOfDescendantNodes;

+ (id)nodeWithRepresentedObject:(id)representedObject;
- (id)initWithRepresentedObject:(id)representedObject;

- (void)appendChildNode:(FETreeNode*)childNode;
- (void)insertChildNode:(FETreeNode*)childNode atIndex:(NSUInteger)index;
- (void)insertChildNode:(FETreeNode *)childNode atIndexPath:(NSIndexPath*)indexPath;

- (void)deleteChildNodeAtIndex:(NSUInteger)index;
- (void)deleteFromParentNode;

- (FETreeNode*)nodeAtIndexPath:(NSIndexPath*)indexPath;
- (FETreeNode*)nodeAtIndex:(NSUInteger)index searchType:(FETreeNodeSearchType)searchType;

- (NSUInteger)indexOfNode:(FETreeNode*)node searchType:(FETreeNodeSearchType)searchType;

- (void)enumerateNodesWithSearchType:(FETreeNodeSearchType)searchType usingBlock:(FETreeNodeEnumerationBlock)aBlock;

@end
