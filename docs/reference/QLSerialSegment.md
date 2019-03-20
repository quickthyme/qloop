
## QLoop Reference

<br />

#### QLSerialSegment

`QLSerialSegment<Input, Output>`

- type: `class`
- conforms to: `AnySegment`

<br />

##### Creating

- init(operationId: `AnyHashable`, operation: `Operation`, errorHandler: `ErrorHandler?`, output: `QLAnchor<Output>?`)


<br />

##### Instance Variables

- input: `QLAnchor<Input>`

- output: `QLAnchor<Output>`

- operationId: `AnyHashable`

- operationQueue: `DispatchQueue`


<br />

##### Diagnostics

- findSegments(with operationId: `AnyHashable`) -> `[AnySegment]`

- describeOperationPath( ) -> `String`


<br />

##### Discussion

Operation `segments` are the vehicles that drive your custom `operations`.
Segments can be run independently, or linked together in order to form any
number of complex sequences.

When connecting segments together, the `input` of the second
gets *assigned* to the `output` of the first, and so on.

- A `segment` only observes its own `input`.
- A `segment` only runs its operation if it has an `output` assigned
