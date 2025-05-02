import Foundation
import FirebaseAuth
import FirebaseFirestore

enum AuthError: Error {
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case userNotFound
    case wrongPassword
    case networkError
    case unknownError(String)
    
    var localizedDescription: String {
        switch self {
        case .invalidEmail:
            return "The email address is invalid"
        case .weakPassword:
            return "The password is too weak"
        case .emailAlreadyInUse:
            return "This email is already in use"
        case .userNotFound:
            return "No account found with this email"
        case .wrongPassword:
            return "Incorrect password"
        case .networkError:
            return "Network error occurred"
        case .unknownError(let message):
            return message
        }
    }
}

class AuthenticationService {
    // Singleton instance
    static let shared = AuthenticationService()
    
    // Auth reference
    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()
    
    // Current user
    var currentUser: User? {
        guard let firebaseUser = auth.currentUser else { return nil }
        return User(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? "",
            displayName: firebaseUser.displayName
        )
    }
    
    // MARK: - Authentication Methods
    
    /// Signs up a new user with email and password
    func signUp(email: String, password: String, displayName: String) async throws -> User {
        do {
            // Create Firebase Auth user
            let authResult = try await auth.createUser(withEmail: email, password: password)
            
            // Create user profile in Firestore
            let user = User(
                id: authResult.user.uid,
                email: email,
                displayName: displayName,
                role: .customer
            )
            
            try await firestore.collection("users").document(user.id).setData(user.toFirestoreData())
            
            // Update Firebase Auth profile
            let changeRequest = authResult.user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            try await changeRequest.commitChanges()
            
            return user
        } catch let error as NSError {
            switch error.code {
            case AuthErrorCode.invalidEmail.rawValue:
                throw AuthError.invalidEmail
            case AuthErrorCode.weakPassword.rawValue:
                throw AuthError.weakPassword
            case AuthErrorCode.emailAlreadyInUse.rawValue:
                throw AuthError.emailAlreadyInUse
            case AuthErrorCode.networkError.rawValue:
                throw AuthError.networkError
            default:
                throw AuthError.unknownError(error.localizedDescription)
            }
        }
    }
    
    /// Signs in a user with email and password
    func signIn(email: String, password: String) async throws -> User {
        do {
            let authResult = try await auth.signIn(withEmail: email, password: password)
            
            // Fetch user profile from Firestore
            let document = try await firestore.collection("users").document(authResult.user.uid).getDocument()
            
            guard let user = User.fromFirestore(document: document) else {
                throw AuthError.unknownError("Failed to load user profile")
            }
            
            return user
        } catch let error as NSError {
            switch error.code {
            case AuthErrorCode.userNotFound.rawValue:
                throw AuthError.userNotFound
            case AuthErrorCode.wrongPassword.rawValue:
                throw AuthError.wrongPassword
            case AuthErrorCode.networkError.rawValue:
                throw AuthError.networkError
            default:
                throw AuthError.unknownError(error.localizedDescription)
            }
        }
    }
    
    /// Signs out the current user
    func signOut() throws {
        do {
            try auth.signOut()
        } catch {
            throw AuthError.unknownError(error.localizedDescription)
        }
    }
    
    /// Sends a password reset email
    func resetPassword(email: String) async throws {
        do {
            try await auth.sendPasswordReset(withEmail: email)
        } catch {
            throw AuthError.unknownError(error.localizedDescription)
        }
    }
    
    /// Updates the current user's profile
    func updateProfile(displayName: String?, phoneNumber: String?) async throws {
        guard let currentUser = auth.currentUser else {
            throw AuthError.unknownError("No user is signed in")
        }
        
        do {
            // Update Firebase Auth profile
            if let displayName = displayName {
                let changeRequest = currentUser.createProfileChangeRequest()
                changeRequest.displayName = displayName
                try await changeRequest.commitChanges()
            }
            
            // Update Firestore profile
            var updateData: [String: Any] = [:]
            if let displayName = displayName {
                updateData["displayName"] = displayName
            }
            if let phoneNumber = phoneNumber {
                updateData["phoneNumber"] = phoneNumber
            }
            
            if !updateData.isEmpty {
                try await firestore.collection("users").document(currentUser.uid).updateData(updateData)
            }
        } catch {
            throw AuthError.unknownError(error.localizedDescription)
        }
    }
    
    /// Updates the user's role (admin only)
    func updateUserRole(userId: String, role: User.UserRole) async throws {
        // Verify current user is admin
        guard let currentUser = currentUser, currentUser.role == .admin else {
            throw AuthError.unknownError("Only admins can update user roles")
        }
        
        do {
            try await firestore.collection("users").document(userId).updateData([
                "role": role.rawValue
            ])
        } catch {
            throw AuthError.unknownError(error.localizedDescription)
        }
    }
    
    /// Deletes the current user's account
    func deleteAccount() async throws {
        guard let currentUser = auth.currentUser else {
            throw AuthError.unknownError("No user is signed in")
        }
        
        do {
            // Delete user document from Firestore
            try await firestore.collection("users").document(currentUser.uid).delete()
            
            // Delete user from Firebase Auth
            try await currentUser.delete()
        } catch {
            throw AuthError.unknownError(error.localizedDescription)
        }
    }
} 