import Foundation
import Combine

class DictionaryViewModel: ObservableObject {
    @Published var words: [WordResponseRemote] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentPage = 1
    @Published var hasMorePages = true
    @Published var totalPages = 0
    @Published var sortingParam: String = "word"
    @Published var sortingDirection: String = "asc"
    
    private let pageSize = 10
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
        
        isLoading = true
        currentPage = 1
        hasMorePages = true
        
        Task { @MainActor in
            do {
                let token = try authService.getToken()
                let request = GetWordsRequest(
                    sortingParam: sortingParam,
                    sortingDirection: sortingDirection,
                    page: currentPage,
                    pageSize: pageSize
                )
                
                let response = try await apiService.getWordsByUser(token: token, request: request)
                words = response.wordList
                totalPages = (response.total + pageSize - 1) / pageSize
                hasMorePages = currentPage < totalPages
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
    
    func loadMoreWords() {
        guard !isLoading && hasMorePages else { return }
        
        isLoading = true
        currentPage += 1
        
        Task { @MainActor in
            do {
                let token = try authService.getToken()
                let request = GetWordsRequest(
                    sortingParam: sortingParam,
                    sortingDirection: sortingDirection,
                    page: currentPage,
                    pageSize: pageSize
                )
                
                let response = try await apiService.getWordsByUser(token: token, request: request)
                words.append(contentsOf: response.wordList)
                hasMorePages = currentPage < totalPages
            } catch {
                errorMessage = error.localizedDescription
                currentPage -= 1
            }
            
            isLoading = false
        }
    }
    
    func toggleSorting(param: String) {
        if sortingParam == param {
            sortingDirection = sortingDirection == "asc" ? "desc" : "asc"
        } else {
            sortingParam = param
            sortingDirection = "asc"
        }
        loadWords()
    }
}
