import SwiftUI

struct RandomWordView: View {
    @StateObject private var viewModel = RandomWordViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 30) {
                    // Слово для перевода
                    if let word = viewModel.currentWord {
                        Text(word.word)
                            .font(.system(size: 32, weight: .bold))
                            .padding(.top, 40)
                        
                        if viewModel.showTranslation {
                            Text(word.translation)
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                        }
                    } else {
                        Text("Wordsaver")
                            .font(.system(size: 32, weight: .bold))
                            .padding(.top, 40)
                    }
                    
                    // Поле ввода перевода
                    TextField("Введите перевод", text: $viewModel.translation)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    // Кнопки
                    VStack(spacing: 20) {
                        HStack(spacing: 20) {
                            Button(action: {
                                Task {
                                    await viewModel.checkAnswer()
                                }
                            }) {
                                Text("Проверить ответ")
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(viewModel.translation.isEmpty ? Color.gray : Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .disabled(viewModel.translation.isEmpty)
                            
                            Button(action: {
                                Task {
                                    await viewModel.fetchRandomWord()
                                }
                            }) {
                                Text("Случайное слово")
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        
                        HStack(spacing: 20) {
                            Button(action: {
                                viewModel.requestShowTranslation()
                            }) {
                                Text("Показать перевод")
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            
                            Button(action: {
                                viewModel.requestSkipWord()
                            }) {
                                Text("Пропустить")
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(Color(.systemGray5))
                                    .foregroundColor(.primary)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                
                if viewModel.showNotification {
                    VStack {
                        if let isCorrect = viewModel.isAnswerCorrect {
                            Text(isCorrect ? "Правильно! ✅" : "Неправильно! ❌")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(isCorrect ? Color.green : Color.red)
                                .cornerRadius(10)
                        }
                    }
                    .transition(.opacity)
                    .animation(.easeInOut, value: viewModel.showNotification)
                }
            }
            .navigationTitle("Слова")
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .alert("Ошибка", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .confirmationDialog(
                "Показать перевод?",
                isPresented: $viewModel.showConfirmationDialog,
                titleVisibility: .visible
            ) {
                Button("Да") {
                    Task {
                        await viewModel.showTranslationAndSkip()
                    }
                }
                Button("Отмена", role: .cancel) {}
            } message: {
                Text("После показа перевода будет загружено новое слово")
            }
            .confirmationDialog(
                "Пропустить слово?",
                isPresented: $viewModel.showSkipConfirmationDialog,
                titleVisibility: .visible
            ) {
                Button("Да") {
                    Task {
                        await viewModel.skipWord()
                    }
                }
                Button("Отмена", role: .cancel) {}
            } message: {
                Text("Текущее слово будет засчитано как неправильно отвеченное")
            }
            .task {
                await viewModel.fetchRandomWord()
            }
        }
    }
}

#Preview {
    RandomWordView()
} 
