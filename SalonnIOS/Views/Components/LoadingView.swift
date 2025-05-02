import SwiftUI

struct LoadingView: View {
    let message: String?
    let title: String
    
    @Environment(\.colorScheme) private var colorScheme
    
    init(message: String? = nil, title: String = "Welcome to Salonn") {
        self.message = message
        self.title = title
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Text(title)
                .font(DesignSystem.Typography.title1)
                .foregroundColor(AppColors.textPrimary(for: colorScheme))
                .multilineTextAlignment(.center)
            
            VStack(spacing: DesignSystem.Spacing.m) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(AppColors.primary(for: colorScheme))
                
                if let message = message {
                    Text(message)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(AppColors.textSecondary(for: colorScheme))
                        .multilineTextAlignment(.center)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background(for: colorScheme))
    }
}

#Preview {
    Group {
        LoadingView(message: "Loading appointments...")
            .preferredColorScheme(.light)
        
        LoadingView(message: "Loading appointments...")
            .preferredColorScheme(.dark)
    }
} 