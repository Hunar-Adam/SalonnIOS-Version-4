import Foundation
import FirebaseFirestore
import CoreLocation

struct SalonAddress: Codable {
    let street: String
    let city: String
    let state: String
    let zipCode: String
    
    var formattedAddress: String {
        return "\(street), \(city), \(state)"
    }
}

struct Salon: Identifiable, Codable, FirestoreSerializable {
    let id: String
    var name: String
    var description: String
    var address: Address
    var phoneNumber: String
    var email: String
    var websiteURL: String?
    var imageURLs: [String]
    var services: [String] // Reference to service IDs
    var staff: [String] // Reference to staff user IDs
    var ownerId: String
    var workingHours: [WorkingDay]
    var averageRating: Double
    var reviewCount: Int
    var verified: Bool
    var createdAt: Date
    var updatedAt: Date
    
    struct Address: Codable {
        var street: String
        var city: String
        var state: String
        var zipCode: String
        var country: String
        var coordinates: GeoPoint?
        
        var formattedAddress: String {
            return "\(street), \(city), \(state) \(zipCode)"
        }
    }
    
    struct WorkingDay: Codable {
        var day: Int // 0 = Sunday, 1 = Monday, etc.
        var isOpen: Bool
        var openTime: Date?
        var closeTime: Date?
        
        var dayName: String {
            let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
            return days[day]
        }
    }
    
    // Convert Firestore document to Salon - Legacy method
    static func fromFirestore(document: DocumentSnapshot) -> Salon? {
        do {
            return try document.decodedWithID()
        } catch {
            print("Error decoding salon: \(error)")
            return parseSalonManually(document: document)
        }
    }
    
    // Manual parsing fallback - Used only if decoder fails
    private static func parseSalonManually(document: DocumentSnapshot) -> Salon? {
        guard let data = document.data() else { return nil }
        
        let id = document.documentID
        let name = data["name"] as? String ?? ""
        let description = data["description"] as? String ?? ""
        let phoneNumber = data["phoneNumber"] as? String ?? ""
        let email = data["email"] as? String ?? ""
        let websiteURL = data["websiteURL"] as? String
        let imageURLs = data["imageURLs"] as? [String] ?? []
        let services = data["services"] as? [String] ?? []
        let staff = data["staff"] as? [String] ?? []
        let ownerId = data["ownerId"] as? String ?? ""
        let averageRating = data["averageRating"] as? Double ?? 0.0
        let reviewCount = data["reviewCount"] as? Int ?? 0
        let verified = data["verified"] as? Bool ?? false
        
        // Parse address
        let addressData = data["address"] as? [String: Any] ?? [:]
        let street = addressData["street"] as? String ?? ""
        let city = addressData["city"] as? String ?? ""
        let state = addressData["state"] as? String ?? ""
        let zipCode = addressData["zipCode"] as? String ?? ""
        let country = addressData["country"] as? String ?? ""
        let coordinates = addressData["coordinates"] as? GeoPoint
        
        let address = Address(
            street: street,
            city: city,
            state: state,
            zipCode: zipCode,
            country: country,
            coordinates: coordinates
        )
        
        // Parse working hours
        let workingHoursData = data["workingHours"] as? [[String: Any]] ?? []
        let workingHours: [WorkingDay] = workingHoursData.compactMap { dayData in
            guard let day = dayData["day"] as? Int else { return nil }
            
            let isOpen = dayData["isOpen"] as? Bool ?? false
            var openTime: Date? = nil
            var closeTime: Date? = nil
            
            if let openTimestamp = dayData["openTime"] as? Timestamp {
                openTime = openTimestamp.dateValue()
            }
            
            if let closeTimestamp = dayData["closeTime"] as? Timestamp {
                closeTime = closeTimestamp.dateValue()
            }
            
            return WorkingDay(day: day, isOpen: isOpen, openTime: openTime, closeTime: closeTime)
        }
        
        // Parse dates
        let createdAtTimestamp = data["createdAt"] as? Timestamp ?? Timestamp(date: Date())
        let updatedAtTimestamp = data["updatedAt"] as? Timestamp ?? Timestamp(date: Date())
        
        return Salon(
            id: id,
            name: name,
            description: description,
            address: address,
            phoneNumber: phoneNumber,
            email: email,
            websiteURL: websiteURL,
            imageURLs: imageURLs,
            services: services,
            staff: staff,
            ownerId: ownerId,
            workingHours: workingHours,
            averageRating: averageRating,
            reviewCount: reviewCount,
            verified: verified,
            createdAt: createdAtTimestamp.dateValue(),
            updatedAt: updatedAtTimestamp.dateValue()
        )
    }
    
    // Convert Salon to Firestore data
    func toFirestoreData() -> [String: Any] {
        // We'll use Firestore.Encoder to encode when possible
        if let encoded = encodeForFirestore() {
            // Remove the ID field as it should not be stored in the Firestore document
            var data = encoded
            data.removeValue(forKey: "id")
            return data
        }
        
        // Fallback to manual encoding if the encoder fails
        return encodeManually()
    }
    
    // Manual encoding fallback - Used only if encoder fails
    private func encodeManually() -> [String: Any] {
        // Convert working hours to dictionary array
        let workingHoursData: [[String: Any]] = workingHours.map { day in
            var dayData: [String: Any] = [
                "day": day.day,
                "isOpen": day.isOpen
            ]
            
            if let openTime = day.openTime {
                dayData["openTime"] = Timestamp(date: openTime)
            }
            
            if let closeTime = day.closeTime {
                dayData["closeTime"] = Timestamp(date: closeTime)
            }
            
            return dayData
        }
        
        // Convert address to dictionary
        var addressData: [String: Any] = [
            "street": address.street,
            "city": address.city,
            "state": address.state,
            "zipCode": address.zipCode,
            "country": address.country
        ]
        
        if let coordinates = address.coordinates {
            addressData["coordinates"] = coordinates
        }
        
        return [
            "name": name,
            "description": description,
            "address": addressData,
            "phoneNumber": phoneNumber,
            "email": email,
            "websiteURL": websiteURL as Any,
            "imageURLs": imageURLs,
            "services": services,
            "staff": staff,
            "ownerId": ownerId,
            "workingHours": workingHoursData,
            "averageRating": averageRating,
            "reviewCount": reviewCount,
            "verified": verified,
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt)
        ]
    }
} 