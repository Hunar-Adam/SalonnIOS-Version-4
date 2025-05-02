import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    let icon: String
    let action: (() -> Void)?
    
    @Environment(\.colorScheme) private var colorScheme
    
    init(
        title: String,
        message: String,
        icon: String,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.m) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(AppColors.primary(for: colorScheme))
            
            Text(title)
                .font(DesignSystem.Typography.title3)
                .foregroundColor(AppColors.textPrimary(for: colorScheme))
            
            Text(message)
                .font(DesignSystem.Typography.body)
                .foregroundColor(AppColors.textSecondary(for: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.m)
            
            if let action = action {
                SalonnButton(title: "Try Again", action: action)
                    .padding(.top, DesignSystem.Spacing.s)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background(for: colorScheme))
    }
}

#Preview {
    EmptyStateView(
        title: "No Appointments",
        message: "You don't have any appointments scheduled yet. Book your first appointment now!",
        icon: "calendar",
        action: {}
    )
} 