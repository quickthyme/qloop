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


