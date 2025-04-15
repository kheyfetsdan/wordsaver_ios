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
    
    private let apiService: ApiService
    private let authService: AuthService
    private var timer: Timer?
    private let userDefaults = UserDefaults.standard
    private let previousWordKey = "previousQuizWord"
    
    init(apiService: ApiService = DefaultApiService(), authService: AuthService = .shared) {
        self.apiService = apiService
        self.authService = authService
    }
    
    private func getPreviousWord() -> String {
        userDefaults.string(forKey: previousWordKey) ?? ""
    }
    
    private func savePreviousWord(_ word: String) {
        userDefaults.set(word, forKey: previousWordKey)
    }
    
    @MainActor
    func fetchQuizWord() async {
        isLoading = true
        errorMessage = nil
        selectedTranslation = nil
        showNextWord = false
        
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
                // Запускаем таймер на 3 секунды для следующего слова
                timer?.invalidate()
                timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                    Task { @MainActor in
                        await self?.fetchQuizWord()
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
