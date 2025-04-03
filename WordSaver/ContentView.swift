//
//  ContentView.swift
//  WordSaver
//
//  Created by d.kheyfets on 02.04.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var showAuth = true
    
    var body: some View {
        TabView {
            SaveWordView()
                .tabItem {
                    Label("Ввод", systemImage: "square.and.pencil")
                }
            
            WordsListView()
                .tabItem {
                    Label("Слова", systemImage: "list.bullet")
                }
            
            QuizView()
                .tabItem {
                    Label("Квиз", systemImage: "questionmark.circle")
                }
            
            DictionaryView()
                .tabItem {
                    Label("Словарь", systemImage: "text.book.closed")
                }
        }
        .sheet(isPresented: $showAuth) {
            AuthSplashView()
        }
    }
}

#Preview {
    ContentView()
}
