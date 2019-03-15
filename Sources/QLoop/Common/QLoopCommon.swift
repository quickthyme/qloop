
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
}
