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

struct WordCard: View {
    let word: WordResponseRemote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(word.word)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(word.translation)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            HStack(spacing: 20) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("\(word.success)")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                    Text("\(word.failed)")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct FilteredWordsList: View {
    let words: [WordResponseRemote]
    let searchText: String
    let isLoading: Bool
    let currentPage: Int
    let totalPages: Int
    let onPreviousPage: () -> Void
    let onNextPage: () -> Void
    
    var filteredWords: [WordResponseRemote] {
        if searchText.isEmpty {
            return words
        }
        return words.filter { word in
            word.word.localizedCaseInsensitiveContains(searchText) ||
            word.translation.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredWords, id: \.id) { word in
                        NavigationLink(destination: WordDetailView(word: word)) {
                            WordCard(word: word)
                        }
                    }
                    .padding(.horizontal)
                    
                    if isLoading {
                        ProgressView()
                            .padding()
                    }
                }
                .padding(.vertical)
            }
            
            HStack {
                Button(action: onPreviousPage) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Назад")
                    }
                    .foregroundColor(currentPage > 1 ? .blue : .gray)
                }
                .disabled(currentPage == 1)
                
                Spacer()
                
                Text("Страница \(currentPage) из \(totalPages)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: onNextPage) {
                    HStack {
                        Text("Вперед")
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(currentPage < totalPages ? .blue : .gray)
                }
                .disabled(currentPage == totalPages)
            }
            .padding()
            .background(Color(.systemGray6))
        }
    }
}

struct DictionaryView: View {
    @StateObject private var viewModel = DictionaryViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Menu {
                        Button(action: { viewModel.toggleSorting(param: "word") }) {
                            HStack {
                                Text("По слову")
                                if viewModel.sortingParam == "word" {
                                    Image(systemName: viewModel.sortingDirection == "asc" ? "arrow.up" : "arrow.down")
                                }
                            }
                        }
                        
                        Button(action: { viewModel.toggleSorting(param: "success") }) {
                            HStack {
                                Text("По успешным ответам")
                                if viewModel.sortingParam == "success" {
                                    Image(systemName: viewModel.sortingDirection == "asc" ? "arrow.up" : "arrow.down")
                                }
                            }
                        }
                        
                        Button(action: { viewModel.toggleSorting(param: "failed") }) {
                            HStack {
                                Text("По ошибкам")
                                if viewModel.sortingParam == "failed" {
                                    Image(systemName: viewModel.sortingDirection == "asc" ? "arrow.up" : "arrow.down")
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text("Сортировка")
                            Image(systemName: "chevron.down")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                if viewModel.isLoading && viewModel.words.isEmpty {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    FilteredWordsList(
                        words: viewModel.words,
                        searchText: searchText,
                        isLoading: viewModel.isLoading,
                        currentPage: viewModel.currentPage,
                        totalPages: viewModel.totalPages,
                        onPreviousPage: viewModel.previousPage,
                        onNextPage: viewModel.nextPage
                    )
                }
            }
            .navigationTitle("Словарь")
            .searchable(text: $searchText, prompt: "Поиск слов")
            .refreshable {
                viewModel.refresh()
            }
            .alert("Ошибка", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK", role: .cancel) {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
        .onAppear {
            viewModel.loadWords()
        }
    }
}

#Preview {
    DictionaryView()
} 
