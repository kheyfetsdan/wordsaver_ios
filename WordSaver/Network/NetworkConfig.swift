import Foundation
import Alamofire

class NetworkConfig {
    static let shared = NetworkConfig()
    
    let session: Session
    
    private init() {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        
        session = Session(configuration: configuration)
    }
    
    func setBaseURL(_ url: String) {
        UserDefaults.standard.set(url, forKey: "baseURL")
    }
    
    func getBaseURL() -> String {
        return UserDefaults.standard.string(forKey: "baseURL") ?? "https://wordsaveriii-e42ab50fe156.herokuapp.com"
    }
} 
