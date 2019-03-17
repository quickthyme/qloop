
## QLoop Reference

<br />

#### QLoop

`QLoop<Input, Output>`

- type: `class`
- conforms to: `QLoopIterable`


<br />

##### Creating

- init( )

- init(onChange: `(Output?)->()`)

- init(iterator: `QLoopIterating`, onChange: `(Output?)->()`)

- init(iterator: `QLoopIterating`, onChange: `(Output?)->()`, onError: `(Error)->()`)


<br />

##### Instance Variables

- input: `QLAnchor<Input>`

- output: `QLAnchor<Output>`

- discontinue: `Bool`

- shouldResume: `Bool`

- onChange: `(Input?)->()`

- onError: `(Error)->()`

- iterator: `QLoopIterating`


<br />

##### Managing behavior

- bind(path: `QLPath`)

- destroy( )


<br />

##### Executing

- perform( )

- perform(_ inputValue: `Input?`)

- performFromLastOutput( )


<br />

##### Diagnostics

- func findSegments(with operationId: `AnyHashable` ) -> `[AnySegment]`

- func describeOperationPath( ) -> `String`
