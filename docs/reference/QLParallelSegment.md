
## QLoop Reference

<br />

#### QLParallelSegment

`QLParallelSegment<Input, Output>`

- type: `class`
- conforms to: `AnySegment`

<br />

##### Creating

- init(_ operations: `[AnyHashable:ParallelOperation]`, combiner: `Combiner?`, errorHandler: `ErrorHandler?`, output: `QLAnchor<Output>?` )


<br />

##### Instance Variables

- input: `QLAnchor<Input>`

- output: `QLAnchor<Output>`

- operationIds: `[AnyHashable]`

- operationQueues: `[AnyHashable: DispatchQueue]`


<br />

##### Diagnostics

- func findSegments(with operationId: `AnyHashable`) -> `[AnySegment]`

- func describeOperationPath( ) -> `String`
