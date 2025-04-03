import SwiftUI

struct SaveWordView: View {
    @State private var word: String = ""
    @State private var translation: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 20) {
                TextField("Введите слово", text: $word)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                TextField("Введите перевод", text: $translation)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: {
                    // Здесь будет логика сохранения
                }) {
                    Text("Сохранить")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .frame(maxWidth: 300)
            
            Spacer()
        }
    }
}

#Preview {
    SaveWordView()
} 