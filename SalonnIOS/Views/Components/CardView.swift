import SwiftUI

struct CardView<Content: View>: View {
    let content: Content
    let style: CardStyle
    let action: (() -> Void)?
    
    @Environment(\.colorScheme) private var colorScheme
    
    init(
        style: CardStyle = .default,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        Group {
            if let action = action {
                Button(action: action) {
                    cardContent
                }
            } else {
                cardContent
            }
        }
    }
    
    private var cardContent: some View {
        content
            .padding(DesignSystem.Spacing.m)
            .background(style.backgroundColor(colorScheme))
            .cornerRadius(DesignSystem.CornerRadius.m)
            .applyShadow(style.shadow)
    }
}

enum CardStyle {
    case `default`
    case elevated
    case outlined
    
    var backgroundColor: (ColorScheme) -> Color {
        switch self {
        case .default, .elevated:
            return { colorScheme in AppColors.surface(for: colorScheme) }
        case .outlined:
            return { _ in .clear }
        }
    }
    
    var shadow: ShadowStyle {
        switch self {
        case .default:
            return DesignSystem.Shadow.small
        case .elevated:
            return DesignSystem.Shadow.medium
        case .outlined:
            return DesignSystem.Shadow.small
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: DesignSystem.Spacing.m) {
        CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.s) {
                Text("Default Card")
                    .font(DesignSystem.Typography.headline)
                Text("This is a default card with small shadow")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(AppColors.textSecondary(for: .light))
            }
        }
        
        CardView(style: .elevated) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.s) {
                Text("Elevated Card")
                    .font(DesignSystem.Typography.headline)
                Text("This is an elevated card with medium shadow")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(AppColors.textSecondary(for: .light))
            }
        }
        
        CardView(style: .outlined) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.s) {
                Text("Outlined Card")
                    .font(DesignSystem.Typography.headline)
                Text("This is an outlined card with border")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(AppColors.textSecondary(for: .light))
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.m)
                .stroke(AppColors.primary(for: .light), lineWidth: 1)
        )
    }
    .padding()
} 