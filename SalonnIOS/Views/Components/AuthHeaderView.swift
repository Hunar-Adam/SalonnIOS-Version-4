import SwiftUI

struct AuthHeaderView: View {
    let title: String
    let showLogo: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    init(title: String, showLogo: Bool = true) {
        self.title = title
        self.showLogo = showLogo
    }
    
    var body: some View {
        VStack(spacing: 8) {
            if showLogo {
                Text("Salonn")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(AppColors.accent(for: colorScheme))
                
                Text("Beauty & Wellness Appointments")
                    .font(.headline)
                    .foregroundColor(AppColors.textSecondary(for: colorScheme))
                
                Text("Environment: \(Bundle.main.appEnvironment.rawValue)")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary(for: colorScheme))
                    .padding(.bottom, 32)
            }
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary(for: colorScheme))
        }
    }
}

struct AuthHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AuthHeaderView(title: "Welcome Back")
                .preferredColorScheme(.light)
            
            AuthHeaderView(title: "Welcome Back")
                .preferredColorScheme(.dark)
        }
    }
} 