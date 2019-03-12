# ![qloop](icon.png) QLoop

**QLoop** /'kyoo•loop/ - *n* - Declarative asynchronous operation loops

## Introduction

Here is an introduction to the [QLoop](https://github.com/quickthyme/qloop) library, and
what it does. It assumes that you already have a basic understanding of Swift. Although,
knowledge of Xcode or any other IDE will be irrelevant to the topics covered here.

At a high level, the features provided are:

  - compose asynchronous operation paths as reusable "loop" constructs
  - *test-friendly* observer-pattern module favoring declarative composition
  - built-in error propagation
  - swiftPM compatible package
  - universal cross-platform

<br />

#### More promising

In a lot of ways, QLoop works very much like "promise chains", but with a few
twists. Like promises, loops allow you to link asynchronous operations, propagate
results between them, safely handle exceptions, and provide observable results.
Unlike promises, however, QLoop makes it easy to statically compose, thoroughly
test, inspect, and reason over complex operating routines with minimal effort.

QLoop enables *declarative-reactive* development **without obfuscation** or
spaghetti mess. Compared to some similar frameworks, it is extremely
light-weight, non-imposing, and universally cross-platform.

#### Less Testing

Testing and composition are primary use-cases, so rather than make setting up
the test environment more difficult, it actually simplifies it a great deal.
One way this is achieved, is that loops essentially mock themselves, given
that they are naturally empty and void of personality until something binds
to its anchors. Each anchor acts as a sort of landing pad for any input it
receives, or for "output anchors", anything it emits. So everything you need
to simulate reactions for testing purposes comes built-in.

Another testing-oriented feature is `describeOperationPath()`, which
produces human-readable, as well as reliably-parsable, snapshots that can
be used for diagnostic purposes and/or for test comparisons.


<br />

### Loops

Compose sequences of asynchronous operation `segments`, then wrap them
up into *observable* loops. Decorating a given entity with loops allows it
to react to output streams using simple `onChange` and `onError` events.

![loops](loops.png)

Because loops are circular, they provide both `input` (**observation**) as
well as `output` (**delegation**) anchors, which relieves many of the
infrastructural demands otherwise often placed on the developer.


<br />

### Segments

Operation `segments` are the vehicles that drive your custom `operations`.
Segments can be run independently, or linked together in order to form any
number of complex sequences.

![segments](segments.png)

To choose from currently there are `linear segments`, those which perform
a **single operation** and then move on, and then there are `compound segments`,
those which perform **multiple operations simultaneously**, waiting for them
all to complete before moving on.


<br />

### Anchors

An `anchor` is what facilitates the contract binding the segments. Binding
to an anchor means to respond to its `onChange(_)` and/or `onError(_)` events.


