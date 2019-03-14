# ![qloop](icon.png) QLoop

**QLoop** /'kyoo•loop/ - *n* - Declarative asynchronous operation loops

## Introduction

Here is an introduction to the [QLoop](https://github.com/quickthyme/qloop)
library, and what it does. It assumes that you already have a basic
understanding of Swift. Although, knowledge of Xcode or any other IDE will
be irrelevant to the topics covered here.

At a high level, features it provides include:

  - compose asynchronous operation paths as reusable "loop" constructs
  - *test-friendly* observer-pattern module favoring declarative composition
  - built-in error propagation
  - swiftPM compatible package
  - universal cross-platform

#### More promising

If you're familiar with "promise chains", then you will no doubt feel right at
home, here. In many ways, QLoop works very much like promises: link together
asynchronous operations, propagate output and/or errors, handle exceptions
safely, allow for synchronous testing, and expose observable results.

The differences, however, are far less subtle. There's obvious stuff, such
as iteration control and operation grouping. (it is a loop, after all)

But what really makes QLoop stand out, is how well one can statically compose,
thoroughly test, inspect, and reason over complex operations with ease.

QLoop enables *declarative-reactive* development **without obfuscation** or
*callback hell*. And when compared to some similar frameworks, it is extremely
light-weight, non-intrusive, and universally cross-platform.

#### Less mocking

Testing, composition, and inspection are the three top priorities of QLoop.
Rather than make setting up the test environment more difficult, it actually
simplifies it a great deal.

Loops essentially mock themselves, given that they are naturally
empty and void of personality until both of its anchors are bound (which they
are not, by default).

Pretty much everything you need to simulate reactions for testing
purposes comes entirely built-in, saving you the trouble of writing mocks and
other such foolery.

Then there's `describeOperationPath()`, which produces human-readable,
as well as reliably-parsable, "snapshots" that can be used for diagnostic
purposes and/or for test comparisons. You can see exactly which operations
are to be called and in what order.


<br />

### Loops

![loops](loops.png)

Compose entire sequences of asynchronous operation `segments`, then wrap them
up into *observable* loops. Decorating an entity with loops makes it easy
to react to output streams using simple `onChange` and `onError` events.

##### Observation & Delegation

Because loops are circular, they provide both `output` (**observation**) as
well as `input` (**delegation**) anchors.

##### Flavorless

By default, a QLoop has no bound functionality on creation. You must bestow
its behavior by binding it to paths and/or segments.

##### Iteration

Loops provide **iteration**, should it be desired. By default, a loop will
run once per input set, but they can be made to run however you like, simply
by swapping out its `iterator`. There are several included out-of-the-box,
but you can also create your own in order to extend the loop's functionality.

Any iterator you wish to use with QLoop must conform to `QLoopIterating`.

##### Chaining

Loops can also be connected to other `loops`, `paths`, or `segments`;
basically anything that can bind to an `anchor`.



<br />

### Paths

The default segment constructors allow them to be linked explicitly,
in a type-safe manner, but they can quickly become difficult to read
or muck around with for any practical use of chaining.

`QLoopPath` addresses this, by allowing you to compose a series
of segments together, in a less-violent, more readable way.

This is accomplished using *type-erasure*, but we don't have to give up
type safety completely. The *failable initializer* will return `nil` if
any segment in the chain fails to link to one of its neighboring segments.

When using paths, **you always have a way to ensure everything is correct.**
Besides, it's trivial to verify the operation chains in our unit-tests,
thanks to their ability to consistently describe themselves.

Just like with a loop, a path behaves as a bundle for its segments. They
are typically bound to a loop at some point, or combined with other paths
and/or segments to form more complex chains.

The practical benefit of using `path`, is that it improves readability of
composed `segments`. In practice, once "baked in", they seldom need changing.


<br />

### Segments

Operation `segments` are the vehicles that drive your custom `operations`.
Segments can be run independently, or linked together in order to form any
number of complex sequences.

![segments](segments.png)

You do not subclass segments. Instead, you simply attach your asynchronous
operations to them using a contract enforced by a simple swift closure.

There are currently two types of segments to choose from:

 - `QLoopLinearSegment` - performs a **single operation** and then moves on
 - `QLoopCompoundSegment` - performs **multiple concurrent operations**,
   waiting for them all to complete before moving on.

When connecting segments together, the `inputAnchor` of the second
(or *isolated anchor*)
gets *assigned* to the `outputAnchor` of the first, and so on. You can
choose to link segments upon instantiation, or anytime thereafter.

  - A `segment` only observes its own `inputAnchor`.
  - A `segment` only runs its operation if it has an `outputAnchor` assigned


<br />

##### Operations

Operations are your application's workers, interactors, etc. In order to attach
an operation to a segment, it must be compatible (either inately or wrapped)
with this signature:

```
((_ input: String?), _ completion: (_ output: String?) -> ()) throws -> ()
```

That is to say, it must take in an `input` of whatever type (which includes tuples),
perform its operation(s), then either call the completion handler with appropriate
output, or throw an error.


<br />

##### ErrorHandlers

Error handlers are optional things you can add whenever you suspect errors might
get thrown. The error handler signature looks like this:

```
( _ error: Error,
  _ completion: @escaping (_ output: String?) -> (),
  _ errCompletion: @escaping (_ output: String?) -> () ) -> ()
```

Whenever the operation throws an error, or if an error is passed via the input
anchor, then the error handler (if set) will try and handle the error. If it is successful,
then it may choose to call the standard `outputCompletion` with resolved data.
Otherwise, it should forward the error (or generate a new one, depending) down
the line by calling `errCompletion` instead.

The default behavior is to just forward the error.


<br />

### Anchors

An `anchor` is what facilitates the **contract** binding segments. To bind
to an anchor essentially means to respond to its `onChange(_)` and/or
`onError(_)` events.

 - An `anchor` can only receive an `input` or an `error`
 - An `anchor` can only have **one subscriber**
 - An `anchor` *can* have **any number of input providers**

Regarding that last item, you can feed an anchor from multiple inputs, and it
ensures *thread-safety* through the use of Dispatch queues. However, even
though it can have any number of input providers, it can only *retain* one
`segment` at a time.

Only reason this might come up, is probably because you tried to do something
brave such as attempting to fuse several inputs together "mid-stream". While one
*can* do this, in such instances, it would be better to determine whether its
possible to just use a compound segment instead, or maybe consider placing
additional loops.

Remember, the goal here is to *clarify* the *intent*, not to build *Marble Madness*.†


<br />

† - (unless your intent *is* to build *Marble Madness*.)

---

For more, please refer to the **[Getting Started](getting-started.md)** guide
or try out the **[demo app](https://github.com/quickthyme/qloop-demo)**!

<br />
