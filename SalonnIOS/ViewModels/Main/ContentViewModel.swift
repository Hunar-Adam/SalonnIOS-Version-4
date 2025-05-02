import Foundation

@MainActor
class ContentViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    init() {
        // Initialize any required services or data
    }
} 