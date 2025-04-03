import SwiftUI

struct AuthSplashView: View {
    @State private var showLogin = false
    @State private var showRegistration = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()
                
                Text("WordSaver")
                    .font(.system(size: 36, weight: .bold))
                
                VStack(spacing: 16) {
                    Button(action: {
                        showRegistration = true
                    }) {
                        Text("Я новый пользователь")
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        showLogin = true
                    }) {
                        Text("У меня есть аккаунт")
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(.systemGray5))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .sheet(isPresented: $showLogin) {
            LoginView()
        }
        .sheet(isPresented: $showRegistration) {
            RegistrationView()
        }
    }
}

#Preview {
    AuthSplashView()
} 