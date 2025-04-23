import SwiftUI

struct QuizView: View {
    @StateObject private var viewModel = QuizViewModel()
    @Binding var selectedTabIndex: Int
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    ScrollView {
                        VStack(spacing: 24) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .scaleEffect(1.5)
                            } else if let error = viewModel.errorMessage {
                                // Error View
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
                                            selectedTabIndex = 0
                                        }) {
                                            HStack {
                                                Image(systemName: "plus.circle.fill")
                                                Text("Добавить слова")
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(12)
                                            .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 2)
                                        }
                                        .frame(width: geometry.size.width - 32)
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            } else if let quiz = viewModel.currentQuiz {
                                // Quiz Content
                                VStack(spacing: 32) {
                                    // Word Card
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            Image(systemName: "questionmark.circle.fill")
                                                .foregroundColor(.blue)
                                                .font(.title2)
                                            Text("Переведите слово")
                                                .font(.headline)
                                                .foregroundColor(.gray)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Text(quiz.word)
                                            .font(.system(size: 32, weight: .bold))
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .padding(.vertical, 8)
                                    }
                                    .padding()
                                    .frame(width: geometry.size.width - 32)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color(.systemBackground))
                                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                                    )
                                    
                                    // Answer Buttons
                                    VStack(spacing: 16) {
                                        ForEach(viewModel.shuffledTranslations, id: \.self) { translation in
                                            Button(action: {
                                                Task {
                                                    await viewModel.checkAnswer(translation)
                                                }
                                            }) {
                                                HStack {
                                                    Text(translation)
                                                        .font(.headline)
                                                        .foregroundColor(.white)
                                                    Spacer()
                                                    if let selected = viewModel.selectedTranslation,
                                                       selected == translation {
                                                        Image(systemName: translation == quiz.trueTranslation ? "checkmark.circle.fill" : "xmark.circle.fill")
                                                            .font(.title2)
                                                    }
                                                }
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(viewModel.getButtonColor(for: translation))
                                                .cornerRadius(12)
                                                .shadow(color: viewModel.getButtonColor(for: translation).opacity(0.3), radius: 5, x: 0, y: 2)
                                            }
                                            .disabled(viewModel.isButtonDisabled(for: translation))
                                            .animation(.easeInOut, value: viewModel.selectedTranslation)
                                        }
                                    }
                                    .frame(width: geometry.size.width - 32)
                                }
                                .padding(.top, 24)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 24)
                    }
                    .background(Color(.systemGroupedBackground))
                    
                    if viewModel.showNextWord {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 4)
                                    .frame(width: 60, height: 60)
                                
                                Circle()
                                    .trim(from: 0, to: CGFloat(viewModel.timeRemaining) / 3.0)
                                    .stroke(Color.white, lineWidth: 4)
                                    .frame(width: 60, height: 60)
                                    .rotationEffect(.degrees(-90))
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Text("\(viewModel.timeRemaining)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.green)
                                .shadow(color: Color.green.opacity(0.3), radius: 10, x: 0, y: 5)
                        )
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.showNextWord)
                    }
                }
            }
            .navigationTitle("Квиз")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.fetchQuizWord()
            }
        }
    }
}

#Preview {
    QuizView(selectedTabIndex: .constant(0))
} 