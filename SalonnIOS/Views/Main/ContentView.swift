import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    
    var body: some View {
        Group {
            if appViewModel.isLoading {
                LoadingView(
                    message: "Setting up your experience...",
                    title: "Welcome to Salonn"
                )
            } else if appViewModel.isAuthenticated {
                MainTabView()
            } else {
                AuthenticationView()
            }
        }
        .onAppear {
            print("📱 ContentView appeared")
        }
        .alert("Error", isPresented: .constant(appViewModel.errorMessage != nil)) {
            Button("OK") {
                appViewModel.errorMessage = nil
            }
        } message: {
            if let error = appViewModel.errorMessage {
                Text(error)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppViewModel())
} 