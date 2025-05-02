import Foundation
import FirebaseFirestore
import Combine

@MainActor
class SalonDiscoveryViewModel: ObservableObject {
    @Published var salons: [Salon] = []
    @Published var featuredSalons: [Salon] = []
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var selectedCategory: String?
    @Published var error: Error?
    @Published var filteredSalons: [Salon] = []
    
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Set up search debounce
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                if !text.isEmpty {
                    self?.searchSalons(query: text)
                } else {
                    self?.fetchSalons()
                }
            }
            .store(in: &cancellables)
        
        fetchSalons()
        fetchFeaturedSalons()
    }
    
    func fetchSalons() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                var query = db.collection("salons")
                    .whereField("verified", isEqualTo: true)
                    .limit(to: 20)
                
                if let category = selectedCategory {
                    query = query.whereField("categories", arrayContains: category)
                }
                
                let snapshot = try await query.getDocuments()
                salons = snapshot.documents.compactMap { Salon.fromFirestore(document: $0) }
                filteredSalons = salons
            } catch {
                self.error = error
                print("Error fetching salons: \(error)")
            }
        }
    }
    
    func fetchFeaturedSalons() {
        Task {
            do {
                let snapshot = try await db.collection("salons")
                    .whereField("verified", isEqualTo: true)
                    .whereField("featured", isEqualTo: true)
                    .limit(to: 5)
                    .getDocuments()
                
                featuredSalons = snapshot.documents.compactMap { Salon.fromFirestore(document: $0) }
            } catch {
                print("Error fetching featured salons: \(error)")
            }
        }
    }
    
    func searchSalons(query: String) {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                // Search in name and description
                let nameSnapshot = try await db.collection("salons")
                    .whereField("name", isGreaterThanOrEqualTo: query)
                    .whereField("name", isLessThan: query + "z")
                    .limit(to: 10)
                    .getDocuments()
                
                let descriptionSnapshot = try await db.collection("salons")
                    .whereField("description", isGreaterThanOrEqualTo: query)
                    .whereField("description", isLessThan: query + "z")
                    .limit(to: 10)
                    .getDocuments()
                
                // Combine and deduplicate results
                var searchResults = Set<String>()
                var results: [Salon] = []
                
                for document in nameSnapshot.documents + descriptionSnapshot.documents {
                    if !searchResults.contains(document.documentID),
                       let salon = Salon.fromFirestore(document: document) {
                        searchResults.insert(document.documentID)
                        results.append(salon)
                    }
                }
                
                filteredSalons = results
            } catch {
                self.error = error
                print("Error searching salons: \(error)")
            }
        }
    }
    
    func filterByCategory(_ category: String?) {
        selectedCategory = category
        fetchSalons()
    }
} 