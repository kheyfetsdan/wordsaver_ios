import SwiftUI

struct SaveWordView: View {
    @StateObject private var viewModel = SaveWordViewModel()
    
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
                    }
                    
                    // Карточка ввода перевода
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Перевод")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        TextField("Введите перевод", text: $viewModel.translation)
                            .textFieldStyle(ModernTextFieldStyle())
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
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Сохранить")
                                .font(.headline)
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
                Button("OK", role: .cancel) {}
            }
        }
    }
}

struct ModernTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }
}

#Preview {
    SaveWordView()
} 