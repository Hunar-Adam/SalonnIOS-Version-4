import Foundation
import SwiftUI
import FirebaseAuth

@MainActor
class AppViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    init() {
        print("=== 👤 AppViewModel Initialization ===")
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        print("🔄 Setting up auth state listener...")
        
        // Make sure Firebase Auth is available
        guard Auth.auth() != nil else {
            print("❌ Firebase Auth not initialized")
            self.errorMessage = "Firebase Auth not initialized"
            self.isLoading = false
            return
        }
        
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] (_, firebaseUser) in
            guard let self = self else { return }
            
            if let firebaseUser = firebaseUser {
                print("✅ User authenticated: \(firebaseUser.uid)")
                self.currentUser = User(
                    id: firebaseUser.uid,
                    email: firebaseUser.email ?? "",
                    displayName: firebaseUser.displayName
                )
                self.isAuthenticated = true
            } else {
                print("ℹ️ No user authenticated")
                self.currentUser = nil
                self.isAuthenticated = false
            }
            
            self.isLoading = false
        }
    }
    
    func signIn() {
        print("🔄 Attempting sign in...")
        // For testing only
        isAuthenticated = true
        currentUser = User(id: "test-user", email: "test@example.com", displayName: "Test User")
        print("✅ Test user signed in")
    }
    
    func signOut() {
        print("🔄 Attempting sign out...")
        do {
            try Auth.auth().signOut()
            self.currentUser = nil
            self.isAuthenticated = false
            print("✅ User signed out successfully")
        } catch {
            print("❌ Error signing out: \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
        }
    }
    
    deinit {
        if let handler = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handler)
            print("🧹 Cleaned up auth state listener")
        }
    }
} 