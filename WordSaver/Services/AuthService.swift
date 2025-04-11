import Foundation
import Combine

class AuthService: ObservableObject {
    @Published var isAuthenticated = false
    
    static let shared = AuthService()
    
    private let keychainService: KeychainService
    
    private init() {
        self.keychainService = KeychainService.shared
        self.isAuthenticated = (try? keychainService.getToken()) != nil
    }
    
    func login(token: String) {
        do {
            try keychainService.saveToken(token)
            isAuthenticated = true
        } catch {
            print("Ошибка при сохранении токена: \(error)")
        }
    }
    
    func logout() {
        do {
            try keychainService.deleteToken()
            isAuthenticated = false
        } catch {
            print("Ошибка при удалении токена: \(error)")
        }
    }
    
    func getToken() throws -> String {
        try keychainService.getToken()
    }
} 