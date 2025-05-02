import SwiftUI

struct SalonProfileView: View {
    let salon: Salon
    @StateObject private var viewModel = SalonProfileViewModel()
    @State private var showingBookingSheet = false
    @State private var selectedDate = Date()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Salon Header
                if let imageUrl = salon.imageURLs.first {
                    CachedAsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                    .frame(height: 250)
                    .clipped()
                }
                
                // Salon Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(salon.name)
                        .font(.title)
                        .bold()
                    
                    Text(salon.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(salon.address.formattedAddress)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Image(systemName: "phone")
                            .foregroundColor(.gray)
                        Text(salon.phoneNumber)
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.gray)
                        Text(salon.email)
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", salon.averageRating))
                        Text("(\(salon.reviewCount) reviews)")
                            .foregroundColor(.gray)
                    }
                    .font(.subheadline)
                    
                    // Working Hours
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Working Hours")
                            .font(.headline)
                            .padding(.top, 8)
                        
                        ForEach(salon.workingHours, id: \.day) { day in
                            if day.isOpen {
                                HStack {
                                    Text(day.dayName)
                                    Spacer()
                                    if let open = day.openTime, let close = day.closeTime {
                                        Text("\(formatTime(open)) - \(formatTime(close))")
                                    }
                                }
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Services Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Services")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else if let error = viewModel.error {
                        ErrorView(error: error) {
                            viewModel.fetchServices(for: salon.id)
                        }
                    } else {
                        ForEach(viewModel.services) { service in
                            ServiceRow(service: service) {
                                viewModel.selectedService = service
                                showingBookingSheet = true
                            }
                        }
                    }
                }
                .padding(.top)
            }
        }
        .navigationTitle("Salon Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchServices(for: salon.id)
        }
        .sheet(isPresented: $showingBookingSheet) {
            if let service = viewModel.selectedService {
                BookingView(
                    service: service,
                    viewModel: viewModel,
                    isPresented: $showingBookingSheet
                )
            }
        }
        .alert("Booking Successful", isPresented: $viewModel.bookingSuccess) {
            Button("OK") {
                showingBookingSheet = false
            }
        } message: {
            Text("Your appointment has been booked successfully!")
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ServiceRow: View {
    let service: Service
    var onBook: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(service.name)
                    .font(.headline)
                Spacer()
                Text("$\(String(format: "%.2f", service.price))")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            
            Text(service.description)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.gray)
                Text("\(service.duration) minutes")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Button(action: onBook) {
                Text("Book Now")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

struct BookingView: View {
    let service: Service
    @ObservedObject var viewModel: SalonProfileViewModel
    @Binding var isPresented: Bool
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    in: Date()...,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                
                if viewModel.isLoading {
                    ProgressView()
                } else if let error = viewModel.error {
                    ErrorView(error: error) {
                        viewModel.fetchAvailableTimeSlots(for: service, date: selectedDate)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            ForEach(viewModel.availableTimeSlots, id: \.self) { timeSlot in
                                Button(action: {
                                    viewModel.bookAppointment(service: service, date: timeSlot)
                                }) {
                                    Text(timeSlot.formatted(date: .omitted, time: .shortened))
                                        .font(.subheadline)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Book \(service.name)")
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
            .onChange(of: selectedDate) { newDate in
                viewModel.fetchAvailableTimeSlots(for: service, date: newDate)
            }
        }
    }
}

struct ErrorView: View {
    let error: Error
    var retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            
            Text(error.localizedDescription)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            
            Button("Retry", action: retryAction)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding()
    }
}

#Preview {
    NavigationView {
        SalonProfileView(salon: Salon(
            id: "1",
            name: "Luxury Hair Studio",
            description: "Premier hair salon offering top-notch services",
            address: Salon.Address(
                street: "123 Main St",
                city: "New York",
                state: "NY",
                zipCode: "10001",
                country: "USA",
                coordinates: nil
            ),
            phoneNumber: "(555) 123-4567",
            email: "info@luxuryhair.com",
            websiteURL: nil,
            imageURLs: ["https://example.com/salon1.jpg"],
            services: [],
            staff: ["John Doe", "Jane Smith"],
            ownerId: "owner123",
            workingHours: [
                Salon.WorkingDay(day: 2, isOpen: true, openTime: Date(), closeTime: Date()),
                Salon.WorkingDay(day: 3, isOpen: true, openTime: Date(), closeTime: Date()),
                Salon.WorkingDay(day: 4, isOpen: true, openTime: Date(), closeTime: Date()),
                Salon.WorkingDay(day: 5, isOpen: true, openTime: Date(), closeTime: Date()),
                Salon.WorkingDay(day: 6, isOpen: true, openTime: Date(), closeTime: Date())
            ],
            averageRating: 4.8,
            reviewCount: 128,
            verified: true,
            createdAt: Date(),
            updatedAt: Date()
        ))
    }
}

