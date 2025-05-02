import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    func fetchHomeData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Will fetch home data when implemented
            try await Task.sleep(nanoseconds: 1_000_000_000) // Simulate network delay
        } catch {
            errorMessage = error.localizedDescription
        }
    }
} 