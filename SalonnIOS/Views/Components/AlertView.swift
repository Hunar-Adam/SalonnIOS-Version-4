import SwiftUI

struct AlertView: View {
    let title: String
    let message: String
    let primaryButton: AlertButton
    let secondaryButton: AlertButton?
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.m) {
            Text(title)
                .font(DesignSystem.Typography.title3)
                .foregroundColor(AppColors.textPrimary(for: colorScheme))
                .multilineTextAlignment(.center)
            
            Text(message)
                .font(DesignSystem.Typography.body)
                .foregroundColor(AppColors.textSecondary(for: colorScheme))
                .multilineTextAlignment(.center)
            
            VStack(spacing: DesignSystem.Spacing.s) {
                SalonnButton(
                    title: primaryButton.title,
                    style: primaryButton.style,
                    action: {
                        primaryButton.action()
                        dismiss()
                    }
                )
                
                if let secondaryButton = secondaryButton {
                    SalonnButton(
                        title: secondaryButton.title,
                        style: secondaryButton.style,
                        action: {
                            secondaryButton.action()
                            dismiss()
                        }
                    )
                }
            }
            .padding(.top, DesignSystem.Spacing.s)
        }
        .padding(DesignSystem.Spacing.m)
        .background(AppColors.surface(for: colorScheme))
        .cornerRadius(DesignSystem.CornerRadius.m)
        .padding(DesignSystem.Spacing.m)
    }
}

struct AlertButton {
    let title: String
    let style: ButtonStyle
    let action: () -> Void
    
    static func primary(title: String, action: @escaping () -> Void) -> AlertButton {
        AlertButton(title: title, style: .primary, action: action)
    }
    
    static func secondary(title: String, action: @escaping () -> Void) -> AlertButton {
        AlertButton(title: title, style: .secondary, action: action)
    }
    
    static func destructive(title: String, action: @escaping () -> Void) -> AlertButton {
        AlertButton(title: title, style: .destructive, action: action)
    }
}

struct ModalView<Content: View>: View {
    let title: String
    let content: Content
    let dismissAction: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    init(
        title: String,
        dismissAction: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.content = content()
        self.dismissAction = dismissAction
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.m) {
            HStack {
                Text(title)
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(AppColors.textPrimary(for: colorScheme))
                
                Spacer()
                
                Button(action: dismissAction) {
                    Image(systemName: "xmark")
                        .foregroundColor(AppColors.textSecondary(for: colorScheme))
                }
            }
            
            content
        }
        .padding(DesignSystem.Spacing.m)
        .background(AppColors.surface(for: colorScheme))
        .cornerRadius(DesignSystem.CornerRadius.m)
        .padding(DesignSystem.Spacing.m)
    }
}

// MARK: - Preview

#Preview {
    Group {
        AlertView(
            title: "Delete Appointment",
            message: "Are you sure you want to delete this appointment? This action cannot be undone.",
            primaryButton: .destructive(title: "Delete") {},
            secondaryButton: .secondary(title: "Cancel") {}
        )
        
        ModalView(title: "Edit Profile", dismissAction: {}) {
            VStack(spacing: DesignSystem.Spacing.m) {
                FormField(
                    title: "Name",
                    placeholder: "Enter your name",
                    text: .constant(""),
                    icon: "person"
                )
                
                FormField(
                    title: "Email",
                    placeholder: "Enter your email",
                    text: .constant(""),
                    keyboardType: .emailAddress,
                    icon: "envelope"
                )
                
                SalonnButton(title: "Save Changes") {}
            }
        }
    }
} 