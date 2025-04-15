import SwiftUI

struct QuizView: View {
    @StateObject private var viewModel = QuizViewModel()
    @Binding var selectedTabIndex: Int
    
    var body: some View {
        VStack(spacing: 20) {
            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    
                    Text(error)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                    
                    if error == "Недостаточно слов, чтобы начать квиз" {
                        Button(action: {
                            selectedTabIndex = 0 // Переключаемся на первую вкладку (Ввод)
                        }) {
                            Text("Добавить слова")
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 24)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let quiz = viewModel.currentQuiz {
                Text(quiz.word)
                    .font(.largeTitle)
                    .padding()
                
                ForEach(viewModel.shuffledTranslations, id: \.self) { translation in
                    Button(action: {
                        Task {
                            await viewModel.checkAnswer(translation)
                        }
                    }) {
                        Text(translation)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.getButtonColor(for: translation))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(viewModel.isButtonDisabled(for: translation))
                }
            }
        }
        .padding()
        .task {
            await viewModel.fetchQuizWord()
        }
    }
}

#Preview {
    QuizView(selectedTabIndex: .constant(0))
} 