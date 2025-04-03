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
    let page: Int
    let pageSize: Int
    let sortType: String
}

struct GetWordsResponse: Decodable {
    let words: [WordResponse]
    let totalPages: Int
}

struct WordResponse: Decodable {
    let id: Int
    let word: String
    let translation: String
    let correctAnswers: Int
    let incorrectAnswers: Int
}

struct WordStatRequest: Encodable {
    let isCorrect: Bool
}

struct QuizRequest: Encodable {
    let excludeWordIds: [Int]
}

struct QuizResponse: Decodable {
    let word: WordResponse
    let options: [String]
} 