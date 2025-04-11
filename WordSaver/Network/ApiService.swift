import Foundation
import Alamofire

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

class DefaultApiService: ApiService {
    private var baseURL: String {
        NetworkConfig.shared.getBaseURL()
    }
    
    private var session: Session {
        NetworkConfig.shared.session
    }
    
    func register(request: RegisterRequest) async throws -> RegisterResponse {
        try await session.request(
            baseURL + "/registration",
            method: .post,
            parameters: request,
            encoder: JSONParameterEncoder.default
        )
        .validate()
        .serializingDecodable(RegisterResponse.self)
        .value
    }
    
    func login(request: LoginRequest) async throws -> LoginResponse {
        try await session.request(
            baseURL + "/login",
            method: .post,
            parameters: request,
            encoder: JSONParameterEncoder.default
        )
        .validate()
        .serializingDecodable(LoginResponse.self)
        .value
    }
    
    func saveWord(token: String, request: SaveWordRequest) async throws {
        try await session.request(
            baseURL + "/save-word",
            method: .post,
            parameters: request,
            encoder: JSONParameterEncoder.default,
            headers: ["Authorization": token]
        )
        .validate()
        .serializingDecodable(EmptyResponse.self)
        .value
    }
    
    func getWord(token: String) async throws -> WordResponse {
        try await session.request(
            baseURL + "/sorted-random-word",
            method: .get,
            headers: ["Authorization": token]
        )
        .validate()
        .serializingDecodable(WordResponse.self)
        .value
    }
    
    func getWordsByUser(token: String, request: GetWordsRequest) async throws -> GetWordsResponse {
        try await session.request(
            baseURL + "/get-words-by-user",
            method: .post,
            parameters: request,
            encoder: JSONParameterEncoder.default,
            headers: ["Authorization": token]
        )
        .validate()
        .serializingDecodable(GetWordsResponse.self)
        .value
    }
    
    func getWordById(token: String, wordId: Int) async throws -> WordResponse {
        try await session.request(
            baseURL + "/word/\(wordId)",
            method: .get,
            headers: ["Authorization": token]
        )
        .validate()
        .serializingDecodable(WordResponse.self)
        .value
    }
    
    func updateWord(token: String, request: SaveWordIdRequest) async throws {
        try await session.request(
            baseURL + "/word",
            method: .put,
            parameters: request,
            encoder: JSONParameterEncoder.default,
            headers: ["Authorization": token]
        )
        .validate()
        .serializingDecodable(EmptyResponse.self)
        .value
    }
    
    func deleteWord(token: String, wordId: Int) async throws {
        try await session.request(
            baseURL + "/delete-word/\(wordId)",
            method: .delete,
            headers: ["Authorization": token]
        )
        .validate()
        .serializingDecodable(EmptyResponse.self)
        .value
    }
    
    func updateWordStat(token: String, wordId: Int, request: WordStatRequest) async throws {
        try await session.request(
            baseURL + "/word-stat/\(wordId)",
            method: .put,
            parameters: request,
            encoder: JSONParameterEncoder.default,
            headers: ["Authorization": token]
        )
        .validate()
        .serializingDecodable(EmptyResponse.self)
        .value
    }
    
    func getQuizWord(token: String, request: QuizRequest) async throws -> QuizResponse {
        try await session.request(
            baseURL + "/quiz",
            method: .post,
            parameters: request,
            encoder: JSONParameterEncoder.default,
            headers: ["Authorization": token]
        )
        .validate()
        .serializingDecodable(QuizResponse.self)
        .value
    }
}

// Пустая структура для пустых ответов
struct EmptyResponse: Decodable {} 