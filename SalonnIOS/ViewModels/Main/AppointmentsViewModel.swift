import Foundation
import FirebaseAuth

@MainActor
class AppointmentsViewModel: ObservableObject {
    @Published var appointments: [Appointment] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let firestoreService = FirestoreService.shared
    
    func fetchAppointments() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                guard let userId = Auth.auth().currentUser?.uid else {
                    throw NSError(domain: "AppointmentsViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
                }
                
                appointments = try await firestoreService.getAppointmentsForCustomer(customerId: userId)
            } catch {
                self.error = error
                print("Error fetching appointments: \(error)")
            }
        }
    }
} 