import SwiftUI

struct ServiceDetailView: View {
    let serviceId: String
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.l) {
                // Service Image
                Image(systemName: "scissors")
                    .font(.system(size: 48))
                    .foregroundColor(AppColors.primary(for: colorScheme))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.xl)
                
                // Service Info
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.m) {
                    Text("Service \(serviceId)")
                        .font(DesignSystem.Typography.title2)
                        .foregroundColor(AppColors.textPrimary(for: colorScheme))
                    
                    Text("$\(30 + (Int(serviceId) ?? 0) * 5)")
                        .font(DesignSystem.Typography.title3)
                        .foregroundColor(AppColors.primary(for: colorScheme))
                    
                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(AppColors.textSecondary(for: colorScheme))
                        .padding(.top, DesignSystem.Spacing.s)
                }
                
                Spacer()
                
                // Book Button
                SalonnButton(
                    title: "Book Now",
                    style: .primary,
                    action: {
                        // Booking action
                    }
                )
                .padding(.top, DesignSystem.Spacing.xl)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ServiceDetailView(serviceId: "1")
    }
} 