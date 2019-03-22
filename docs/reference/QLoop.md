
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

- onFinal: `(Input?)->()`

- onChange: `(Input?)->()`

- onError: `(Error)->()`

- iterator: `QLoopIterating`


<br />

##### Managing behavior

- bind(path: `QLPath` )

- bind(segment: `QLSegment` )

- destroy( )


<br />

##### Executing

- perform( )

- perform( `Input?` )


<br />

##### Diagnostics

- findSegments(with operationId: `AnyHashable` ) -> `[AnySegment]`

- describeOperationPath(  ) -> `String`

<br />

##### Discussion

When subscribing to loop events, understand that both `onChange` and `onFinal` calls
will occur on final loop output. When using the default iteration of "single", then there
is no reason to subscribe to both events. When using one of the infinitely continuous modes,
however, only `onChange` will ever get called.

 - `onChange` is called on every output change
 - `onFinal` is called for the last output when using iterations that have a finite state (in addition to `onChange`)
 - `onFinal` may also be called upon the next iteration if the `discontinue` flag gets set
 (and the iterator being used returns false, as all of the included ones do in this situation.)
 
