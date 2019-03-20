
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

`QLParallelSegment` is more powerful than its serial counterpart, but also
more complicated.

Operations in a parallel segment run concurrently. Once they have all completed
their work, the segment calls the `combiner` in order to reduce the values into
the output type the segment is expected to pass.

When setting up parallel segments, you can optionally assign dispatch queues
to the operations by adding it to `operationQueues`. The key is the id of the
operation, the value is the `DispatchQueue` you want it to use.
