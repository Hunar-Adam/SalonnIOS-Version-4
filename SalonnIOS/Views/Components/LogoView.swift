import SwiftUI

struct LogoView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "scissors")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .foregroundColor(Color(hex: "5D3FD3"))
            
            Text("Salonn")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(Color(hex: "5D3FD3"))
            
            Text("Beauty & Wellness Appointments")
                .font(.headline)
                .foregroundColor(Color(.systemGray))
            
            Text("Environment: \(Bundle.main.appEnvironment.rawValue)")
                .font(.subheadline)
                .foregroundColor(Color(.systemGray))
                .padding(.top, 4)
        }
        .padding(.top, 60)
    }
}

#Preview {
    LogoView()
} 