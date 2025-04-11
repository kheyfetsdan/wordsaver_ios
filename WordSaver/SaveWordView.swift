import SwiftUI

struct SaveWordView: View {
    @StateObject private var viewModel = SaveWordViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                VStack(spacing: 20) {
                    TextField("Введите слово", text: $viewModel.word)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    TextField("Введите перевод", text: $viewModel.translation)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .padding(.horizontal)
                    }
                    
                    Button(action: {
                        viewModel.saveWord()
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Сохранить")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(viewModel.isFormValid ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                }
                .frame(maxWidth: 300)
                
                Spacer()
            }
            .navigationTitle("Добавить слово")
            .alert("Слово успешно сохранено", isPresented: $viewModel.isWordSaved) {
                Button("OK", role: .cancel) {}
            }
        }
    }
}

#Preview {
    SaveWordView()
} 