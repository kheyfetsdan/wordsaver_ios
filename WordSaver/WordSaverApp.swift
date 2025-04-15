//
//  WordSaverApp.swift
//  WordSaver
//
//  Created by d.kheyfets on 02.04.2025.
//

import SwiftUI
import Alamofire

@main
struct WordSaverApp: App {
    @StateObject private var authService = AuthService.shared
    @State private var selectedTabIndex = 0
    
    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                TabView(selection: $selectedTabIndex) {
                    SaveWordView()
                        .tabItem {
                            Label("Ввод", systemImage: "plus.circle")
                        }
                        .tag(0)
                    RandomWordView()
                        .tabItem {
                            Label("Слова", systemImage: "text.cursor")
                        }
                        .tag(1)
                    DictionaryView()
                        .tabItem {
                            Label("Словарь", systemImage: "book")
                        }
                        .tag(2)
                    
                    QuizView(selectedTabIndex: $selectedTabIndex)
                        .tabItem {
                            Label("Квиз", systemImage: "questionmark.circle")
                        }
                        .tag(3)
                    
                    ProfileView()
                        .tabItem {
                            Label("Профиль", systemImage: "person")
                        }
                        .tag(4)
                }
            } else {
                ContentView()
            }
        }
    }
}
