import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable, FirestoreSerializable {
    let id: String
    let email: String
    var displayName: String?
    var phoneNumber: String?
    var profileImageURL: String?
    var role: UserRole
    var createdAt: Date
    var updatedAt: Date
    
    enum UserRole: String, Codable {
        case customer
        case salonStaff
        case salonOwner
        case admin
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case displayName
        case phoneNumber
        case profileImageURL
        case role
        case createdAt
        case updatedAt
    }
    
    init(id: String, 
         email: String, 
         displayName: String? = nil, 
         phoneNumber: String? = nil,
         profileImageURL: String? = nil,
         role: UserRole = .customer,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.phoneNumber = phoneNumber
        self.profileImageURL = profileImageURL
        self.role = role
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // Convert Firestore document to User - Legacy method
    static func fromFirestore(document: DocumentSnapshot) -> User? {
        guard let data = document.data() else { return nil }
        
        let id = document.documentID
        let email = data["email"] as? String ?? ""
        let displayName = data["displayName"] as? String
        let phoneNumber = data["phoneNumber"] as? String
        let profileImageURL = data["profileImageURL"] as? String
        let roleString = data["role"] as? String ?? "customer"
        let role = UserRole(rawValue: roleString) ?? .customer
        
        let createdAtTimestamp = data["createdAt"] as? Timestamp ?? Timestamp(date: Date())
        let updatedAtTimestamp = data["updatedAt"] as? Timestamp ?? Timestamp(date: Date())
        
        return User(
            id: id,
            email: email,
            displayName: displayName,
            phoneNumber: phoneNumber,
            profileImageURL: profileImageURL,
            role: role,
            createdAt: createdAtTimestamp.dateValue(),
            updatedAt: updatedAtTimestamp.dateValue()
        )
    }
    
    // Convert User to Firestore data - Legacy method
    func toFirestoreData() -> [String: Any] {
        // We'll use Firestore.Encoder to encode when possible
        if let encoded = encodeForFirestore() {
            // Remove the ID field as it should not be stored in the Firestore document
            var data = encoded
            data.removeValue(forKey: "id")
            return data
        }
        
        // Fallback to manual encoding if the encoder fails
        return [
            "email": email,
            "displayName": displayName as Any,
            "phoneNumber": phoneNumber as Any,
            "profileImageURL": profileImageURL as Any,
            "role": role.rawValue,
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt)
        ]
    }
    
    // Alternative method using Firestore.Decoder
    static func fromFirestoreWithDecoder(document: DocumentSnapshot) -> User? {
        do {
            guard let data = document.data() else { return nil }
            
            // The document ID must be preserved since it's not stored in the data
            let id = document.documentID
            
            // Create a mutable copy of the data with the ID
            var userData = data
            userData["id"] = id
            
            let decoder = Firestore.Decoder()
            let user = try decoder.decode(User.self, from: userData)
            return user
        } catch {
            print("Error decoding user: \(error)")
            return nil
        }
    }
    
    // Alternative method using Firestore.Encoder
    func encodeForFirestore() -> [String: Any]? {
        do {
            let encoder = Firestore.Encoder()
            let data = try encoder.encode(self)
            return data
        } catch {
            print("Error encoding user: \(error)")
            return nil
        }
    }
} 