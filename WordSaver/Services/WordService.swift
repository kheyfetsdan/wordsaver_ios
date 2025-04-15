import Foundation

class WordService {
    private let apiService: ApiService
    
    init(apiService: ApiService = DefaultApiService()) {
        self.apiService = apiService
    }
    
    func getWord(token: String) async throws -> WordResponseRemote {
        try await apiService.getWord(token: token)
    }
    
    func updateWordStat(token: String, wordId: Int, request: WordStatRequest) async throws {
        _ = try await apiService.updateWordStat(token: token, wordId: wordId, request: request)
    }
} 