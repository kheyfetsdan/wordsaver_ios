import SwiftUI

struct QuizView: View {
    @StateObject private var viewModel = QuizViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
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
    QuizView()
} 