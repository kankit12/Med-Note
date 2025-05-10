
//  ContentView.swift
//  MedNote

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()
    @Environment(\.colorScheme) private var systemColorScheme
    
    var body: some View {
        NavigationView {
            TabView {
                HomeView()
                    .environmentObject(appState)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                
                SymptomInputView()
                    .environmentObject(appState)
                    .tabItem {
                        Label("Symptoms", systemImage: "heart.text.square.fill")
                    }
                
                IllnessEstimateView()
                    .environmentObject(appState)
                    .tabItem {
                        Label("Estimate", systemImage: "heart.text.square")
                    }
                
                SymptomHistoryView()
                    .environmentObject(appState)
                    .tabItem {
                        Label("History", systemImage: "chart.line.uptrend.xyaxis")
                    }
                
                SettingsView()
                    .environmentObject(appState)
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
            .preferredColorScheme(appState.useSystemDarkMode ? systemColorScheme : (appState.isDarkMode ? .dark : .light))
            .tint(.blue)
        }
    }
}

#Preview {
    ContentView()
}
