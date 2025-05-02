import Foundation
import FirebaseFirestore

struct Service: Identifiable, Codable {
    let id: String
    let salonId: String
    let name: String
    let description: String
    let price: Double
    let duration: Int
    let category: String
    let salonName: String
    let imageURL: String
    let preparationTime: Int
    let cleanupTime: Int
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    enum Category: String, Codable {
        case haircut = "Haircut"
        case coloring = "Coloring"
        case styling = "Styling"
        case treatment = "Treatment"
        case makeup = "Makeup"
        case nails = "Nails"
        case spa = "Spa"
        case other = "Other"
    }
    
    // Convert Firestore document to Service
    static func fromFirestore(document: QueryDocumentSnapshot) -> Service? {
        let data = document.data()
        
        // Convert Timestamps to Dates
        let createdAtTimestamp = data["createdAt"] as? Timestamp ?? Timestamp(date: Date())
        let updatedAtTimestamp = data["updatedAt"] as? Timestamp ?? Timestamp(date: Date())
        
        return Service(
            id: document.documentID,
            salonId: data["salonId"] as? String ?? "",
            name: data["name"] as? String ?? "",
            description: data["description"] as? String ?? "",
            price: data["price"] as? Double ?? 0.0,
            duration: data["duration"] as? Int ?? 30,
            category: data["category"] as? String ?? "",
            salonName: data["salonName"] as? String ?? "",
            imageURL: data["imageURL"] as? String ?? "",
            preparationTime: data["preparationTime"] as? Int ?? 0,
            cleanupTime: data["cleanupTime"] as? Int ?? 0,
            isActive: data["isActive"] as? Bool ?? true,
            createdAt: createdAtTimestamp.dateValue(),
            updatedAt: updatedAtTimestamp.dateValue()
        )
    }
    
    // Convert Service to Firestore data
    func toFirestore() -> [String: Any] {
        return [
            "salonId": salonId,
            "name": name,
            "description": description,
            "price": price,
            "category": category,
            "salonName": salonName,
            "preparationTime": preparationTime as Any,
            "cleanupTime": cleanupTime as Any,
            "isActive": isActive,
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt)
        ]
    }
    
    // Helper method for formatting price
    func formattedPrice(currencyCode: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: NSNumber(value: price)) ?? "$\(price)"
    }
    
    // Helper method for formatting duration
    var formattedDuration: String {
        if duration < 60 {
            return "\(duration) min"
        } else {
            let hours = duration / 60
            let minutes = duration % 60
            if minutes == 0 {
                return "\(hours) hr"
            } else {
                return "\(hours) hr \(minutes) min"
            }
        }
    }
    
    // Total duration including preparation and cleanup
    var totalDuration: Int {
        return duration + preparationTime + cleanupTime
    }
} 