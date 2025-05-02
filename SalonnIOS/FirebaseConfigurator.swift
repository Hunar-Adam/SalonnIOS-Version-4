import Foundation
import FirebaseCore
import FirebaseAnalytics
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import FirebaseMessaging

enum BuildEnvironment: String {
    case dev = "Dev"
    case staging = "Staging"
    case prod = "Prod"
    
    static var current: BuildEnvironment {
        // Get the current bundle ID
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        
        // Check if it contains specific environment identifiers
        if bundleID.contains(".staging") {
            print("🏗️ Running in STAGING mode (detected from bundle ID)")
            return .staging
        } else if bundleID.contains(".dev") {
            print("🏗️ Running in DEBUG mode (detected from bundle ID)")
            return .dev
        } else {
            print("🏗️ Running in PRODUCTION mode (detected from bundle ID)")
            return .prod
        }
        
        // Previous implementation using compiler flags - kept as comment for reference
        /*
        #if DEBUG
        print("🏗️ Running in DEBUG mode")
        return .dev
        #elseif STAGING
        print("🏗️ Running in STAGING mode")
        return .staging
        #else
        print("🏗️ Running in PRODUCTION mode")
        return .prod
        #endif
        */
    }
    
    var bundleId: String {
        switch self {
        case .dev:
            return "com.sanmedia.SalonnIOS.dev"
        case .staging:
            return "com.sanmedia.SalonnIOS.staging"
        case .prod:
            return "com.sanmedia.SalonnIOS"
        }
    }
    
    var displayName: String {
        switch self {
        case .dev:
            return "Salonn Dev"
        case .staging:
            return "Salonn Stage"
        case .prod:
            return "Salonn"
        }
    }
}

class FirebaseConfigurator {
    static func configure() {
        // Wrap everything in a do-catch to prevent crashes
        do {
            print("\n=== 🔥 Firebase Configuration Starting ===")
            
            // 1. Basic environment check
            let environment = BuildEnvironment.current
            print("📱 Environment: \(environment.rawValue)")
            print("📦 Bundle ID: \(Bundle.main.bundleIdentifier ?? "unknown")")
            
            // 2. Early exit if Firebase is already configured
            if FirebaseApp.app() != nil {
                print("ℹ️ Firebase already configured, skipping initialization")
                return
            }
            
            // 3. Find configuration file
            let configFileName = "GoogleService-Info-\(environment.rawValue)"
            print("🔍 Looking for: \(configFileName).plist")
            
            guard let filePath = Bundle.main.path(forResource: configFileName, ofType: "plist") else {
                print("⚠️ Configuration file not found, trying default GoogleService-Info.plist")
                
                // Try default plist as fallback
                guard let defaultPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
                    throw NSError(domain: "FirebaseConfiguratorError",
                                code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "No Firebase configuration file found"])
                }
                print("✅ Using default configuration file")
                try configureFirebase(withPath: defaultPath)
                return
            }
            
            // 4. Configure Firebase with environment-specific file
            try configureFirebase(withPath: filePath)
            
        } catch {
            print("❌ Firebase configuration failed: \(error.localizedDescription)")
            print("⚠️ App will continue without Firebase")
        }
    }
    
    private static func configureFirebase(withPath path: String) throws {
        print("📄 Using configuration from: \(path)")
        
        guard let options = FirebaseOptions(contentsOfFile: path) else {
            throw NSError(domain: "FirebaseConfiguratorError",
                         code: -2,
                         userInfo: [NSLocalizedDescriptionKey: "Invalid Firebase configuration file"])
        }
        
        print("📊 Configuration loaded successfully")
        
        // Configure Firebase
        FirebaseApp.configure(options: options)
        print("✅ Firebase core configured")
        
        // Configure additional services
        configureAdditionalServices()
        
        print("=== ✅ Firebase Configuration Complete ===\n")
    }
    
    private static func configureAdditionalServices() {
        // Analytics
        Analytics.setAnalyticsCollectionEnabled(true)
        print("✅ Analytics configured")
        
        // Auth state
        if Auth.auth().currentUser != nil {
            print("👤 User is already signed in")
        } else {
            print("👤 No user currently signed in")
        }
    }
    
    // Helper method to verify Firebase connection
    static func testConnection() {
        let environment = BuildEnvironment.current
        print("📱 Testing Firebase connection for \(environment.rawValue)...")
        
        // Test Firestore
        Firestore.firestore().collection("test").document().setData([
            "test": true,
            "timestamp": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("❌ Firestore test failed: \(error.localizedDescription)")
            } else {
                print("✅ Firestore test successful")
            }
        }
    }
}
