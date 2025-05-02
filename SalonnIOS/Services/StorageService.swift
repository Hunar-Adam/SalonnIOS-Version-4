import Foundation
import FirebaseStorage
import UIKit

// Error type for Storage operations
enum StorageError: Error {
    case uploadFailed(String)
    case downloadFailed(String)
    case invalidImage
    case unknownError(String)
    
    var localizedDescription: String {
        switch self {
        case .uploadFailed(let message):
            return "Upload failed: \(message)"
        case .downloadFailed(let message):
            return "Download failed: \(message)"
        case .invalidImage:
            return "Invalid image data"
        case .unknownError(let message):
            return message
        }
    }
}

class StorageService {
    // Singleton instance
    static let shared = StorageService()
    
    // Storage reference
    private let storage = Storage.storage().reference()
    
    // Storage paths
    private struct StoragePaths {
        static let profileImages = "profile_images"
        static let salonImages = "salon_images"
        static let serviceImages = "service_images"
    }
    
    // MARK: - Upload Methods
    
    /// Uploads an image to Firebase Storage
    /// - Parameters:
    ///   - image: The UIImage to upload
    ///   - path: The storage path (folder)
    ///   - fileName: Optional filename, if nil a UUID will be generated
    ///   - metadata: Optional metadata
    /// - Returns: Download URL for the uploaded image
    func uploadImage(_ image: UIImage, 
                     toPath path: String, 
                     fileName: String? = nil,
                     metadata: StorageMetadata? = nil) async throws -> URL {
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw StorageError.invalidImage
        }
        
        let imageName = fileName ?? UUID().uuidString
        let imagePath = "\(path)/\(imageName).jpg"
        let imageRef = storage.child(imagePath)
        
        let uploadMetadata = metadata ?? StorageMetadata()
        if uploadMetadata.contentType == nil {
            uploadMetadata.contentType = "image/jpeg"
        }
        
        do {
            _ = try await imageRef.putDataAsync(imageData, metadata: uploadMetadata)
            let downloadURL = try await imageRef.downloadURL()
            return downloadURL
        } catch {
            throw StorageError.uploadFailed(error.localizedDescription)
        }
    }
    
    /// Uploads a profile image
    func uploadProfileImage(_ image: UIImage, userId: String) async throws -> URL {
        return try await uploadImage(
            image,
            toPath: StoragePaths.profileImages,
            fileName: userId
        )
    }
    
    /// Uploads a salon image
    func uploadSalonImage(_ image: UIImage, salonId: String, isMain: Bool = false) async throws -> URL {
        let fileName = isMain ? "\(salonId)_main" : "\(salonId)_\(UUID().uuidString)"
        return try await uploadImage(
            image,
            toPath: StoragePaths.salonImages,
            fileName: fileName
        )
    }
    
    /// Uploads a service image
    func uploadServiceImage(_ image: UIImage, serviceId: String) async throws -> URL {
        return try await uploadImage(
            image,
            toPath: StoragePaths.serviceImages,
            fileName: serviceId
        )
    }
    
    // MARK: - Download Methods
    
    /// Downloads an image from a URL
    func downloadImage(fromURL url: URL) async throws -> UIImage {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else {
                throw StorageError.invalidImage
            }
            return image
        } catch {
            throw StorageError.downloadFailed(error.localizedDescription)
        }
    }
    
    /// Downloads an image from a storage path
    func downloadImage(fromPath path: String) async throws -> UIImage {
        let reference = storage.child(path)
        
        do {
            let data = try await reference.data(maxSize: 5 * 1024 * 1024) // 5MB max
            guard let image = UIImage(data: data) else {
                throw StorageError.invalidImage
            }
            return image
        } catch {
            throw StorageError.downloadFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Delete Methods
    
    /// Deletes a file from Firebase Storage
    func deleteFile(atPath path: String) async throws {
        let reference = storage.child(path)
        
        do {
            try await reference.delete()
        } catch {
            throw StorageError.unknownError(error.localizedDescription)
        }
    }
    
    /// Deletes a file from URL
    func deleteFile(fromURL url: URL) async throws {
        guard let path = extractPathFromURL(url) else {
            throw StorageError.unknownError("Invalid URL format")
        }
        
        try await deleteFile(atPath: path)
    }
    
    // MARK: - Helper Methods
    
    /// Extracts the storage path from a Firebase Storage URL
    private func extractPathFromURL(_ url: URL) -> String? {
        // Firebase Storage URLs have format like:
        // https://firebasestorage.googleapis.com/v0/b/[PROJECT_ID].appspot.com/o/[PATH]?alt=media&token=[TOKEN]
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let path = components.path.split(separator: "/").last,
              let decodedPath = path.removingPercentEncoding else {
            return nil
        }
        
        return decodedPath
    }
} 