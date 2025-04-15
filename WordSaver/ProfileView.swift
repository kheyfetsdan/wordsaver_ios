import SwiftUI

struct ProfileView: View {
    @StateObject private var authService = AuthService.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Здесь можно добавить информацию о пользователе
            VStack(spacing: 10) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                
                Text("Имя пользователя")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding(.bottom, 40)
            
            Button(action: {
                authService.logout()
            }) {
                Text("Выйти из приложения")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProfileView()
} 