import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                LogoView()
                
                Text("Create Account")
                    .font(.system(size: 28, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 40)
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Full Name")
                            .font(.system(size: 17))
                            .foregroundColor(Color(.systemGray))
                        TextField("Enter your name", text: $viewModel.displayName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.system(size: 17))
                            .foregroundColor(Color(.systemGray))
                        TextField("Enter your email", text: $viewModel.email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Phone Number (Optional)")
                            .font(.system(size: 17))
                            .foregroundColor(Color(.systemGray))
                        TextField("Enter your phone number", text: $viewModel.phoneNumber)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.phonePad)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Password")
                            .font(.system(size: 17))
                            .foregroundColor(Color(.systemGray))
                        SecureField("Create a password", text: $viewModel.password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Text("Must be at least 8 characters")
                            .font(.system(size: 13))
                            .foregroundColor(Color(.systemGray))
                            .padding(.top, 4)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm Password")
                            .font(.system(size: 17))
                            .foregroundColor(Color(.systemGray))
                        SecureField("Confirm your password", text: $viewModel.confirmPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.top, 10)
                }
                
                Button(action: {
                    Task {
                        await viewModel.signUp()
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Create Account")
                            .font(.system(size: 17, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(hex: "5D3FD3"))
                .foregroundColor(.white)
                .cornerRadius(25)
                .padding(.horizontal, 20)
                .padding(.top, 30)
                .disabled(viewModel.isLoading)
                
                HStack {
                    Text("Already have an account?")
                        .foregroundColor(Color(.systemGray))
                    Button("Sign In") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "5D3FD3"))
                }
                .font(.system(size: 15))
                .padding(.vertical, 34)
            }
        }
        .background(Color(.systemBackground))
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
} 