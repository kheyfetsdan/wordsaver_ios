import Foundation
import Security

class KeychainService {
    static let shared = KeychainService()
    
    private let service = "com.wordsaver.app"
    private let account = "auth_token"
    
    init() {}
    
    func saveToken(_ token: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: token.data(using: .utf8)!
        ]
        
        // Сначала удаляем существующий токен, если он есть
        SecItemDelete(query as CFDictionary)
        
        // Сохраняем новый токен
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveError
        }
    }
    
    func getToken() throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            throw KeychainError.notFound
        }
        
        return token
    }
    
    func deleteToken() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteError
        }
    }
}

enum KeychainError: Error {
    case saveError
    case deleteError
    case notFound
    
    var localizedDescription: String {
        switch self {
        case .saveError:
            return "Не удалось сохранить токен"
        case .deleteError:
            return "Не удалось удалить токен"
        case .notFound:
            return "Токен не найден"
        }
    }
} 