import SwiftUI

struct ListItem<Leading: View, Trailing: View>: View {
    let title: String
    let subtitle: String?
    let leading: Leading
    let trailing: Trailing
    let action: (() -> Void)?
    
    @Environment(\.colorScheme) private var colorScheme
    
    init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leading = leading()
        self.trailing = trailing()
        self.action = action
    }
    
    var body: some View {
        Group {
            if let action = action {
                Button(action: action) {
                    content
                }
            } else {
                content
            }
        }
    }
    
    private var content: some View {
        HStack(spacing: DesignSystem.Spacing.m) {
            leading
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(title)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(AppColors.textPrimary(for: colorScheme))
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(AppColors.textSecondary(for: colorScheme))
                }
            }
            
            Spacer()
            
            trailing
        }
        .padding(DesignSystem.Spacing.m)
        .background(AppColors.surface(for: colorScheme))
    }
}

extension ListItem {
    init(
        title: String,
        subtitle: String? = nil,
        leadingImage: String,
        trailingImage: String,
        action: (() -> Void)? = nil
    ) where Leading == AnyView, Trailing == AnyView {
        self.init(
            title: title,
            subtitle: subtitle,
            leading: {
                AnyView(
                    Image(systemName: leadingImage)
                        .foregroundStyle(.primary)
                )
            },
            trailing: {
                AnyView(
                    Image(systemName: trailingImage)
                        .foregroundStyle(.secondary)
                )
            },
            action: action
        )
    }
    
    init(
        title: String,
        subtitle: String? = nil,
        leadingImage: String,
        action: (() -> Void)? = nil
    ) where Leading == AnyView, Trailing == EmptyView {
        self.init(
            title: title,
            subtitle: subtitle,
            leading: {
                AnyView(
                    Image(systemName: leadingImage)
                        .foregroundStyle(.primary)
                )
            },
            trailing: { EmptyView() },
            action: action
        )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: DesignSystem.Spacing.xxs) {
        ListItem(
            title: "Haircut",
            subtitle: "30 minutes • $45",
            leadingImage: "scissors",
            trailingImage: "chevron.right"
        ) {}
        
        ListItem(
            title: "Manicure",
            subtitle: "45 minutes • $35",
            leadingImage: "hand.raised"
        ) {}
        
        ListItem(
            title: "Custom Item",
            subtitle: "With custom views",
            leading: {
                Circle()
                    .fill(AppColors.primary(for: .light))
                    .frame(width: 40, height: 40)
            },
            trailing: {
                Text("Custom")
                    .font(DesignSystem.Typography.caption1)
                    .foregroundColor(AppColors.textSecondary(for: .light))
            }
        ) {}
    }
    .padding()
} 