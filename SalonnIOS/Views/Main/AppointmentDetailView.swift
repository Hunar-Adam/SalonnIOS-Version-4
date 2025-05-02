import SwiftUI

struct AppointmentDetailView: View {
    let appointmentId: String
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var router: NavigationRouter
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.l) {
                // Appointment Info
                CardView {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.m) {
                        HStack {
                            Image(systemName: "calendar")
                                .font(.system(size: 24))
                                .foregroundColor(AppColors.primary(for: colorScheme))
                            
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                                Text("March \(Int(appointmentId) ?? 1), 2024")
                                    .font(DesignSystem.Typography.headline)
                                    .foregroundColor(AppColors.textPrimary(for: colorScheme))
                                
                                Text("2:00 PM")
                                    .font(DesignSystem.Typography.subheadline)
                                    .foregroundColor(AppColors.textSecondary(for: colorScheme))
                            }
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.s) {
                            Text("Service")
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(AppColors.textSecondary(for: colorScheme))
                            
                            Text("Haircut")
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(AppColors.textPrimary(for: colorScheme))
                        }
                        
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.s) {
                            Text("Price")
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(AppColors.textSecondary(for: colorScheme))
                            
                            Text("$35")
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(AppColors.textPrimary(for: colorScheme))
                        }
                    }
                    .padding()
                }
                
                // Actions
                VStack(spacing: DesignSystem.Spacing.m) {
                    SalonnButton(
                        title: "Reschedule",
                        style: .secondary,
                        action: {
                            // Reschedule action
                        }
                    )
                    
                    SalonnButton(
                        title: "Cancel Appointment",
                        style: .destructive,
                        action: {
                            // Cancel action
                        }
                    )
                }
                .padding(.top, DesignSystem.Spacing.xl)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AppointmentDetailView(appointmentId: "1")
            .environmentObject(NavigationRouter())
    }
} 