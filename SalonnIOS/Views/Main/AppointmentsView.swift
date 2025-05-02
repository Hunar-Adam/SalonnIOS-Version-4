import SwiftUI

struct AppointmentsView: View {
    @EnvironmentObject private var router: NavigationRouter
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel = AppointmentsViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.error {
                VStack(spacing: DesignSystem.Spacing.m) {
                    Text("Error loading appointments")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(AppColors.textPrimary(for: colorScheme))
                    
                    Text(error.localizedDescription)
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(AppColors.textSecondary(for: colorScheme))
                    
                    Button("Retry") {
                        viewModel.fetchAppointments()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            } else if viewModel.appointments.isEmpty {
                VStack(spacing: DesignSystem.Spacing.m) {
                    Text("No appointments")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(AppColors.textPrimary(for: colorScheme))
                    
                    Text("Book a service to get started")
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(AppColors.textSecondary(for: colorScheme))
                }
                .padding()
            } else {
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.m) {
                        ForEach(viewModel.appointments) { appointment in
                            CardView(action: {
                                router.navigate(to: .appointmentDetail(id: appointment.id))
                            }) {
                                ListItem(
                                    title: appointment.serviceName,
                                    subtitle: "\(appointment.formattedDate) • \(appointment.formattedTimeSlot)",
                                    leadingImage: "calendar",
                                    trailingImage: "chevron.right"
                                )
                            }
                        }
                    }
                    .padding(.vertical, DesignSystem.Spacing.m)
                    .padding(.horizontal, DesignSystem.Spacing.m)
                }
            }
        }
        .onAppear {
            viewModel.fetchAppointments()
        }
    }
}

#Preview {
    NavigationStack {
        AppointmentsView()
            .environmentObject(NavigationRouter())
    }
}
