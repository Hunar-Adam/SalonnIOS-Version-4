import Foundation

class ProfileViewModel: ObservableObject {
    @Published var isLoading = false
    
    func fetchProfileData() async {
        // This will be implemented later when we add profile data fetching
        // For now it's just a placeholder
        isLoading = true
        try? await Task.sleep(nanoseconds: 1_000_000_000) // Simulate network delay
        isLoading = false
    }
} 