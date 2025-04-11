import Foundation
import Combine

class DictionaryViewModel: ObservableObject {
    @Published var words: [WordResponseRemote] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentPage = 1
    @Published var hasMorePages = true
    @Published var totalPages = 0
    
    private let pageSize = 5
    private let apiService: ApiService
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()
    
    init(apiService: ApiService = DefaultApiService(),
         authService: AuthService = .shared) {
        self.apiService = apiService
        self.authService = authService
    }
    
    func loadWords() {
        guard !isLoading else { return }
        
        do {
            let token = try authService.getToken()
            isLoading = true
            errorMessage = nil
            
            let request = GetWordsRequest(
                sortingParam: "word",
                sortingDirection: "asc",
                page: currentPage,
                pageSize: pageSize
            )
            
            Task {
                do {
                    let response = try await apiService.getWordsByUser(token: token, request: request)
                    await MainActor.run {
                        words = response.wordList
                        totalPages = calculateTotalPages(total: response.total, pageSize: pageSize)
                        hasMorePages = currentPage < totalPages
                        isLoading = false
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
                            errorMessage = "Ошибка при загрузке слов"
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
    
    func nextPage() {
        guard hasMorePages else { return }
        currentPage += 1
        loadWords()
    }
    
    func previousPage() {
        guard currentPage > 1 else { return }
        currentPage -= 1
        loadWords()
    }
    
    func refresh() {
        currentPage = 1
        hasMorePages = true
        loadWords()
    }
    
    func calculateTotalPages(total: Int, pageSize: Int) -> Int {
        return (total + pageSize - 1) / pageSize
    }
}
