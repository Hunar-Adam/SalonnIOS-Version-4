import Foundation
import FirebaseFirestore
import Combine

// Error type for Firestore operations
enum FirestoreError: Error {
    case documentNotFound
    case encodingError
    case decodingError
    case unknownError(String)
    
    var localizedDescription: String {
        switch self {
        case .documentNotFound:
            return "Document not found"
        case .encodingError:
            return "Error encoding document"
        case .decodingError:
            return "Error decoding document"
        case .unknownError(let message):
            return message
        }
    }
}

class FirestoreService {
    // Singleton instance
    static let shared = FirestoreService()
    
    // Firestore database reference
    private let db = Firestore.firestore()
    
    // Collection constants
    private struct Collections {
        static let users = "users"
        static let salons = "salons"
        static let services = "services"
        static let appointments = "appointments"
    }
    
    // MARK: - Generic CRUD Operations
    
    /// Creates a document in the specified collection
    func create<T: Encodable>(collection: String, data: T) async throws -> String {
        do {
            if let firestoreData = data as? [String: Any] {
                let docRef = try await db.collection(collection).addDocument(data: firestoreData)
                return docRef.documentID
            } else {
                // Convert Encodable to dictionary
                let encoder = Firestore.Encoder()
                let dataDict = try encoder.encode(data)
                
                let docRef = db.collection(collection).document()
                try await docRef.setData(dataDict)
                return docRef.documentID
            }
        } catch {
            print("Error creating document: \(error.localizedDescription)")
            throw FirestoreError.encodingError
        }
    }
    
    /// Retrieves a document by ID
    func get<T: Decodable>(collection: String, id: String) async throws -> T? {
        do {
            let docRef = db.collection(collection).document(id)
            let document = try await docRef.getDocument()
            
            if document.exists {
                // Convert document data to model
                var data = document.data() ?? [:]
                
                // For models that might expect an 'id' field
                data["id"] = document.documentID
                
                let decoder = Firestore.Decoder()
                return try decoder.decode(T.self, from: data)
            } else {
                throw FirestoreError.documentNotFound
            }
        } catch {
            print("Error getting document: \(error.localizedDescription)")
            throw FirestoreError.decodingError
        }
    }
    
    /// Updates a document by ID
    func update<T: Encodable>(collection: String, id: String, data: T) async throws {
        do {
            let docRef = db.collection(collection).document(id)
            if let firestoreData = data as? [String: Any] {
                try await docRef.updateData(firestoreData)
            } else {
                // Convert Encodable to dictionary
                let encoder = Firestore.Encoder()
                let dataDict = try encoder.encode(data)
                
                try await docRef.setData(dataDict, merge: true)
            }
        } catch {
            print("Error updating document: \(error.localizedDescription)")
            throw FirestoreError.encodingError
        }
    }
    
    /// Deletes a document by ID
    func delete(collection: String, id: String) async throws {
        do {
            try await db.collection(collection).document(id).delete()
        } catch {
            print("Error deleting document: \(error.localizedDescription)")
            throw FirestoreError.unknownError(error.localizedDescription)
        }
    }
    
    /// Queries documents in a collection based on field and value
    func query<T: Decodable, V>(collection: String, field: String, isEqualTo value: V) async throws -> [T] {
        do {
            let snapshot = try await db.collection(collection)
                .whereField(field, isEqualTo: value)
                .getDocuments()
            
            let decoder = Firestore.Decoder()
            return try snapshot.documents.compactMap { document in
                // Convert document data to model
                var data = document.data()
                
                // For models that might expect an 'id' field
                data["id"] = document.documentID
                
                return try decoder.decode(T.self, from: data)
            }
        } catch {
            print("Error querying documents: \(error.localizedDescription)")
            throw FirestoreError.decodingError
        }
    }
    
    // MARK: - User Operations
    
    /// Creates a new user
    func createUser(user: User) async throws -> String {
        let encoder = Firestore.Encoder()
        var userData = try encoder.encode(user)
        
        // Remove the ID field as it should be the document ID
        userData.removeValue(forKey: "id")
        
        let docRef = try await db.collection(Collections.users).addDocument(data: userData)
        return docRef.documentID
    }
    
    /// Gets a user by ID
    func getUser(id: String) async throws -> User? {
        let document = try await db.collection(Collections.users).document(id).getDocument()
        
        if document.exists {
            // Convert document data to model
            var data = document.data() ?? [:]
            data["id"] = document.documentID 
            
            let decoder = Firestore.Decoder()
            return try decoder.decode(User.self, from: data)
        }
        
        return nil
    }
    
    /// Updates a user
    func updateUser(user: User) async throws {
        let encoder = Firestore.Encoder()
        var userData = try encoder.encode(user)
        
        // Remove the ID field as it should be the document ID
        userData.removeValue(forKey: "id")
        
        try await db.collection(Collections.users).document(user.id).setData(userData, merge: true)
    }
    
    /// Deletes a user
    func deleteUser(id: String) async throws {
        try await delete(collection: Collections.users, id: id)
    }
    
    // MARK: - Salon Operations
    
    /// Creates a new salon
    func createSalon(salon: Salon) async throws -> String {
        let encoder = Firestore.Encoder()
        var salonData = try encoder.encode(salon)
        
        // Remove the ID field as it should be the document ID
        salonData.removeValue(forKey: "id")
        
        let docRef = try await db.collection(Collections.salons).addDocument(data: salonData)
        return docRef.documentID
    }
    
    /// Gets a salon by ID
    func getSalon(id: String) async throws -> Salon? {
        let document = try await db.collection(Collections.salons).document(id).getDocument()
        
        if document.exists {
            // Convert document data to model
            var data = document.data() ?? [:]
            data["id"] = document.documentID 
            
            let decoder = Firestore.Decoder()
            return try decoder.decode(Salon.self, from: data)
        }
        
        return nil
    }
    
    /// Updates a salon
    func updateSalon(salon: Salon) async throws {
        let encoder = Firestore.Encoder()
        var salonData = try encoder.encode(salon)
        
        // Remove the ID field as it should be the document ID
        salonData.removeValue(forKey: "id")
        
        try await db.collection(Collections.salons).document(salon.id).setData(salonData, merge: true)
    }
    
    /// Deletes a salon
    func deleteSalon(id: String) async throws {
        try await delete(collection: Collections.salons, id: id)
    }
    
    /// Gets salons owned by a user
    func getSalonsByOwner(ownerId: String) async throws -> [Salon] {
        return try await query(collection: Collections.salons, field: "ownerId", isEqualTo: ownerId)
    }
    
    // MARK: - Service Operations
    
    /// Creates a new service
    func createService(service: Service) async throws -> String {
        let encoder = Firestore.Encoder()
        var serviceData = try encoder.encode(service)
        
        // Remove the ID field as it should be the document ID
        serviceData.removeValue(forKey: "id")
        
        let docRef = try await db.collection(Collections.services).addDocument(data: serviceData)
        return docRef.documentID
    }
    
    /// Gets a service by ID
    func getService(id: String) async throws -> Service? {
        let document = try await db.collection(Collections.services).document(id).getDocument()
        
        if document.exists {
            // Convert document data to model
            var data = document.data() ?? [:]
            data["id"] = document.documentID 
            
            let decoder = Firestore.Decoder()
            return try decoder.decode(Service.self, from: data)
        }
        
        return nil
    }
    
    /// Updates a service
    func updateService(service: Service) async throws {
        let encoder = Firestore.Encoder()
        var serviceData = try encoder.encode(service)
        
        // Remove the ID field as it should be the document ID
        serviceData.removeValue(forKey: "id")
        
        try await db.collection(Collections.services).document(service.id).setData(serviceData, merge: true)
    }
    
    /// Deletes a service
    func deleteService(id: String) async throws {
        try await delete(collection: Collections.services, id: id)
    }
    
    /// Gets services for a salon
    func getServicesForSalon(salonId: String) async throws -> [Service] {
        return try await query(collection: Collections.services, field: "salonId", isEqualTo: salonId)
    }
    
    /// Gets services for a specific staff member
    func getServicesForStaff(staffId: String) async throws -> [Service] {
        let snapshot = try await db.collection(Collections.services)
            .whereField("staffIds", arrayContains: staffId)
            .getDocuments()
        
        let decoder = Firestore.Decoder()
        return try snapshot.documents.compactMap { document in
            var data = document.data()
            data["id"] = document.documentID
            
            return try decoder.decode(Service.self, from: data)
        }
    }
    
    // MARK: - Appointment Operations
    
    /// Creates a new appointment
    func createAppointment(appointment: Appointment) async throws -> String {
        let appointmentData = appointment.toFirestoreData()
        let docRef = try await db.collection(Collections.appointments).addDocument(data: appointmentData)
        return docRef.documentID
    }
    
    /// Gets an appointment by ID
    func getAppointment(id: String) async throws -> Appointment? {
        let document = try await db.collection(Collections.appointments).document(id).getDocument()
        return Appointment.fromFirestore(document: document)
    }
    
    /// Updates an appointment
    func updateAppointment(appointment: Appointment) async throws {
        try await db.collection(Collections.appointments)
            .document(appointment.id)
            .setData(appointment.toFirestoreData())
    }
    
    /// Deletes an appointment
    func deleteAppointment(id: String) async throws {
        try await delete(collection: Collections.appointments, id: id)
    }
    
    /// Gets appointments for a customer
    func getAppointmentsForCustomer(customerId: String) async throws -> [Appointment] {
        let snapshot = try await db.collection(Collections.appointments)
            .whereField("userId", isEqualTo: customerId)
            .getDocuments()
        
        return snapshot.documents.compactMap { Appointment.fromFirestore(document: $0) }
    }
    
    /// Gets appointments for a salon
    func getAppointmentsForSalon(salonId: String) async throws -> [Appointment] {
        let snapshot = try await db.collection(Collections.appointments)
            .whereField("salonId", isEqualTo: salonId)
            .getDocuments()
        
        return snapshot.documents.compactMap { Appointment.fromFirestore(document: $0) }
    }
    
    /// Gets appointments for a staff member
    func getAppointmentsForStaff(staffId: String) async throws -> [Appointment] {
        let snapshot = try await db.collection(Collections.appointments)
            .whereField("staffId", isEqualTo: staffId)
            .getDocuments()
        
        return snapshot.documents.compactMap { Appointment.fromFirestore(document: $0) }
    }
    
    /// Gets appointments for a salon on a specific date
    func getAppointmentsForDate(salonId: String, date: Date) async throws -> [Appointment] {
        // Create date range for the specified date (midnight to midnight)
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let snapshot = try await db.collection(Collections.appointments)
            .whereField("salonId", isEqualTo: salonId)
            .whereField("startTime", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("startTime", isLessThan: Timestamp(date: endOfDay))
            .getDocuments()
        
        return snapshot.documents.compactMap { Appointment.fromFirestore(document: $0) }
    }
} 
