# ![qloop](icon.png) QLoop

**QLoop** /'kyoo•loop/ - *n* - Declarative asynchronous operation loops

## Getting Started

This guide will help you get started with using QLoop, and assumes you already
know your way around [Xcode](https://developer.apple.com/xcode/) and/or
the [Swift Package Manager](https://swift.org/package-manager/).

<br />

### 1) Install the package

Either add it as a *submodule* or use **SwiftPM** ...

<br />

#### Using Xcode

When importing the library for use in an Xcode project (such as for an iOS or
OSX app), then one solid choice is to simply add it as a git *submodule*:
  
```
    mkdir -p submodule
    git submodule add https://github.com/quickthyme/qloop.git submodule/qloop

```

Next, link the **QLoop.xcodeproj** as a dependency of your project by dragging
it from the Finder into your open project or workspace.

Once you have the project linked, it's build scheme and products will be
selectable from drop-downs in your Xcode project. Just add `QLoop` to your
target's dependencies and `libQLoop-<arch>.a` to the linking phase, and you're
all set!

<br />

#### Using the Swift Package Manager

QLoop supports the [Swift Package Manager](https://swift.org/package-manager/).
It works fine in any Swift project on any Swift platform, including OSX and Linux.
Just add the dependency to your `Package.swift` file:

  - package: `QLoop`
  - url: `https://github.com/quickthyme/qloop.git`

Then just ...

```
    swift resolve
```
That's it, nothing else to do except start using it...

<br />

### 2) Pin an "empty" *loop* to some entity:

```
import UIKit
import QLoop

class ManaViewController: UIViewController {

    @IBAction func magicAction(_ sender: AnyObject?) {
        doMagicLoop.perform(true)
    }

    lazy var doMagicLoop = QLoop<Void, Sparkles>(

        onChange: ({ sparkles in
            self.manaView.showSparkles()
        }),

        onError: ({ error in
            self.manaView.showError()
        }))
}

```

<br />

### 3) Implement your asynchronous *operations*:

```
func MakeSparkles(awesomeSauce: Combustible) -> (((String?), (String?)->()) throws -> ()) {
    let powder = grind(awesomeSauce)
    return { input, completion in
        result = Heat(powder, level: 11)
        completion(result)
    }
}
```

<br />

### 4) Bind a *path* to the loop:

```
    func inject() {
        manaViewController
            .doMagicLoop.bind(path:

                QLoopPath<Void, Sparkles>(
                    QLoopLinearSegment(1, MakeSparkles(awesomeSauce: .unicornSriracha)),
                    QLoopLinearSegment(2, SafetyInspectSparkles()))
    }

```

<br />

### 5) Write *tests*:

```
...
    func test_when_magicAction_then_it_runs_the_loop() {
        subject.magicAction(nil)
        XCTAssertEqual(subject.doMagicLoop.inputAnchor.input, true)
    }
...
```

<br />

For more, please check out the [demo app](https://github.com/quickthyme/qloop-demo)
,
or read the [Introduction](introduction.md).

