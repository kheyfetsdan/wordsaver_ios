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
    private let keychainService: KeychainService
    private var cancellables = Set<AnyCancellable>()
    
    init(apiService: ApiService = DefaultApiService(),
         keychainService: KeychainService = .shared) {
        self.apiService = apiService
        self.keychainService = keychainService
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
                try keychainService.saveToken(response.token)
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
            } catch let error as KeychainError {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
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