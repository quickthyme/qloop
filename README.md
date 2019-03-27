# ![qloop](docs/icon.png) QLoop

![release_version](https://img.shields.io/github/tag/quickthyme/qloop.svg?label=release)
[![build status](https://travis-ci.org/quickthyme/qloop.svg?branch=master)](https://travis-ci.org/quickthyme/qloop)
[![swiftpm_compatible](https://img.shields.io/badge/swift_pm-compatible-brightgreen.svg?style=flat) ](https://swift.org/package-manager/)
![license](https://img.shields.io/github/license/quickthyme/qloop.svg?color=black)

**QLoop** /'kyoo•loop/ - *n* - Declarative asynchronous operation loops

  - compose asynchronous operation paths as reusable "loop" constructs
  - *test-friendly* observer-pattern module favoring declarative composition
  - built-in error propagation
  - swiftPM compatible package
  - universal module; Swift 4.2+, 5 (default)

Compose `paths` of asynchronous operation `segments`, then bind them to anchors
or wrap them up into *observable* loops. Simply decorate an entity with empty `loops`
and/or `anchors`, and implement the `onChange` and/or `onError` events.

Designed to be simple to use, test, and debug. *(Or so it's intended.)*

<br />

## [Introduction](docs/introduction.md)

a.k.a. *[what it is and what it does](docs/introduction.md)*.


## [Getting Started](docs/getting-started.md)

How to *[install and start using](docs/getting-started.md)* it.


## [API Reference](docs/reference.md)

Basically just a listing of the *[classes, functions, and arguments](docs/reference.md)* that make up QLoop.


## [Change Log](docs/changelog.md)

On-going *[summary of pertinent changes](docs/changelog.md)* from one version to the next.


## [Demo App](https://github.com/quickthyme/qloop-demo)

The example app, *[qloop-demo](https://github.com/quickthyme/qloop-demo)*,
demonstrates how to write a declarative iOS app using QLoop, which includes
real-world working examples of static composition, error handling, concurrent
threads, and unit-testing.

 
 <br />
 
---

Enjoying QLoop? You might check out its soul-mate:
*[QRoute](https://github.com/quickthyme/qroute)*,
a library providing declarative navigation and routing features with similar
enthusiasm. Using them together, or separately, is up to you.

:)
