import Foundation
import Combine

class RandomWordViewModel: ObservableObject {
    @Published var currentWord: WordResponseRemote?
    @Published var translation: String = ""
    @Published var showTranslation: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isAnswerCorrect: Bool?
    @Published var showNotification: Bool = false
    @Published var showConfirmationDialog: Bool = false
    @Published var showSkipConfirmationDialog: Bool = false
    
    private let wordService: WordService
    private let authService: AuthService
    private var timer: Timer?
    private let userDefaults = UserDefaults.standard
    private let currentWordKey = "currentWord"
    private let hasAnsweredKey = "hasAnswered"
    
    init(wordService: WordService = WordService(), authService: AuthService = .shared) {
        self.wordService = wordService
        self.authService = authService
        
        // Загружаем сохраненное слово при инициализации
        if let savedWord = loadSavedWord() {
            currentWord = savedWord
        }
    }
    
    private func loadSavedWord() -> WordResponseRemote? {
        guard let data = userDefaults.data(forKey: currentWordKey),
              let word = try? JSONDecoder().decode(WordResponseRemote.self, from: data) else {
            return nil
        }
        return word
    }
    
    private func saveCurrentWord() {
        if let word = currentWord,
           let data = try? JSONEncoder().encode(word) {
            userDefaults.set(data, forKey: currentWordKey)
            userDefaults.set(false, forKey: hasAnsweredKey)
        }
    }
    
    private func clearSavedWord() {
        userDefaults.removeObject(forKey: currentWordKey)
        userDefaults.removeObject(forKey: hasAnsweredKey)
    }
    
    @MainActor
    func fetchRandomWord() async {
        // Проверяем, есть ли сохраненное слово и был ли на него ответ
        if let savedWord = loadSavedWord(),
           !userDefaults.bool(forKey: hasAnsweredKey) {
            currentWord = savedWord
            return
        }
        
        isLoading = true
        errorMessage = nil
        showTranslation = false
        translation = ""
        isAnswerCorrect = nil
        showNotification = false
        
        do {
            let token = try authService.getToken()
            currentWord = try await wordService.getWord(token: token)
            saveCurrentWord()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func checkAnswer() async {
        guard let currentWord = currentWord else { return }
        
        do {
            let token = try authService.getToken()
            let isCorrect = translation.lowercased() == currentWord.translation.lowercased()
            let request = WordStatRequest(success: isCorrect)
            
            try await wordService.updateWordStat(
                token: token,
                wordId: currentWord.id,
                request: request
            )
            
            isAnswerCorrect = isCorrect
            showNotification = true
            userDefaults.set(true, forKey: hasAnsweredKey)
            
            // Запускаем таймер на 3 секунды
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                Task { @MainActor in
                    await self?.fetchRandomWord()
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func skipWord() async {
        guard let currentWord = currentWord else { return }
        
        do {
            let token = try authService.getToken()
            let request = WordStatRequest(success: false)
            try await wordService.updateWordStat(
                token: token,
                wordId: currentWord.id,
                request: request
            )
            
            userDefaults.set(true, forKey: hasAnsweredKey)
            clearSavedWord()
            await fetchRandomWord()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func showTranslationAndSkip() async {
        guard let currentWord = currentWord else { return }
        
        do {
            let token = try authService.getToken()
            let request = WordStatRequest(success: false)
            try await wordService.updateWordStat(
                token: token,
                wordId: currentWord.id,
                request: request
            )
            
            userDefaults.set(true, forKey: hasAnsweredKey)
            showTranslation = true
            
            // Запускаем таймер на 3 секунды
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                Task { @MainActor in
                    await self?.fetchRandomWord()
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func requestShowTranslation() {
        showConfirmationDialog = true
    }
    
    func requestSkipWord() {
        showSkipConfirmationDialog = true
    }
} 