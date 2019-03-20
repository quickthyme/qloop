
## QLoop Reference

<br />

#### QLAnchor

`QLAnchor<Input>`

- type: `class`
- conforms to: `AnyAnchor`

<br />

##### Creating

- init( )

- init(onChange: `(Input?)->()` )

- init(onChange: `(Input?)->()`, onError: `(Error)->()` )


<br />

##### Instance Variables

- value: `Input?`

- error: `Error?`

- onChange: `(Input?)->()`

- onError: `(Error)->()`

- inputSegment: `AnySegment?`


<br />

##### Configuration

By default, `QLAnchor` always remembers the last `value` or `error` it received, but
it  **releases them in production builds**. This behavior can be disabled by
setting the anchor global config `releaseValues` to `false`:

`QLCommon.Config.Anchor.releaseValues = false`

<br />

##### Discussion

An `anchor` is what facilitates the **contract** binding segments. To bind
to an anchor essentially means to respond to its `onChange(_)` and/or
`onError(_)` events.

- An `anchor` can only receive a `value` or an `error`
- An `anchor` can only have **one subscriber**
- An `anchor` *can* have **any number of input providers**
- An `anchor` raises `onChange` and `onError` on the *main thread* by **default**

Regarding that last item, you can feed an anchor from multiple inputs, but it can
*retain* only one `segment` at a time.

`QLAnchor` implements a type of **semaphore** that makes use of synchronous dispatch
queues around its `value` and `error` nodes. Inputs can safely arrive on any thread,
and the events are guaranteed to arrive in serial fashion, although their order is not.

Anchors always raise the `onChange` and `onError` events on the main thread.
