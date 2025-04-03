import SwiftUI

struct WordDetailView: View {
    let item: DictionaryItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Карточка слова
                VStack(spacing: 16) {
                    Text(item.word)
                        .font(.system(size: 32, weight: .bold))
                    
                    Text(item.translation)
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    // Статистика
                    HStack(spacing: 40) {
                        VStack(spacing: 8) {
                            Text("\(item.stats.correct).0")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.blue)
                            Text("Правильные ответы")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(spacing: 8) {
                            Text("\(item.stats.incorrect).0")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.red)
                            Text("Неправильные ответы")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle(item.word)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Назад")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {
                            // Действие редактирования
                        }) {
                            Image(systemName: "pencil")
                        }
                        
                        Button(action: {
                            // Действие удаления
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    WordDetailView(item: DictionaryItem(
        word: "Cope",
        translation: "Справляться",
        stats: WordStatistics(correct: 200, incorrect: 0)
    ))
} 