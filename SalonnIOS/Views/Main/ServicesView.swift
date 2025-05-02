import SwiftUI

struct ServicesView: View {
    @EnvironmentObject private var router: NavigationRouter
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: DesignSystem.Spacing.m
            ) {
                ForEach(0..<6) { index in
                    CardView(action: {
                        router.navigate(to: .serviceDetail(id: "\(index)"))
                    }) {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.s) {
                            Image(systemName: "scissors")
                                .font(.system(size: 24))
                                .foregroundColor(AppColors.primary(for: colorScheme))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.bottom, DesignSystem.Spacing.xs)
                            
                            Text("Service \(index + 1)")
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(AppColors.textPrimary(for: colorScheme))
                            
                            Text("$\(30 + index * 5)")
                                .font(DesignSystem.Typography.subheadline)
                                .foregroundColor(AppColors.textSecondary(for: colorScheme))
                        }
                        .padding()
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    NavigationStack {
        ServicesView()
            .environmentObject(NavigationRouter())
    }
} 