import Foundation
import FirebaseFirestore

// Protocol for objects that can be encoded to Firestore
protocol FirestoreEncodable: Encodable {
    func toFirestoreData() -> [String: Any]
}

// Protocol for objects that can be decoded from Firestore
protocol FirestoreDecodable: Decodable {
    static func fromFirestore(document: DocumentSnapshot) -> Self?
}

// Combined protocol for objects that can be both encoded to and decoded from Firestore
typealias FirestoreSerializable = FirestoreEncodable & FirestoreDecodable

// Extension to provide default implementation using Firestore.Encoder
extension FirestoreEncodable {
    func encodeForFirestore() -> [String: Any]? {
        do {
            let encoder = Firestore.Encoder()
            return try encoder.encode(self)
        } catch {
            print("Error encoding for Firestore: \(error)")
            return nil
        }
    }
}

// Extension to provide a default implementation for DocumentReference
extension DocumentReference {
    func setEncodableData<T: Encodable>(from value: T, merge: Bool = false) throws {
        let encoder = Firestore.Encoder()
        let encoded = try encoder.encode(value)
        if merge {
            try setData(encoded, merge: true)
        } else {
            try setData(encoded)
        }
    }
    
    func setEncodableDataAsync<T: Encodable>(from value: T, merge: Bool = false) async throws {
        let encoder = Firestore.Encoder()
        let encoded = try encoder.encode(value)
        if merge {
            try await setData(encoded, merge: true)
        } else {
            try await setData(encoded)
        }
    }
}

// Extension to provide a default implementation for QuerySnapshot
extension QuerySnapshot {
    func decoded<T: Decodable>() throws -> [T] {
        let decoder = Firestore.Decoder()
        
        return try documents.compactMap { document in
            do {
                let data = document.data()
                return try decoder.decode(T.self, from: data)
            } catch {
                print("Error decoding document \(document.documentID): \(error)")
                return nil
            }
        }
    }
    
    // Special handling for Identifiable types
    func decodedWithID<T>() throws -> [T] where T: Decodable, T: Identifiable, T.ID == String {
        let decoder = Firestore.Decoder()
        
        return try documents.compactMap { document in
            do {
                var data = document.data()
                data["id"] = document.documentID
                
                let decoded = try decoder.decode(T.self, from: data)
                return decoded
            } catch {
                print("Error decoding document \(document.documentID) with ID: \(error)")
                return nil
            }
        }
    }
}

// Extension to provide a default implementation for DocumentSnapshot
extension DocumentSnapshot {
    func decoded<T: Decodable>() throws -> T? {
        guard self.exists else { return nil }
        
        do {
            let data = self.data() ?? [:]
            let decoder = Firestore.Decoder()
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch {
            print("Error decoding document \(self.documentID): \(error)")
            throw error
        }
    }
    
    // Special handling for Identifiable types
    func decodedWithID<T>() throws -> T? where T: Decodable, T: Identifiable, T.ID == String {
        guard self.exists else { return nil }
        
        do {
            var data = self.data() ?? [:]
            data["id"] = self.documentID
            
            let decoder = Firestore.Decoder()
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch {
            print("Error decoding document \(self.documentID) with ID: \(error)")
            throw error
        }
    }
} 