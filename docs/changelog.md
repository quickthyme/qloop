# ![qloop](icon.png) QLoop

**QLoop** /'kyoo•loop/ - *n* - Declarative asynchronous operation loops

## Change Log


<br />

### 0.1.4

- updated for swift 5
- `QLoopIteratingResettable` separated from `QLoopIterating`
  (avoids having to implement empty `reset()` functions on iterators that
  never reset.)

<br />

### 0.1.3

- added `bind(segment:)` to `QLoop`
- fixed dispatch bug in `QLParallelSegment`


<br />

### 0.1.2

- `QLoop` upgrades
  - `onFinal` is now a thing ( called the same way as onChange, except only on final *iteration* )
- `QLAnchor` upgrades
  - default output and error sent on main thread (can be overriden if necessary)
- `QLParallelSegment` upgrades
  - guarantees async dispatch of operations
  - more reliable operation completion handling
- `QLSerialSegment` upgrades
  - now can assign dispatch queue
  - guarantees async dispatch of operation


<br />

### 0.1.1

 - renaming and simplified interfaces
 - `QLParallelSegment` upgrades
   - supports assignment of dispatch queues per `operationId`
   - thread safety around operation runs
   - operations can now output any type
   - simpler `combiner` no longer requires intermediate type


<br />

### 0.1.0

 - initial alpha testing release
 - cleaner testing support 

<br />
