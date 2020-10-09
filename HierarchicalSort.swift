//
//  VariableTree.swift
//
//  Created by Michael Ginn on 4/9/20.
//  Copyright © 2020 Michael Ginn. All rights reserved.
//

import Foundation

/// Sorts an array of element into the order they would appear in a hierarchical display.
/// 1. If an element is a child of another it appears after the parent and before the next element on the same level as the parent
/// 2. Between children of the same parent, they are sorted in ascending order.
/// - Parameters:
///   - items: The items to be sorted
///   - parentIdKeyPath: The keypath for the class of the items that represents the parent of the item.
/// - Returns: A sorted array of tuples, (element, level) where level is the level in the hierarchy. 1 represents the top level.
internal func hierarchicalSort<Element>(_ items: [Element], parentIdKeyPath: KeyPath<Element, Element.ID?>) -> [(Element, Int)] where Element: Identifiable, Element: Comparable {
    typealias ElementTreeNode = TreeNode<Element>

    // First, convert each item to a node containing the item's value. O(nlogn)
    let nodes = items.map { ElementTreeNode($0) }.sorted()

    // Make a lookup table for our nodes so we can find a parent in O(1) time. O(n)
    let nodeLookup = nodes.reduce([:]) { (dict, node) -> [Element.ID: ElementTreeNode] in
        var dict = dict
        if let item = node.value {
            dict[item.id] = node
        }
        return dict
    }

    // A node to act as the root for the top level comments
    let root: ElementTreeNode = ElementTreeNode()

    // Next, loop through again and for each element, if it has a parent id, find that element and assign the new element to the parent's `children` array, in a sorted fashion
    for node in nodes {
        // Will hold the parent, either root or another node
        var parentNode: ElementTreeNode

        // Determine what the parent node for the element is.
        if let nodeValue = node.value, let parentId = nodeValue[keyPath: parentIdKeyPath] {
            // Find the parent node.
            if let parent = nodeLookup[parentId] {
                // We found the parent great
                parentNode = parent
            } else {
                // We couldn't find the parent. Not good. We won't put it in at all.
                continue
            }
        } else {
            // Node is a parent itself, put it as a child of root
            parentNode = root
        }

        // Now, add the current node to the parentNode's `children` array, sorted
        // We don't need to worry about sorting this manually because we're working through all the nodes sorted already
        parentNode.children.append(node)
    }

    // Now, we have our full tree, held by the `root`
    // Finally, we need to loop through and collapse in the right order
    let collapsedItems = recursiveCollapseTree(node: root)

    return collapsedItems
}

/// Collapses a tree (held by a root) into an array, using a Postorder tree traversal.
/// - Parameters:
///   - node: The node holding the top of the tree or subtree to collapse
///   - level: The current level of the whole tree (starts at 0 for root)
/// - Returns: An array of tuples with (object, level) where level represents the level in the hierarchy. Level 1 represents comments on the top level.
private func recursiveCollapseTree<T>(node: TreeNode<T>, level: Int = 0) -> [(T, Int)] {
    let valArray = node.value == nil ? [] : [(node.value!, level)]
    if node.children.count == 0 {
        // Base case
        return valArray
    } else {
        // Call the method recursively on each child, then combine the current item and it's children arrays into one array.
        let combinedArray = node.children.reduce(valArray) { (arraySoFar, newNode) -> [(T, Int)] in
            arraySoFar + recursiveCollapseTree(node: newNode, level: level + 1)
        }
        return combinedArray
    }
}

/// A helper class that wraps an element and adds a `children` property
private class TreeNode<Element>: Comparable where Element: Comparable {
    static func < (lhs: TreeNode<Element>, rhs: TreeNode<Element>) -> Bool {
        guard let lval = lhs.value, let rval = rhs.value else { return false }
        return lval < rval
    }

    static func == (lhs: TreeNode<Element>, rhs: TreeNode<Element>) -> Bool {
        return lhs.value == rhs.value
    }

    /// The nodes which are children of the node. The array should always be sorted.
    var children: [TreeNode<Element>] = []

    /// The wrapped value of the node.
    var value: Element?

    init(_ value: Element? = nil) {
        self.value = value
    }
}
