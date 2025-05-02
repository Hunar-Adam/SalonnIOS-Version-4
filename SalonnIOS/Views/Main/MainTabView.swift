import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var router = NavigationRouter()
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        TabView(selection: $router.selectedTab) {
            NavigationStack(path: $router.path) {
                HomeView()
                    .standardNavigation(title: "Home")
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        switch destination {
                        case .serviceDetail(let id):
                            ServiceDetailView(serviceId: id)
                        case .appointmentDetail(let id):
                            AppointmentDetailView(appointmentId: id)
                        default:
                            EmptyView()
                        }
                    }
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(NavigationRouter.Tab.home)
            
            NavigationStack(path: $router.path) {
                AppointmentsView()
                    .standardNavigation(title: "Appointments")
            }
            .tabItem {
                Label("Appointments", systemImage: "calendar")
            }
            .tag(NavigationRouter.Tab.appointments)
            
            NavigationStack(path: $router.path) {
                ServicesView()
                    .standardNavigation(title: "Services")
            }
            .tabItem {
                Label("Services", systemImage: "scissors")
            }
            .tag(NavigationRouter.Tab.services)
            
            NavigationStack(path: $router.path) {
                ProfileView()
                    .standardNavigation(title: "Profile")
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
            .tag(NavigationRouter.Tab.profile)
        }
        .tint(AppColors.primary(for: colorScheme))
        .environmentObject(router)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppViewModel())
}
