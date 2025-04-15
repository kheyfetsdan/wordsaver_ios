//
//  ContentView.swift
//  WordSaver
//
//  Created by d.kheyfets on 02.04.2025.
//

import SwiftUI

struct SelectedTabKey: EnvironmentKey {
    static let defaultValue: Binding<Int> = .constant(0)
}

extension EnvironmentValues {
    var selectedTab: Binding<Int> {
        get { self[SelectedTabKey.self] }
        set { self[SelectedTabKey.self] = newValue }
    }
}

struct ContentView: View {
    @StateObject private var authService = AuthService.shared
    @State private var selectedTabIndex = 0
    
    var body: some View {
        if authService.isAuthenticated {
            TabView(selection: $selectedTabIndex) {
                SaveWordView()
                    .tabItem {
                        Label("Ввод", systemImage: "square.and.pencil")
                    }
                    .tag(0)
                
                RandomWordView()
                    .tabItem {
                        Label("Слова", systemImage: "list.bullet")
                    }
                    .tag(1)
                
                QuizView(selectedTabIndex: $selectedTabIndex)
                    .tabItem {
                        Label("Квиз", systemImage: "questionmark.circle")
                    }
                    .tag(2)
                
                DictionaryView()
                    .tabItem {
                        Label("Словарь", systemImage: "text.book.closed")
                    }
                    .tag(3)
                
                ProfileView()
                    .tabItem {
                        Label("Профиль", systemImage: "person")
                    }
                    .tag(4)
            }
        } else {
            AuthSplashView()
        }
    }
}

#Preview {
    ContentView()
}
