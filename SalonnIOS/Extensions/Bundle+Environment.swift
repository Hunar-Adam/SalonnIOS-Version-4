import Foundation

extension Bundle {
    enum AppEnvironment: String {
        case dev = "Dev"
        case staging = "Staging"
        case prod = "Production"
    }
    
    var appEnvironment: AppEnvironment {
        guard let bundleID = bundleIdentifier else { return .dev }
        
        if bundleID.hasSuffix(".dev") {
            return .dev
        } else if bundleID.hasSuffix(".stage") || bundleID.hasSuffix(".staging") {
            return .staging
        } else {
            return .prod
        }
    }
} 