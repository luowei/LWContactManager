# Graph Report - /Users/luowei/projects/libs/LWContactManager  (2026-05-04)

## Corpus Check
- Corpus is ~17,737 words - fits in a single context window. You may not need a graph.

## Summary
- 92 nodes · 95 edges · 11 communities detected
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 2 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]

## God Nodes (most connected - your core abstractions)
1. `LWContact` - 8 edges
2. `LWAppDelegate` - 7 edges
3. `LWContactService` - 7 edges
4. `LWContactViewModel` - 7 edges
5. `LWAddressBookService` - 7 edges
6. `LWViewController` - 6 edges
7. `LWPhoneNumber` - 6 edges
8. `Tests` - 4 edges
9. `AuthorizationStatus` - 4 edges
10. `LegacyContactsViewController` - 3 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Communities (18 total, 3 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.23
Nodes (4): ChineseContactsViewController, ContactsViewController, CustomFilterViewController, LegacyContactsViewController

### Community 1 - "Community 1"
Cohesion: 0.27
Nodes (5): Hashable, Identifiable, CNContact, LWContact, LWPhoneNumber

### Community 2 - "Community 2"
Cohesion: 0.24
Nodes (6): AuthorizationStatus, authorized, denied, notDetermined, LWContactViewModel, ObservableObject

### Community 3 - "Community 3"
Cohesion: 0.25
Nodes (7): ContactRow, LWContactPickerView, LWContactPickerView_Previews, PreviewProvider, ContactListView, MyView, View

### Community 4 - "Community 4"
Cohesion: 0.25
Nodes (7): LWAppDelegate, -applicationDidBecomeActive, -applicationDidEnterBackground, -applicationdidFinishLaunchingWithOptions, -applicationWillEnterForeground, -applicationWillResignActive, -applicationWillTerminate

### Community 5 - "Community 5"
Cohesion: 0.25
Nodes (7): LWAddressBookService, -init, -isBlankString, -loadContactsWithSearchTextsuccessBlock, -requestAccess, -serviceWithPrimaryLanguage, -setupAddressBookWithPrimaryLanguage

### Community 6 - "Community 6"
Cohesion: 0.29
Nodes (6): LWViewController, -addressBookService, -reloadSearchAddressBook, -searchText, -viewDidAppear, -viewDidLoad

### Community 8 - "Community 8"
Cohesion: 0.4
Nodes (4): Tests, -setUp, -tearDown, -testExample

## Knowledge Gaps
- **23 isolated node(s):** `-setUp`, `-tearDown`, `-testExample`, `-applicationdidFinishLaunchingWithOptions`, `-applicationWillResignActive` (+18 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `LWContactViewModel` connect `Community 2` to `Community 3`?**
  _High betweenness centrality (0.107) - this node is a cross-community bridge._
- **Why does `LWContactService` connect `Community 7` to `Community 2`?**
  _High betweenness centrality (0.049) - this node is a cross-community bridge._
- **What connects `-setUp`, `-tearDown`, `-testExample` to the rest of the system?**
  _23 weakly-connected nodes found - possible documentation gaps or missing edges._