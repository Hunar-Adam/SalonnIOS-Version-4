import SwiftUI

struct FormField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var validationState: ValidationState = .default
    var errorMessage: String?
    var icon: String?
    
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text(title)
                .font(DesignSystem.Typography.subheadline)
                .foregroundColor(AppColors.textSecondary(for: colorScheme))
            
            HStack(spacing: DesignSystem.Spacing.s) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                }
                
                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .textFieldStyle(PlainTextFieldStyle())
                .font(DesignSystem.Typography.body)
                .foregroundColor(AppColors.textPrimary(for: colorScheme))
                .keyboardType(keyboardType)
                .focused($isFocused)
            }
            .padding(DesignSystem.Spacing.s)
            .background(backgroundColor)
            .cornerRadius(DesignSystem.CornerRadius.s)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.s)
                    .stroke(borderColor, lineWidth: 1)
            )
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(DesignSystem.Typography.caption1)
                    .foregroundColor(AppColors.error(for: colorScheme))
            }
        }
    }
    
    private var backgroundColor: Color {
        if isFocused {
            return AppColors.surfaceVariant(for: colorScheme)
        }
        return AppColors.surface(for: colorScheme)
    }
    
    private var borderColor: Color {
        switch validationState {
        case .default:
            return isFocused ? AppColors.primary(for: colorScheme) : AppColors.surfaceVariant(for: colorScheme)
        case .valid:
            return AppColors.success(for: colorScheme)
        case .invalid:
            return AppColors.error(for: colorScheme)
        }
    }
    
    private var iconColor: Color {
        switch validationState {
        case .default:
            return AppColors.textSecondary(for: colorScheme)
        case .valid:
            return AppColors.success(for: colorScheme)
        case .invalid:
            return AppColors.error(for: colorScheme)
        }
    }
}

enum ValidationState {
    case `default`
    case valid
    case invalid
}

// MARK: - Preview

#Preview {
    VStack(spacing: DesignSystem.Spacing.m) {
        FormField(
            title: "Email",
            placeholder: "Enter your email",
            text: .constant(""),
            keyboardType: .emailAddress,
            icon: "envelope"
        )
        
        FormField(
            title: "Password",
            placeholder: "Enter your password",
            text: .constant(""),
            isSecure: true,
            validationState: .valid,
            icon: "lock"
        )
        
        FormField(
            title: "Phone Number",
            placeholder: "Enter your phone number",
            text: .constant(""),
            keyboardType: .phonePad,
            validationState: .invalid,
            errorMessage: "Invalid phone number",
            icon: "phone"
        )
    }
    .padding()
} 