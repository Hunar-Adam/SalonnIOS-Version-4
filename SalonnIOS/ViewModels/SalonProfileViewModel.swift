import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
class SalonProfileViewModel: ObservableObject {
    @Published var services: [Service] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var selectedService: Service?
    @Published var selectedDate: Date?
    @Published var availableTimeSlots: [Date] = []
    @Published var bookingSuccess = false
    
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    func fetchServices(for salonId: String) {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                let snapshot = try await db.collection("salons")
                    .document(salonId)
                    .collection("services")
                    .getDocuments()
                
                services = snapshot.documents.compactMap { Service.fromFirestore(document: $0) }
            } catch {
                self.error = error
                print("Error fetching services: \(error)")
            }
        }
    }
    
    func fetchAvailableTimeSlots(for service: Service, date: Date) {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                // Get salon working hours
                let salonDoc = try await db.collection("salons")
                    .document(service.salonId)
                    .getDocument()
                
                guard let salonData = salonDoc.data(),
                      let workingHours = salonData["workingHours"] as? [String: Any],
                      let startTime = workingHours["start"] as? String,
                      let endTime = workingHours["end"] as? String else {
                    throw NSError(domain: "SalonProfileViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid salon working hours"])
                }
                
                // Get existing appointments for the day
                let appointmentsSnapshot = try await db.collection("appointments")
                    .whereField("salonId", isEqualTo: service.salonId)
                    .whereField("date", isGreaterThanOrEqualTo: Calendar.current.startOfDay(for: date))
                    .whereField("date", isLessThan: Calendar.current.startOfDay(for: date.addingTimeInterval(86400)))
                    .getDocuments()
                
                let bookedSlots = appointmentsSnapshot.documents.compactMap { doc -> Date? in
                    guard let timestamp = doc.data()["date"] as? Timestamp else { return nil }
                    return timestamp.dateValue()
                }
                
                // Generate available time slots
                let calendar = Calendar.current
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                
                guard let startDate = dateFormatter.date(from: startTime),
                      let endDate = dateFormatter.date(from: endTime) else {
                    throw NSError(domain: "SalonProfileViewModel", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid time format"])
                }
                
                var slots: [Date] = []
                var currentDate = calendar.date(bySettingHour: calendar.component(.hour, from: startDate),
                                              minute: calendar.component(.minute, from: startDate),
                                              second: 0,
                                              of: date)!
                
                let endDateTime = calendar.date(bySettingHour: calendar.component(.hour, from: endDate),
                                              minute: calendar.component(.minute, from: endDate),
                                              second: 0,
                                              of: date)!
                
                while currentDate < endDateTime {
                    if !bookedSlots.contains(where: { calendar.isDate($0, equalTo: currentDate, toGranularity: .minute) }) {
                        slots.append(currentDate)
                    }
                    currentDate = calendar.date(byAdding: .minute, value: service.duration, to: currentDate)!
                }
                
                availableTimeSlots = slots
            } catch {
                self.error = error
                print("Error fetching time slots: \(error)")
            }
        }
    }
    
    func bookAppointment(service: Service, date: Date) {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                guard let userId = Auth.auth().currentUser?.uid else {
                    throw NSError(domain: "SalonProfileViewModel", code: 3, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
                }
                
                let appointment = Appointment(
                    id: UUID().uuidString,
                    salonId: service.salonId,
                    serviceId: service.id,
                    userId: userId,
                    date: date,
                    status: .pending,
                    price: service.price,
                    serviceName: service.name,
                    salonName: service.salonName,
                    customerName: Auth.auth().currentUser?.displayName ?? "Guest"
                )
                
                try await db.collection("appointments")
                    .document(appointment.id)
                    .setData(appointment.toFirestoreData())
                
                bookingSuccess = true
            } catch {
                self.error = error
                print("Error booking appointment: \(error)")
            }
        }
    }
} 