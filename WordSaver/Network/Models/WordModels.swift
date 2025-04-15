import Foundation

struct SaveWordRequest: Encodable {
    let word: String
    let translation: String
}

struct SaveWordIdRequest: Encodable {
    let id: Int
    let word: String
    let translation: String
}

struct GetWordsRequest: Encodable {
    let sortingParam: String
    let sortingDirection: String
    let page: Int
    let pageSize: Int
}

struct GetWordsResponse: Decodable {
    let wordList: [WordResponseRemote]
    let total: Int
    let page: Int
}

struct WordResponseRemote: Codable {
    let id: Int
    let word: String
    let translation: String
    let success: Int
    let failed: Int
    let addedAt: String
}

struct WordStatRequest: Encodable {
    let success: Bool
}

struct QuizRequest: Encodable {
    let previousWord: String
}

struct QuizResponse: Decodable {
    let id: Int
    let word: String
    let trueTranslation: String
    let translation1: String
    let translation2: String
    let translation3: String
}
