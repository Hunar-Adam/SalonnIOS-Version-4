import SwiftUI

enum ButtonStyle {
    case primary
    case secondary
    case tertiary
    case destructive
    
    var backgroundColor: (ColorScheme) -> Color {
        switch self {
        case .primary:
            return { colorScheme in AppColors.primary(for: colorScheme) }
        case .secondary:
            return { colorScheme in AppColors.surface(for: colorScheme) }
        case .tertiary:
            return { _ in .clear }
        case .destructive:
            return { colorScheme in AppColors.error(for: colorScheme) }
        }
    }
    
    var foregroundColor: (ColorScheme) -> Color {
        switch self {
        case .primary:
            return { _ in .white }
        case .secondary:
            return { colorScheme in AppColors.primary(for: colorScheme) }
        case .tertiary:
            return { colorScheme in AppColors.primary(for: colorScheme) }
        case .destructive:
            return { _ in .white }
        }
    }
    
    var borderColor: (ColorScheme) -> Color? {
        switch self {
        case .primary:
            return { _ in nil }
        case .secondary:
            return { colorScheme in AppColors.primary(for: colorScheme) }
        case .tertiary:
            return { _ in nil }
        case .destructive:
            return { _ in nil }
        }
    }
}

struct SalonnButton: View {
    let title: String
    let style: ButtonStyle
    let action: () -> Void
    let isLoading: Bool
    let icon: String?
    
    @Environment(\.colorScheme) private var colorScheme
    
    init(
        title: String,
        style: ButtonStyle = .primary,
        isLoading: Bool = false,
        icon: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.isLoading = isLoading
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style.foregroundColor(colorScheme)))
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                    }
                    Text(title)
                        .font(DesignSystem.Typography.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(style.backgroundColor(colorScheme))
            .foregroundColor(style.foregroundColor(colorScheme))
            .cornerRadius(DesignSystem.CornerRadius.m)
            .overlay(
                Group {
                    if let borderColor = style.borderColor(colorScheme) {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.m)
                            .stroke(borderColor, lineWidth: 1)
                    }
                }
            )
        }
        .disabled(isLoading)
    }
}

#Preview {
    VStack(spacing: DesignSystem.Spacing.m) {
        SalonnButton(title: "Primary Button") {}
        
        SalonnButton(
            title: "Secondary Button",
            style: .secondary
        ) {}
        
        SalonnButton(
            title: "Tertiary Button",
            style: .tertiary
        ) {}
        
        SalonnButton(
            title: "Destructive Button",
            style: .destructive
        ) {}
        
        SalonnButton(
            title: "Loading Button",
            isLoading: true
        ) {}
        
        SalonnButton(
            title: "Button with Icon",
            icon: "plus"
        ) {}
    }
    .padding()
} 