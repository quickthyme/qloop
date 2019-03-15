
public struct QLoopCommon {

    public struct Config {

        public struct Anchor {

            public static var releaseValues: Bool = {
                #if !DEBUG
                return true
                #else
                return false
                #endif
            }()
        }
    }

    public struct Operation {
    }

    public struct Path {
        func Disconnected<Input, Output>() -> QLoopPath<Input, Output> {
            return
                QLoopPath<Input, Output>(
                    QLoopLinearSegment<Input, Output>(
                        "DisconnectedLoopSegment",
                        ({ (_, _) in }) ))!
        }
    }
}
