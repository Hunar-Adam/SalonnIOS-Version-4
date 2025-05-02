import SwiftUI

struct SalonDiscoveryView: View {
    @StateObject private var viewModel = SalonDiscoveryViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                SearchBar(text: $searchText, onSearch: {
                    viewModel.searchSalons(query: searchText)
                })
                .padding()
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.error {
                    ErrorView(error: error) {
                        viewModel.fetchSalons()
                    }
                } else {
                    // Salon List
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.filteredSalons) { salon in
                                NavigationLink(destination: SalonProfileView(salon: salon)) {
                                    SalonCard(salon: salon)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Discover Salons")
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    var onSearch: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search salons...", text: $text, onCommit: onSearch)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                    onSearch()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

struct SalonCard: View {
    let salon: Salon
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Salon Image
            if let imageUrl = salon.imageURLs.first {
                CachedAsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                .frame(height: 200)
                .clipped()
            }
            
            // Salon Info
            VStack(alignment: .leading, spacing: 4) {
                Text(salon.name)
                    .font(.headline)
                
                Text(salon.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                Text(salon.address.formattedAddress)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", salon.averageRating))
                    Text("(\(salon.reviewCount) reviews)")
                        .foregroundColor(.gray)
                }
                .font(.subheadline)
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

#Preview {
    SalonDiscoveryView()
} 