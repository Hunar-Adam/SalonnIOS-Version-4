import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var router: NavigationRouter
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.l) {
                // Upcoming appointments section
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.m) {
                    Text("Upcoming Appointments")
                        .font(DesignSystem.Typography.title3)
                        .foregroundColor(AppColors.textPrimary(for: colorScheme))
                    
                    CardView {
                        // Placeholder for upcoming appointments
                        Text("No upcoming appointments")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(AppColors.textSecondary(for: colorScheme))
                            .padding()
                    }
                }
                
                // Featured services section
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.m) {
                    Text("Featured Services")
                        .font(DesignSystem.Typography.title3)
                        .foregroundColor(AppColors.textPrimary(for: colorScheme))
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DesignSystem.Spacing.m) {
                            ForEach(0..<3) { index in
                                CardView(action: {
                                    router.navigate(to: .serviceDetail(id: "\(index)"))
                                }) {
                                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.s) {
                                        Text("Service \(index + 1)")
                                            .font(DesignSystem.Typography.headline)
                                            .foregroundColor(AppColors.textPrimary(for: colorScheme))
                                        
                                        Text("Description of service \(index + 1)")
                                            .font(DesignSystem.Typography.subheadline)
                                            .foregroundColor(AppColors.textSecondary(for: colorScheme))
                                    }
                                    .frame(width: 200)
                                    .padding()
                                }
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.m)
                    }
                }
            }
            .padding(.vertical, DesignSystem.Spacing.m)
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(NavigationRouter())
    }
}
