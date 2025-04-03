import Foundation

struct RegisterRequest: Encodable {
    let email: String
    let password: String
}

struct RegisterResponse: Decodable {
    let token: String
}

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct LoginResponse: Decodable {
    let token: String
} 