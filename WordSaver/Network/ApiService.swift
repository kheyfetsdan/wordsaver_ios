import Foundation
import Alamofire
import Combine

protocol ApiService {
    func register(request: RegisterRequest) async throws -> RegisterResponse
    func login(request: LoginRequest) async throws -> LoginResponse
    func saveWord(token: String, request: SaveWordRequest) async throws
    func getWord(token: String) async throws -> WordResponseRemote
    func getWordsByUser(token: String, request: GetWordsRequest) async throws -> GetWordsResponse
    func getWordById(token: String, wordId: Int) async throws -> WordResponseRemote
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
    
    private func handleResponse<T: Decodable>(_ response: DataResponse<T, AFError>) throws -> T {
        if let statusCode = response.response?.statusCode {
            switch statusCode {
            case 200...299:
                if let value = response.value {
                    return value
                }
                throw ApiError.invalidResponse
            case 400:
                throw ApiError.unauthorized
            case 401:
                throw ApiError.unauthorized
            case 409:
                throw ApiError.accountExists
            case 400...499:
                if let data = response.data,
                   let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw ApiError.serverError(message: errorResponse.message)
                }
                throw ApiError.serverError(message: "Ошибка клиента")
            case 500...599:
                throw ApiError.serverError(message: "Ошибка сервера")
            default:
                throw ApiError.networkError
            }
        } else {
            throw ApiError.networkError
        }
    }
    
    private func getHeaders(token: String? = nil) -> HTTPHeaders {
        var headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        if let token = token {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return headers
    }
    
    func register(request: RegisterRequest) async throws -> RegisterResponse {
        do {
            let response = try await session.request(
                baseURL + "/registration",
                method: .post,
                parameters: request,
                encoder: JSONParameterEncoder.default
            )
            .validate()
            .serializingDecodable(RegisterResponse.self)
            .response
            
            return try handleResponse(response)
        } catch let error as ApiError {
            throw error
        } catch {
            throw ApiError.networkError
        }
    }
    
    func login(request: LoginRequest) async throws -> LoginResponse {
        do {
            let response = try await session.request(
                baseURL + "/login",
                method: .post,
                parameters: request,
                encoder: JSONParameterEncoder.default
            )
            .validate()
            .serializingDecodable(LoginResponse.self)
            .response
            
            return try handleResponse(response)
        } catch let error as ApiError {
            throw error
        } catch {
            throw ApiError.networkError
        }
    }
    
    func saveWord(token: String, request: SaveWordRequest) async throws {
        try await session.request(
            baseURL + "/save-word",
            method: .post,
            parameters: request,
            encoder: JSONParameterEncoder.default,
            headers: getHeaders(token: token)
        )
        .validate()
        .serializingString()
        .value
    }
    
    func getWord(token: String) async throws -> WordResponseRemote {
        try await session.request(
            baseURL + "/sorted-random-word",
            method: .get,
            headers: getHeaders(token: token)
        )
        .validate()
        .serializingDecodable(WordResponseRemote.self)
        .value
    }
    
    func getWordsByUser(token: String, request: GetWordsRequest) async throws -> GetWordsResponse {
        try await session.request(
            baseURL + "/get-words-by-user",
            method: .post,
            parameters: request,
            encoder: JSONParameterEncoder.default,
            headers: getHeaders(token: token)
        )
        .validate()
        .serializingDecodable(GetWordsResponse.self)
        .value
    }
    
    func getWordById(token: String, wordId: Int) async throws -> WordResponseRemote {
        try await session.request(
            baseURL + "/word/\(wordId)",
            method: .get,
            headers: getHeaders(token: token)
        )
        .validate()
        .serializingDecodable(WordResponseRemote.self)
        .value
    }
    
    func updateWord(token: String, request: SaveWordIdRequest) async throws {
        try await session.request(
            baseURL + "/word",
            method: .put,
            parameters: request,
            encoder: JSONParameterEncoder.default,
            headers: getHeaders(token: token)
        )
        .validate()
        .serializingString()
        .value
    }
    
    func deleteWord(token: String, wordId: Int) async throws {
        try await session.request(
            baseURL + "/delete-word/\(wordId)",
            method: .delete,
            headers: getHeaders(token: token)
        )
        .validate()
        .serializingString()
        .value
    }
    
    func updateWordStat(token: String, wordId: Int, request: WordStatRequest) async throws {
        try await session.request(
            baseURL + "/word-stat/\(wordId)",
            method: .put,
            parameters: request,
            encoder: JSONParameterEncoder.default,
            headers: getHeaders(token: token)
        )
        .validate()
        .serializingString()
        .value
    }
    
    func getQuizWord(token: String, request: QuizRequest) async throws -> QuizResponse {
        try await session.request(
            baseURL + "/quiz",
            method: .post,
            parameters: request,
            encoder: JSONParameterEncoder.default,
            headers: getHeaders(token: token)
        )
        .validate()
        .serializingDecodable(QuizResponse.self)
        .value
    }
}

// Пустая структура для пустых ответов
struct EmptyResponse: Decodable {}

// Структура для парсинга ошибок от сервера
struct ErrorResponse: Decodable {
    let message: String
} 
