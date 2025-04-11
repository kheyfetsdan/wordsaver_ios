import Foundation

enum ApiError: Error {
    case networkError
    case serverError(message: String)
    case unauthorized
    case invalidResponse
    case accountExists
    
    var localizedDescription: String {
        switch self {
        case .networkError:
            return "Ошибка сети"
        case .serverError(let message):
            return message
        case .unauthorized:
            return "Ошибка авторизации"
        case .invalidResponse:
            return "Неверный ответ от сервера"
        case .accountExists:
            return "Аккаунт с таким email уже зарегистрирован"
        }
    }
} 