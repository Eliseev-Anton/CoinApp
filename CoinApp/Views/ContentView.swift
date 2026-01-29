//
//  ContentView.swift
//  CoinApp
//
//  Корневой View приложения.
//  Содержит TabView для навигации между основными разделами.
//

import SwiftUI

/// Главный View приложения с табами
struct ContentView: View {

    // MARK: - Properties

    /// Выбранный таб
    @State private var selectedTab: Tab = .coins

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTab) {
            // Таб со списком монет
            CoinsListView()
                .tabItem {
                    Label("Монеты", systemImage: "bitcoinsign.circle.fill")
                }
                .tag(Tab.coins)

            // Таб с избранными
            FavoritesView()
                .tabItem {
                    Label("Избранное", systemImage: "star.fill")
                }
                .tag(Tab.favorites)

            // Таб с настройками
            SettingsView()
                .tabItem {
                    Label("Настройки", systemImage: "gearshape.fill")
                }
                .tag(Tab.settings)
        }
        // iOS 17+: типобезопасный tint
        .tint(.orange)
    }
}

// MARK: - Tab Enum

/// Перечисление табов приложения
enum Tab: Hashable {
    case coins
    case favorites
    case settings
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(CoreDataService.preview)
}
