import SwiftUI

struct SaveWordView: View {
    @StateObject private var viewModel = SaveWordViewModel()
    @FocusState private var focusedField: Field?
    
    enum Field {
        case word, translation
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 24) {
                        // Word Input Card
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
                            
                            TextField("Введите слово", text: $viewModel.word)
                                .textFieldStyle(ModernTextFieldStyle())
                                .focused($focusedField, equals: .word)
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
                                Image(systemName: "globe")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                                Text("Перевод")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            TextField("Введите перевод", text: $viewModel.translation)
                                .textFieldStyle(ModernTextFieldStyle())
                                .focused($focusedField, equals: .translation)
                        }
                        .padding()
                        .frame(width: geometry.size.width - 32)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        )
                        
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundColor(.red)
                                .padding(.top, 8)
                        }
                        
                        // Save Button
                        Button(action: {
                            viewModel.saveWord()
                        }) {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Сохранить")
                                        .font(.headline)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.isFormValid ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 2)
                        }
                        .disabled(!viewModel.isFormValid || viewModel.isLoading)
                        .frame(width: geometry.size.width - 32)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 24)
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle("Добавить слово")
            .navigationBarTitleDisplayMode(.inline)
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
