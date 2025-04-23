import SwiftUI

struct RandomWordView: View {
    @StateObject private var viewModel = RandomWordViewModel()
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Word Card
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "note.text")
                                        .foregroundColor(.blue)
                                        .font(.title2)
                                    Text("Слово для перевода")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if let word = viewModel.currentWord {
                                    Text(word.word)
                                        .font(.system(size: 32, weight: .bold))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.vertical, 8)
                                    
                                    if viewModel.showTranslation {
                                        Text(word.translation)
                                            .font(.system(size: 24))
                                            .foregroundColor(.gray)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                } else {
                                    Text("Wordsaver")
                                        .font(.system(size: 32, weight: .bold))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.vertical, 8)
                                }
                            }
                            .padding()
                            .frame(width: geometry.size.width - 32)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            )
                            
                            // Translation Input Card
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.blue)
                                        .font(.title2)
                                    Text("Ваш перевод")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                TextField("Введите перевод", text: $viewModel.translation)
                                    .textFieldStyle(ModernTextFieldStyle())
                            }
                            .padding()
                            .frame(width: geometry.size.width - 32)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            )
                            
                            // Action Buttons
                            VStack(spacing: 16) {
                                Button(action: {
                                    Task {
                                        await viewModel.checkAnswer()
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text("Проверить ответ")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(viewModel.translation.isEmpty ? Color.gray : Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                    .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 2)
                                }
                                .disabled(viewModel.translation.isEmpty)
                                
                                HStack(spacing: 16) {
                                    Button(action: {
                                        Task {
                                            await viewModel.forceFetchRandomWord()
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "shuffle")
                                            Text("Случайное")
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                        .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 2)
                                    }
                                    
                                    Button(action: {
                                        viewModel.requestShowTranslation()
                                    }) {
                                        HStack {
                                            Image(systemName: "eye.fill")
                                            Text("Перевод")
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                        .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 2)
                                    }
                                }
                                
                                Button(action: {
                                    viewModel.requestSkipWord()
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.right")
                                        Text("Пропустить")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .foregroundColor(.primary)
                                    .cornerRadius(12)
                                }
                            }
                            .frame(width: geometry.size.width - 32)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 24)
                    }
                    .background(Color(.systemGroupedBackground))
                    
                    if viewModel.showNotification {
                        VStack {
                            if let isCorrect = viewModel.isAnswerCorrect {
                                HStack {
                                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .font(.title)
                                    Text(isCorrect ? "Правильно!" : "Неправильно!")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(isCorrect ? Color.green : Color.red)
                                .cornerRadius(12)
                                .shadow(color: (isCorrect ? Color.green : Color.red).opacity(0.3), radius: 5, x: 0, y: 2)
                            }
                        }
                        .transition(.opacity)
                        .animation(.easeInOut, value: viewModel.showNotification)
                    }
                }
            }
            .navigationTitle("Слова")
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
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
