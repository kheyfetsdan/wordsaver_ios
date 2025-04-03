import SwiftUI

struct QuizView: View {
    @State private var selectedAnswer: Int? = nil
    @State private var isAnswerCorrect: Bool? = nil
    
    let word = "River"
    let answers = ["Слон", "Яма", "Река", "Самолет"]
    let correctAnswerIndex = 2
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Слово для перевода
                Text(word)
                    .font(.system(size: 32, weight: .bold))
                    .padding(.top, 40)
                
                // Варианты ответов
                VStack(spacing: 16) {
                    ForEach(0..<answers.count, id: \.self) { index in
                        Button(action: {
                            selectedAnswer = index
                            isAnswerCorrect = (index == correctAnswerIndex)
                        }) {
                            Text(answers[index])
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(backgroundColor(for: index))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(selectedAnswer != nil)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Квиз")
        }
    }
    
    private func backgroundColor(for index: Int) -> Color {
        if selectedAnswer == nil {
            return .blue
        } else if index == selectedAnswer {
            return isAnswerCorrect == true ? .green : .red
        } else if index == correctAnswerIndex && isAnswerCorrect == false {
            return .green
        }
        return .blue.opacity(0.5)
    }
}

#Preview {
    QuizView()
} 