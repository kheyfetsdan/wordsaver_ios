import Foundation
import Combine

class RegistrationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isRegistrationSuccessful = false
    
    private let apiService: ApiService
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()
    
    init(apiService: ApiService = DefaultApiService(),
         authService: AuthService = .shared) {
        self.apiService = apiService
        self.authService = authService
    }
    
    var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && password == confirmPassword
    }
    
    func register() {
        guard isFormValid else {
            errorMessage = "Пожалуйста, заполните все поля и убедитесь, что пароли совпадают"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let request = RegisterRequest(email: email, password: password)
        
        Task {
            do {
                let response = try await apiService.register(request: request)
                authService.login(token: response.token)
                await MainActor.run {
                    isLoading = false
                    isRegistrationSuccessful = true
                }
            } catch let error as ApiError {
                await MainActor.run {
                    isLoading = false
                    switch error {
                    case .networkError:
                        errorMessage = "Ошибка сети. Проверьте подключение к интернету"
                    case .serverError(let message):
                        errorMessage = message
                    case .unauthorized:
                        errorMessage = "Ошибка авторизации"
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