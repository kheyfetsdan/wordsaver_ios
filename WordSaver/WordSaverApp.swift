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
    
    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                TabView {
                    SaveWordView()
                        .tabItem {
                            Label("Ввод", systemImage: "plus.circle")
                        }
                    RandomWordView()
                        .tabItem {
                            Label("Слова", systemImage: "text.cursor")
                        }
                    DictionaryView()
                        .tabItem {
                            Label("Словарь", systemImage: "book")
                        }
                    
                    QuizView()
                        .tabItem {
                            Label("Квиз", systemImage: "questionmark.circle")
                        }
                }
            } else {
                ContentView()
            }
        }
    }
}
