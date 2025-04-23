import SwiftUI
import Foundation

struct WordDetailView: View {
    @State private var word: WordResponseRemote
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false
    @State private var editedWord: String
    @State private var editedTranslation: String
    @State private var showingDeleteAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var isSaving = false
    
    @StateObject private var viewModel = WordDetailViewModel()
    
    init(word: WordResponseRemote) {
        _word = State(initialValue: word)
        _editedWord = State(initialValue: word.word)
        _editedTranslation = State(initialValue: word.translation)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 24) {
                    // Word Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "note.text")
                                .foregroundColor(.blue)
                                .font(.title2)
                            Text("Слово")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if isEditing {
                            TextField("Введите слово", text: $editedWord)
                                .textFieldStyle(ModernTextFieldStyle())
                        } else {
                            Text(word.word)
                                .font(.title)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                    .frame(width: geometry.size.width - 32)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    
                    // Translation Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.blue)
                                .font(.title2)
                            Text("Перевод")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if isEditing {
                            TextField("Введите перевод", text: $editedTranslation)
                                .textFieldStyle(ModernTextFieldStyle())
                        } else {
                            Text(word.translation)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                    .frame(width: geometry.size.width - 32)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    
                    // Stats Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            Text("Статистика")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 20) {
                            StatView(title: "Правильно", value: word.success, icon: "checkmark.circle.fill", color: .green)
                            StatView(title: "Ошибок", value: word.failed, icon: "xmark.circle.fill", color: .red)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .frame(width: geometry.size.width - 32)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    
                    if isEditing {
                        Button(action: saveChanges) {
                            HStack {
                                if isSaving {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "checkmark")
                                    Text("Сохранить")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 2)
                        }
                        .disabled(isSaving)
                        .frame(width: geometry.size.width - 32)
                    }
                    
                    Button(action: { showingDeleteAlert = true }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Удалить слово")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(12)
                    }
                    .frame(width: geometry.size.width - 32)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
            }
            .background(Color(.systemGroupedBackground))
        }
        .navigationTitle("Детали слова")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isEditing.toggle() }) {
                    Text(isEditing ? "Отмена" : "Редактировать")
                        .foregroundColor(.blue)
                }
            }
        }
        .alert("Удалить слово?", isPresented: $showingDeleteAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Удалить", role: .destructive) {
                deleteWord()
            }
        } message: {
            Text("Вы уверены, что хотите удалить это слово?")
        }
        .alert("Ошибка", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func saveChanges() {
        isSaving = true
        Task {
            do {
                let request = SaveWordIdRequest(id: word.id, word: editedWord, translation: editedTranslation)
                try await viewModel.updateWord(request: request)
                await MainActor.run {
                    word = WordResponseRemote(
                        id: word.id,
                        word: editedWord,
                        translation: editedTranslation,
                        success: word.success,
                        failed: word.failed,
                        addedAt: word.addedAt
                    )
                    isEditing = false
                    isSaving = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Не удалось обновить слово: \(error.localizedDescription)"
                    showingErrorAlert = true
                    isSaving = false
                }
            }
        }
    }
    
    private func deleteWord() {
        Task {
            do {
                try await viewModel.deleteWord(wordId: word.id)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Не удалось удалить слово"
                    showingErrorAlert = true
                }
            }
        }
    }
}

struct StatView: View {
    let title: String
    let value: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Text("\(value)")
                .font(.title2)
                .fontWeight(.bold)
        }
    }
}

class WordDetailViewModel: ObservableObject {
    private let networkService = DefaultApiService()
    private let authService = AuthService.shared
    
    func updateWord(request: SaveWordIdRequest) async throws {
        let token = try authService.getToken()
        try await networkService.updateWord(token: token, request: request)
    }
    
    func deleteWord(wordId: Int) async throws {
        let token = try authService.getToken()
        try await networkService.deleteWord(token: token, wordId: wordId)
    }
}

