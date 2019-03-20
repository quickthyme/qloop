
public struct QLCommon {

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

    public enum Error: Swift.Error {
        case AnchorMismatch
        case Unknown
        case ThrownButNotSet
    }
}
