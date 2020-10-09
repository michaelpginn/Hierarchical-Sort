# Hierarchical-Sort
An algorithm to sort an array in Swift that allows for elements to have a parent-child relationship.

## Why would you need this?
I needed this sort in order to take an unsorted array of "Comment" objects and sort them by date ascending, BUT with the requirement that any comments that were a reply to another comment should appear after that comment (and before the next comment on the level of the parent).

> Disclaimer: This algorithm is only useful if you have items that only have a "parent" field. If your items instead have a "children" field, this will not work.

For instance, given these objects:

A: 1
B: 2
C: 3, child of A

The order should be A, C, B.

## Usage

    let sorted = hierarchicalSort(myObjects, parentIdKeyPath: \MyClass.parentId)
    
where `MyClass` looks something like

    struct MyClass : Equatable, Identifiable, Comparable {
      public let id: String
      public let parentId: String?
      
      ... 
      
    }
    
### Notes

- The function returns an array of Tuples, with the form `(object: T, level: Int)` where the level represents the nesting level of the item. Any items on the top level are given `level: 1`. In the comments example, this was used to determine how much to indent the comment.
- This sort has O(n log n) time complexity.
