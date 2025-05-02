import Foundation
import SwiftUI

@MainActor
class AuthenticationViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    // Form fields
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var displayName = ""
    @Published var phoneNumber = ""
    
    // Form validation
    var isEmailValid: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    var isPasswordValid: Bool {
        return password.count >= 8
    }
    
    var passwordsMatch: Bool {
        return password == confirmPassword
    }
    
    var isSignUpFormValid: Bool {
        return isEmailValid && isPasswordValid && passwordsMatch && !displayName.isEmpty
    }
    
    var isSignInFormValid: Bool {
        return isEmailValid && isPasswordValid
    }
    
    // MARK: - Authentication Methods
    
    func signUp() async {
        guard isSignUpFormValid else {
            errorMessage = "Please fill in all fields correctly"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            let user = try await AuthenticationService.shared.signUp(
                email: email,
                password: password,
                displayName: displayName
            )
            
            currentUser = user
            isAuthenticated = true
            clearForm()
        } catch let error as AuthError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "An unexpected error occurred"
        }
        
        isLoading = false
    }
    
    func signIn() async {
        guard isSignInFormValid else {
            errorMessage = "Please enter a valid email and password"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            let user = try await AuthenticationService.shared.signIn(
                email: email,
                password: password
            )
            
            currentUser = user
            isAuthenticated = true
            clearForm()
        } catch let error as AuthError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "An unexpected error occurred"
        }
        
        isLoading = false
    }
    
    func signOut() {
        do {
            try AuthenticationService.shared.signOut()
            currentUser = nil
            isAuthenticated = false
        } catch {
            errorMessage = "Failed to sign out"
        }
    }
    
    func resetPassword() async {
        guard isEmailValid else {
            errorMessage = "Please enter a valid email address"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            try await AuthenticationService.shared.resetPassword(email: email)
            errorMessage = "Password reset email sent"
        } catch let error as AuthError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "An unexpected error occurred"
        }
        
        isLoading = false
    }
    
    func updateProfile() async {
        isLoading = true
        errorMessage = ""
        
        do {
            try await AuthenticationService.shared.updateProfile(
                displayName: displayName,
                phoneNumber: phoneNumber
            )
            
            // Refresh current user
            if let user = currentUser {
                currentUser = User(
                    id: user.id,
                    email: user.email,
                    displayName: displayName,
                    phoneNumber: phoneNumber,
                    profileImageURL: user.profileImageURL,
                    role: user.role,
                    createdAt: user.createdAt,
                    updatedAt: Date()
                )
            }
            
            errorMessage = "Profile updated successfully"
        } catch let error as AuthError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "An unexpected error occurred"
        }
        
        isLoading = false
    }
    
    func deleteAccount() async {
        isLoading = true
        errorMessage = ""
        
        do {
            try await AuthenticationService.shared.deleteAccount()
            currentUser = nil
            isAuthenticated = false
            clearForm()
        } catch let error as AuthError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "An unexpected error occurred"
        }
        
        isLoading = false
    }
    
    // MARK: - Helper Methods
    
    private func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
        displayName = ""
        phoneNumber = ""
    }
    
    func loadCurrentUser() {
        currentUser = AuthenticationService.shared.currentUser
        isAuthenticated = currentUser != nil
        
        if let user = currentUser {
            displayName = user.displayName ?? ""
            phoneNumber = user.phoneNumber ?? ""
        }
    }
} 