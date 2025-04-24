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
        NavigationLink(destination: WordDetailView(word: word)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(word.word)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text(word.translation)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.system(size: 14, weight: .semibold))
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
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FilteredWordsList: View {
    let words: [WordResponseRemote]
    let searchText: String
    let isLoading: Bool
    let currentPage: Int
    let totalPages: Int
    let onLoadMore: () -> Void
    
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
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredWords, id: \.id) { word in
                    WordCard(word: word)
                        .padding(.horizontal)
                }
                
                if isLoading {
                    ProgressView()
                        .padding()
                } else if currentPage < totalPages {
                    Color.clear
                        .frame(height: 1)
                        .onAppear {
                            onLoadMore()
                        }
                }
            }
            .padding(.vertical)
        }
    }
}

struct DictionaryView: View {
    @StateObject private var viewModel = DictionaryViewModel()
    @State private var searchText = ""
    @State private var showingSortMenu = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Поиск...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Sort Button
                Button(action: {
                    showingSortMenu = true
                }) {
                    HStack {
                        Image(systemName: "arrow.up.arrow.down")
                        Text(getSortTitle())
                        if viewModel.sortingParam != "word" {
                            Image(systemName: viewModel.sortingDirection == "asc" ? "arrow.up" : "arrow.down")
                        }
                    }
                    .foregroundColor(.blue)
                    .padding(.vertical, 8)
                }
                .confirmationDialog("Сортировка", isPresented: $showingSortMenu) {
                    Button("По слову") {
                        viewModel.toggleSorting(param: "word")
                    }
                    Button("По успешным ответам") {
                        viewModel.toggleSorting(param: "success")
                    }
                    Button("По ошибкам") {
                        viewModel.toggleSorting(param: "failed")
                    }
                }
                
                // Words List
                FilteredWordsList(
                    words: viewModel.words,
                    searchText: searchText,
                    isLoading: viewModel.isLoading,
                    currentPage: viewModel.currentPage,
                    totalPages: viewModel.totalPages,
                    onLoadMore: viewModel.loadMoreWords
                )
            }
            .navigationTitle("Словарь")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                viewModel.loadWords()
            }
            .overlay {
                if viewModel.isLoading && viewModel.words.isEmpty {
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
        }
    }
    
    private func getSortTitle() -> String {
        switch viewModel.sortingParam {
        case "word":
            return "По слову"
        case "success":
            return "По успешным ответам"
        case "failed":
            return "По ошибкам"
        default:
            return "Сортировка"
        }
    }
}

#Preview {
    DictionaryView()
} 
