
## QLoop Reference

<br />

#### QLPath

`QLPath<Input, Output>`

- type: `class`


<br />

##### Creating

- init?(_ segments: `AnySegment...`)


<br />

##### Instance Variables

- input: `QLAnchor<Input>`

- output: `QLAnchor<Output>`



<br />

##### Diagnostics

- func findSegments(with operationId: `AnyHashable`) -> `[`AnySegment]

- func describeOperationPath( ) -> `String`
