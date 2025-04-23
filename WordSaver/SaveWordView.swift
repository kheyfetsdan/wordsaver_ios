import SwiftUI

struct SaveWordView: View {
    @StateObject private var viewModel = SaveWordViewModel()
    @FocusState private var focusedField: Field?
    
    enum Field {
        case word, translation
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()
                
                VStack(spacing: 20) {
                    // Карточка ввода слова
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Слово")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        TextField("Введите слово", text: $viewModel.word)
                            .textFieldStyle(ModernTextFieldStyle())
                            .focused($focusedField, equals: .word)
                    }
                    
                    // Карточка ввода перевода
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Перевод")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        TextField("Введите перевод", text: $viewModel.translation)
                            .textFieldStyle(ModernTextFieldStyle())
                            .focused($focusedField, equals: .translation)
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .padding(.top, 8)
                    }
                    
                    // Кнопка сохранения
                    Button(action: {
                        viewModel.saveWord()
                    }) {
                        ZStack {
                            Color.clear
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Сохранить")
                                    .font(.headline)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(viewModel.isFormValid ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .navigationTitle("Добавить слово")
            .alert("Слово успешно сохранено", isPresented: $viewModel.isWordSaved) {
                Button("OK", role: .cancel) {
                    viewModel.word = ""
                    viewModel.translation = ""
                }
            }
            .onChange(of: viewModel.isWordSaved) { oldValue, newValue in
                if !newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        focusedField = nil
                    }
                }
            }
        }
    }
}

#Preview {
    SaveWordView()
} 
