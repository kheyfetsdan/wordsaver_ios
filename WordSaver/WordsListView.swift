import SwiftUI

struct WordsListView: View {
    @State private var translation: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Слово для перевода
                Text("Wordsaver")
                    .font(.system(size: 32, weight: .bold))
                    .padding(.top, 40)
                
                // Поле ввода перевода
                TextField("Введите перевод", text: $translation)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                // Кнопки
                VStack(spacing: 20) {
                    HStack(spacing: 20) {
                        Button(action: {
                            // Здесь будет логика проверки
                        }) {
                            Text("Проверить ответ")
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(translation.isEmpty ? Color.gray : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(translation.isEmpty)
                        
                        Button(action: {
                            // Здесь будет логика случайного слова
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
                            // Здесь будет логика показа перевода
                        }) {
                            Text("Показать перевод")
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            // Здесь будет логика пропуска
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
            .navigationTitle("Слова")
        }
    }
}

#Preview {
    WordsListView()
} 