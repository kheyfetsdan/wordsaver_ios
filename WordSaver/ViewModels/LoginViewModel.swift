import Foundation
import Combine

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isLoginSuccessful = false
    
    private let apiService: ApiService
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()
    
    init(apiService: ApiService = DefaultApiService(),
         authService: AuthService = .shared) {
        self.apiService = apiService
        self.authService = authService
    }
    
    var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    func login() {
        guard isFormValid else {
            errorMessage = "Пожалуйста, заполните все поля"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let request = LoginRequest(email: email, password: password)
        
        Task {
            do {
                let response = try await apiService.login(request: request)
                try authService.login(token: response.token)
                await MainActor.run {
                    isLoading = false
                    isLoginSuccessful = true
                }
            } catch let error as ApiError {
                await MainActor.run {
                    isLoading = false
                    switch error {
                    case .networkError:
                        errorMessage = "Ошибка сети. Проверьте подключение к интернету"
                    case .serverError(let message):
                        if message.contains("400") {
                            errorMessage = "Неверный email или пароль"
                        } else {
                            errorMessage = message
                        }
                    case .unauthorized:
                        errorMessage = "Неверный email или пароль"
                    case .invalidResponse:
                        errorMessage = "Неверный ответ от сервера"
                    case .accountExists:
                        errorMessage = "Аккаунт с таким email уже зарегистрирован"
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Произошла неизвестная ошибка: \(error.localizedDescription)"
                }
            }
        }
    }
} 