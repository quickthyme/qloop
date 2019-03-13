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

If you're familiar with "promise chains", then you will no doubt feel right
at home, here. In many ways, QLoop works very much like promises: link together
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

Compose sequences of asynchronous operation `segments`, then wrap them
up into *observable* loops. Decorating a given entity with loops allows it
to react to output streams using simple `onChange` and `onError` events.

![loops](loops.png)

Because loops are circular, they provide both `output` (**observation**) as
well as `input` (**delegation**) anchors.

Loops can also be connected to other `loops`, `paths`, or `segments`;
basically anything that can bind to an `anchor`.

By default, a QLoop has no bound functionality on creation. You must bestow
its behavior by binding it to paths and/or segments.


<br />

### Paths

The default segment constructors allow them to be linked explicitly,
in a type-safe manner, but they can quickly become difficult to read
or muck around with for any practical use of chaining.

Instead, `QLoopPath` is provided, which allows you to compose series
of segments together, in a less-violent, more readable way.

We don't have to give up complete type safety, however, as the failable
initializer will return `nil` if any segment fails to link to one of its
neighboring segments.

You always have a way to ensure everything is correct. Besides, it's
trivial to verify the operation chains in our unit-tests, thanks to their
ability to consistently describe themselves.

The main benefit of using `path`, is that it improves readability
of composed `segments`, as well as providing a convenient bundle which
can then be bound to any loop, or combined with other paths and/or
segments to form even more complex operation chains.


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

<br />

### Anchors

An `anchor` is what facilitates the contract binding the segments. Binding
to an anchor essentially means to respond to its `onChange(_)` and/or
`onError(_)` events.

Anchors only receive `input` or `error`, and can only have one subscriber
at a time. When connecting segments together, the output anchor of the first
gets assigned to the input anchor provided by the next. (Segments only ever
observe their own input anchor.)

<br />

-

For more, please refer to the **[Getting Started](getting-started.md)** guide
or try out the **[demo app](https://github.com/quickthyme/qloop-demo)**!

<br />
