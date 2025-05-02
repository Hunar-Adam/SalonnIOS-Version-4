import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                // Profile Section
                Section(header: Text("Profile")) {
                    FormField(
                        title: "Display Name",
                        placeholder: "Enter your name",
                        text: $viewModel.displayName
                    )
                    
                    FormField(
                        title: "Phone Number",
                        placeholder: "Enter your phone number",
                        text: $viewModel.phoneNumber,
                        keyboardType: .phonePad
                    )
                    
                    if let user = viewModel.currentUser {
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(user.email)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Role")
                            Spacer()
                            Text(user.role.rawValue.capitalized)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Account Section
                Section(header: Text("Account")) {
                    Button(action: {
                        Task {
                            await viewModel.updateProfile()
                        }
                    }) {
                        if viewModel.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else {
                            Text("Update Profile")
                        }
                    }
                    
                    Button(action: {
                        Task {
                            await viewModel.resetPassword()
                        }
                    }) {
                        Text("Reset Password")
                    }
                    
                    Button(action: {
                        Task {
                            await viewModel.deleteAccount()
                        }
                    }) {
                        Text("Delete Account")
                            .foregroundColor(.red)
                    }
                }
                
                // Sign Out Section
                Section {
                    Button(action: {
                        viewModel.signOut()
                        dismiss()
                    }) {
                        Text("Sign Out")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.loadCurrentUser()
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
} 