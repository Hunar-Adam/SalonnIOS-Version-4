import SwiftUI

/// Represents all possible navigation destinations in the app
enum NavigationDestination: Hashable {
    case home
    case profile
    case appointments
    case services
    case settings
    case serviceDetail(id: String)
    case appointmentDetail(id: String)
}

/// Handles app-wide navigation state and routing
class NavigationRouter: ObservableObject {
    @Published var path = NavigationPath()
    @Published var selectedTab: Tab = .home
    
    enum Tab {
        case home
        case appointments
        case services
        case profile
    }
    
    func navigate(to destination: NavigationDestination) {
        path.append(destination)
    }
    
    func navigateBack() {
        path.removeLast()
    }
    
    func navigateToRoot() {
        path.removeLast(path.count)
    }
    
    func switchTab(to tab: Tab) {
        selectedTab = tab
    }
}

/// View modifier to add standard navigation styling
struct NavigationBarModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    
    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppColors.surface(for: colorScheme), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

extension View {
    func standardNavigation(title: String) -> some View {
        modifier(NavigationBarModifier(title: title))
    }
} 