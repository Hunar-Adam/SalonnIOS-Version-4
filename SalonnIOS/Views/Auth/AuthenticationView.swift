import SwiftUI

struct AuthenticationView: View {
    @State private var showSignIn = false
    @State private var showSignUp = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: DesignSystem.Spacing.xl) {
                Text("Welcome to Salonn")
                    .font(DesignSystem.Typography.largeTitle)
                    .foregroundColor(AppColors.textPrimary(for: colorScheme))
                    .multilineTextAlignment(.center)
                
                // Scissors Logo
                Image(systemName: "scissors")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .foregroundColor(AppColors.primary(for: colorScheme))
            }
            
            Spacer()
            
            VStack(spacing: DesignSystem.Spacing.m) {
                SalonnButton(
                    title: "Sign In",
                    style: .primary,
                    action: { showSignIn = true }
                )
                
                SalonnButton(
                    title: "Create Account",
                    style: .secondary,
                    action: { showSignUp = true }
                )
            }
            .padding(.horizontal, DesignSystem.Spacing.m)
            .padding(.bottom, DesignSystem.Spacing.xxxl)
        }
        .background(AppColors.background(for: colorScheme))
        .sheet(isPresented: $showSignIn) {
            SignInView()
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView()
        }
    }
}

#Preview {
    Group {
        AuthenticationView()
            .preferredColorScheme(.light)
        
        AuthenticationView()
            .preferredColorScheme(.dark)
    }
} 