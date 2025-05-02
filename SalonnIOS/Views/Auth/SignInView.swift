import SwiftUI

struct SignInView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State private var showForgotPassword = false
    @State private var showSignUp = false
    
    var body: some View {
        VStack(spacing: 0) {
            LogoView()
            
            Text("Sign In")
                .font(.system(size: 28, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 40)
            
            VStack(spacing: 20) {
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
                    Text("Password")
                        .font(.system(size: 17))
                        .foregroundColor(Color(.systemGray))
                    SecureField("Enter your password", text: $viewModel.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Button(action: {
                    showForgotPassword = true
                }) {
                    Text("Forgot Password?")
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "5D3FD3"))
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
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
                    await viewModel.signIn()
                }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Sign In")
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
            
            Spacer()
            
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(Color(.systemGray))
                Button("Sign Up") {
                    showSignUp = true
                }
                .foregroundColor(Color(hex: "5D3FD3"))
            }
            .font(.system(size: 15))
            .padding(.bottom, 34)
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView()
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
} 