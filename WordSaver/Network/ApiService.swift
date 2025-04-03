import Foundation

protocol ApiService {
    func register(request: RegisterRequest) async throws -> RegisterResponse
    func login(request: LoginRequest) async throws -> LoginResponse
    func saveWord(token: String, request: SaveWordRequest) async throws
    func getWord(token: String) async throws -> WordResponse
    func getWordsByUser(token: String, request: GetWordsRequest) async throws -> GetWordsResponse
    func getWordById(token: String, wordId: Int) async throws -> WordResponse
    func updateWord(token: String, request: SaveWordIdRequest) async throws
    func deleteWord(token: String, wordId: Int) async throws
    func updateWordStat(token: String, wordId: Int, request: WordStatRequest) async throws
    func getQuizWord(token: String, request: QuizRequest) async throws -> QuizResponse
} 