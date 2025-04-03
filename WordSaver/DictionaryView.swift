import SwiftUI

struct WordStatistics {
    let correct: Int
    let incorrect: Int
}

struct DictionaryItem: Identifiable {
    let id = UUID()
    let word: String
    let translation: String
    let stats: WordStatistics
}

struct DictionaryView: View {
    @State private var sortType: SortType = .alphabetical
    @State private var currentPage = 1
    @State private var totalPages = 2
    @State private var selectedItem: DictionaryItem? = nil
    
    // Тестовые данные
    let items = [
        DictionaryItem(word: "Application", translation: "Приложение", stats: WordStatistics(correct: 2, incorrect: 0)),
        DictionaryItem(word: "Cope", translation: "Справляться", stats: WordStatistics(correct: 200, incorrect: 0)),
        DictionaryItem(word: "Gun", translation: "Оружие", stats: WordStatistics(correct: 7, incorrect: 1)),
        DictionaryItem(word: "Menialtasks", translation: "Черновая работа", stats: WordStatistics(correct: 2, incorrect: 1)),
        DictionaryItem(word: "Plenty", translation: "Множество", stats: WordStatistics(correct: 4, incorrect: 0))
    ]
    
    enum SortType {
        case alphabetical, correct, incorrect
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Кнопки сортировки
                HStack(spacing: 12) {
                    sortButton(title: "А-Я", type: .alphabetical)
                    sortButton(title: "✓", type: .correct)
                    sortButton(title: "✗", type: .incorrect)
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Список слов
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(items) { item in
                            wordCard(item: item)
                                .onTapGesture {
                                    selectedItem = item
                                }
                        }
                    }
                    .padding()
                }
                
                // Пагинация
                HStack {
                    Button(action: {
                        if currentPage > 1 {
                            currentPage -= 1
                        }
                    }) {
                        Text("Назад")
                            .foregroundColor(currentPage > 1 ? .blue : .gray)
                    }
                    .disabled(currentPage == 1)
                    
                    Spacer()
                    
                    Text("\(currentPage) из \(totalPages)")
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Button(action: {
                        if currentPage < totalPages {
                            currentPage += 1
                        }
                    }) {
                        Text("Вперёд")
                            .foregroundColor(currentPage < totalPages ? .blue : .gray)
                    }
                    .disabled(currentPage == totalPages)
                }
                .padding()
                .background(Color.white)
            }
            .navigationTitle("Словарь")
            .sheet(item: $selectedItem) { item in
                WordDetailView(item: item)
            }
        }
    }
    
    private func sortButton(title: String, type: SortType) -> some View {
        Button(action: {
            sortType = type
        }) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(sortType == type ? Color.white : Color.clear)
                .cornerRadius(8)
        }
    }
    
    private func wordCard(item: DictionaryItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.word)
                .font(.headline)
            Text(item.translation)
                .foregroundColor(.gray)
            
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                    Text("\(item.stats.correct)")
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "xmark")
                        .foregroundColor(.red)
                    Text("\(item.stats.incorrect)")
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    DictionaryView()
} 