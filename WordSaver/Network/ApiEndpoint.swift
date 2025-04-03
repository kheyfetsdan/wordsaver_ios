import Foundation

enum ApiEndpoint {
    case register(RegisterRequest)
    case login(LoginRequest)
    case saveWord(token: String, request: SaveWordRequest)
    case getWord(token: String)
    case getWordsByUser(token: String, request: GetWordsRequest)
    case getWordById(token: String, wordId: Int)
    case updateWord(token: String, request: SaveWordIdRequest)
    case deleteWord(token: String, wordId: Int)
    case updateWordStat(token: String, wordId: Int, request: WordStatRequest)
    case getQuizWord(token: String, request: QuizRequest)
    
    var path: String {
        switch self {
        case .register:
            return "/registration"
        case .login:
            return "/login"
        case .saveWord:
            return "/save-word"
        case .getWord:
            return "/sorted-random-word"
        case .getWordsByUser:
            return "/get-words-by-user"
        case .getWordById(_, let wordId):
            return "/word/\(wordId)"
        case .updateWord:
            return "/word"
        case .deleteWord(_, let wordId):
            return "/delete-word/\(wordId)"
        case .updateWordStat(_, let wordId, _):
            return "/word-stat/\(wordId)"
        case .getQuizWord:
            return "/quiz"
        }
    }
    
    var method: String {
        switch self {
        case .register, .login, .saveWord, .getWordsByUser, .getQuizWord:
            return "POST"
        case .getWord, .getWordById:
            return "GET"
        case .updateWord, .updateWordStat:
            return "PUT"
        case .deleteWord:
            return "DELETE"
        }
    }
    
    var headers: [String: String] {
        var headers = ["Content-Type": "application/json"]
        
        switch self {
        case .saveWord(let token, _),
             .getWord(let token),
             .getWordsByUser(let token, _),
             .getWordById(let token, _),
             .updateWord(let token, _),
             .deleteWord(let token, _),
             .updateWordStat(let token, _, _),
             .getQuizWord(let token, _):
            headers["Authorization"] = token
        default:
            break
        }
        
        return headers
    }
} 