import Foundation
import Combine

class SaveWordViewModel: ObservableObject {
    @Published var word = ""
    @Published var translation = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isWordSaved = false
    
    private let apiService: ApiService
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()
    
    init(apiService: ApiService = DefaultApiService(),
         authService: AuthService = .shared) {
        self.apiService = apiService
        self.authService = authService
    }
    
    var isFormValid: Bool {
        !word.isEmpty && !translation.isEmpty
    }
    
    func saveWord() {
        guard isFormValid else {
            errorMessage = "Пожалуйста, заполните все поля"
            return
        }
        
        do {
            let token = try authService.getToken()
            isLoading = true
            errorMessage = nil
            
            let request = SaveWordRequest(word: word, translation: translation)
            
            Task {
                do {
                    try await apiService.saveWord(token: token, request: request)
                    await MainActor.run {
                        isLoading = false
                        isWordSaved = true
                        word = ""
                        translation = ""
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
                            errorMessage = "Ошибка при сохранении слова"
                        }
                    }
                } catch {
                    await MainActor.run {
                        isLoading = false
                        errorMessage = "Произошла неизвестная ошибка: \(error.localizedDescription)"
                    }
                }
            }
        } catch {
            errorMessage = "Ошибка авторизации"
        }
    }
} 