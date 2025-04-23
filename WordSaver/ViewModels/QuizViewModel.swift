import Foundation
import Combine
import SwiftUI

class QuizViewModel: ObservableObject {
    @Published var currentQuiz: QuizResponse?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedTranslation: String?
    @Published var showNextWord: Bool = false
    @Published var shuffledTranslations: [String] = []
    @Published var timeRemaining: Int = 3
    
    private let apiService: ApiService
    private let authService: AuthService
    private var timer: Timer?
    private let userDefaults = UserDefaults.standard
    private let previousWordKey = "previousQuizWord"
    private let hasAnsweredKey = "hasAnsweredQuiz"
    
    init(apiService: ApiService = DefaultApiService(), authService: AuthService = .shared) {
        self.apiService = apiService
        self.authService = authService
        
        // Загружаем сохраненное слово при инициализации
        if let savedWord = loadSavedWord() {
            currentQuiz = savedWord
            shuffledTranslations = loadShuffledTranslations()
        }
    }
    
    private func loadSavedWord() -> QuizResponse? {
        guard let data = userDefaults.data(forKey: previousWordKey),
              let word = try? JSONDecoder().decode(QuizResponse.self, from: data) else {
            return nil
        }
        return word
    }
    
    private func loadShuffledTranslations() -> [String] {
        guard let data = userDefaults.data(forKey: "shuffledTranslations"),
              let translations = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return translations
    }
    
    private func saveCurrentWord() {
        if let word = currentQuiz,
           let data = try? JSONEncoder().encode(word) {
            userDefaults.set(data, forKey: previousWordKey)
            userDefaults.set(false, forKey: hasAnsweredKey)
            
            if let translationsData = try? JSONEncoder().encode(shuffledTranslations) {
                userDefaults.set(translationsData, forKey: "shuffledTranslations")
            }
        }
    }
    
    private func clearSavedWord() {
        userDefaults.removeObject(forKey: previousWordKey)
        userDefaults.removeObject(forKey: hasAnsweredKey)
        userDefaults.removeObject(forKey: "shuffledTranslations")
    }
    
    private func getPreviousWord() -> String {
        userDefaults.string(forKey: previousWordKey) ?? ""
    }
    
    private func savePreviousWord(_ word: String) {
        userDefaults.set(word, forKey: previousWordKey)
    }
    
    @MainActor
    func fetchQuizWord() async {
        // Проверяем, есть ли сохраненное слово и был ли на него ответ
        if let savedWord = loadSavedWord(),
           !userDefaults.bool(forKey: hasAnsweredKey) {
            currentQuiz = savedWord
            shuffledTranslations = loadShuffledTranslations()
            return
        }
        
        isLoading = true
        errorMessage = nil
        selectedTranslation = nil
        showNextWord = false
        timeRemaining = 3
        
        do {
            let token = try authService.getToken()
            let previousWord = getPreviousWord()
            let request = QuizRequest(previousWord: previousWord)
            
            currentQuiz = try await apiService.getQuizWord(token: token, request: request)
            
            if let quiz = currentQuiz {
                // Сохраняем текущее слово как предыдущее для следующего запроса
                savePreviousWord(quiz.word)
                
                // Перемешиваем переводы
                var translations = [quiz.trueTranslation, quiz.translation1, quiz.translation2, quiz.translation3]
                translations.shuffle()
                shuffledTranslations = translations
                
                // Сохраняем текущее состояние
                saveCurrentWord()
            }
        } catch let error as ApiError {
            switch error {
            case .serverError(let message) where message.contains("412"):
                errorMessage = "Недостаточно слов, чтобы начать квиз"
            default:
                errorMessage = error.localizedDescription
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func checkAnswer(_ selectedAnswer: String) async {
        guard let currentQuiz = currentQuiz else { return }
        
        let isCorrect = selectedAnswer == currentQuiz.trueTranslation
        selectedTranslation = selectedAnswer
        
        do {
            let token = try authService.getToken()
            let request = WordStatRequest(success: isCorrect)
            
            try await apiService.updateWordStat(
                token: token,
                wordId: currentQuiz.id,
                request: request
            )
            
            if isCorrect {
                showNextWord = true
                timeRemaining = 3
                userDefaults.set(true, forKey: hasAnsweredKey)
                
                // Запускаем таймер обратного отсчета
                timer?.invalidate()
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                    Task { @MainActor in
                        guard let self = self else { return }
                        if self.timeRemaining > 0 {
                            self.timeRemaining -= 1
                        } else {
                            self.timer?.invalidate()
                            self.timer = nil
                            await self.fetchQuizWord()
                        }
                    }
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func getButtonColor(for translation: String) -> Color {
        guard let selected = selectedTranslation,
              let currentQuiz = currentQuiz else {
            return .blue
        }
        
        if selected == translation {
            return translation == currentQuiz.trueTranslation ? .green : .red
        }
        
        return .blue
    }
    
    func isButtonDisabled(for translation: String) -> Bool {
        guard let selected = selectedTranslation,
              let currentQuiz = currentQuiz else {
            return false
        }
        
        // Блокируем только неправильный выбранный ответ
        return selected == translation && translation != currentQuiz.trueTranslation
    }
} 
