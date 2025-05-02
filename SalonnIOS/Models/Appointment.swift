import Foundation
import FirebaseFirestore

struct Appointment: Identifiable, Codable, FirestoreSerializable {
    let id: String
    let salonId: String
    let serviceId: String
    let userId: String
    let date: Date
    let status: AppointmentStatus
    let price: Double
    let serviceName: String
    let salonName: String
    let customerName: String
    let startTime: Date
    let endTime: Date
    let createdAt: Date
    let updatedAt: Date
    
    init(
        id: String,
        salonId: String,
        serviceId: String,
        userId: String,
        date: Date,
        status: AppointmentStatus,
        price: Double,
        serviceName: String,
        salonName: String,
        customerName: String,
        startTime: Date,
        endTime: Date,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.salonId = salonId
        self.serviceId = serviceId
        self.userId = userId
        self.date = date
        self.status = status
        self.price = price
        self.serviceName = serviceName
        self.salonName = salonName
        self.customerName = customerName
        self.startTime = startTime
        self.endTime = endTime
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // Convenience initializer for creating new appointments
    init(
        id: String,
        salonId: String,
        serviceId: String,
        userId: String,
        date: Date,
        status: AppointmentStatus,
        price: Double,
        serviceName: String,
        salonName: String,
        customerName: String
    ) {
        self.id = id
        self.salonId = salonId
        self.serviceId = serviceId
        self.userId = userId
        self.date = date
        self.status = status
        self.price = price
        self.serviceName = serviceName
        self.salonName = salonName
        self.customerName = customerName
        self.startTime = date
        self.endTime = date.addingTimeInterval(3600) // Default 1 hour duration
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    enum AppointmentStatus: String, Codable, CaseIterable {
        case pending = "pending"
        case confirmed = "confirmed"
        case inProgress = "inProgress"
        case completed = "completed"
        case cancelled = "cancelled"
        case noShow = "noShow"
        
        var displayName: String {
            switch self {
            case .pending: return "Pending"
            case .confirmed: return "Confirmed"
            case .inProgress: return "In Progress"
            case .completed: return "Completed"
            case .cancelled: return "Cancelled"
            case .noShow: return "No Show"
            }
        }
        
        var color: String {
            switch self {
            case .pending: return "yellow"
            case .confirmed: return "blue"
            case .inProgress: return "purple"
            case .completed: return "green"
            case .cancelled: return "red"
            case .noShow: return "gray"
            }
        }
    }
    
    enum PaymentStatus: String, Codable, CaseIterable {
        case unpaid = "unpaid"
        case paid = "paid"
        case partiallyPaid = "partiallyPaid"
        case refunded = "refunded"
        case cancelled = "cancelled"
        
        var displayName: String {
            switch self {
            case .unpaid: return "Unpaid"
            case .paid: return "Paid"
            case .partiallyPaid: return "Partially Paid"
            case .refunded: return "Refunded"
            case .cancelled: return "Cancelled"
            }
        }
    }
    
    // MARK: - FirestoreSerializable
    func toFirestoreData() -> [String: Any] {
        return [
            "id": id,
            "salonId": salonId,
            "serviceId": serviceId,
            "userId": userId,
            "date": Timestamp(date: date),
            "status": status.rawValue,
            "price": price,
            "serviceName": serviceName,
            "salonName": salonName,
            "customerName": customerName,
            "startTime": Timestamp(date: startTime),
            "endTime": Timestamp(date: endTime),
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt)
        ]
    }
    
    static func fromFirestore(document: DocumentSnapshot) -> Appointment? {
        guard let data = document.data() else { return nil }
        
        guard let salonId = data["salonId"] as? String,
              let serviceId = data["serviceId"] as? String,
              let userId = data["userId"] as? String,
              let dateTimestamp = data["date"] as? Timestamp,
              let statusRaw = data["status"] as? String,
              let status = AppointmentStatus(rawValue: statusRaw),
              let price = data["price"] as? Double,
              let serviceName = data["serviceName"] as? String,
              let salonName = data["salonName"] as? String,
              let customerName = data["customerName"] as? String else {
            return nil
        }
        
        // Handle timestamps with defaults
        let startTimeTimestamp = (data["startTime"] as? Timestamp) ?? dateTimestamp
        let endTimeTimestamp = (data["endTime"] as? Timestamp) ?? Timestamp(date: dateTimestamp.dateValue().addingTimeInterval(3600))
        let createdAtTimestamp = (data["createdAt"] as? Timestamp) ?? Timestamp(date: Date())
        let updatedAtTimestamp = (data["updatedAt"] as? Timestamp) ?? Timestamp(date: Date())
        
        return Appointment(
            id: document.documentID,
            salonId: salonId,
            serviceId: serviceId,
            userId: userId,
            date: dateTimestamp.dateValue(),
            status: status,
            price: price,
            serviceName: serviceName,
            salonName: salonName,
            customerName: customerName,
            startTime: startTimeTimestamp.dateValue(),
            endTime: endTimeTimestamp.dateValue(),
            createdAt: createdAtTimestamp.dateValue(),
            updatedAt: updatedAtTimestamp.dateValue()
        )
    }
    
    // Helper for duration in minutes
    var durationMinutes: Int {
        return Int(endTime.timeIntervalSince(startTime) / 60)
    }
    
    // Formatted date string
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: startTime)
    }
    
    // Formatted time string
    var formattedTimeSlot: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
    
    // Formatted price
    func formattedPrice(currencyCode: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: NSNumber(value: price)) ?? "$\(price)"
    }
} 