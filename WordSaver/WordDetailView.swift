import SwiftUI

struct WordDetailView: View {
    let word: WordResponseRemote
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Слово")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text(word.word)
                    .font(.title)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Перевод")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text(word.translation)
                    .font(.title2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Детали слова")
    }
}

