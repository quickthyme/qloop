
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


<br />

##### Diagnostics

- findSegments(with operationId: `AnyHashable`) -> `[AnySegment]`

- describeOperationPath( ) -> `String`
