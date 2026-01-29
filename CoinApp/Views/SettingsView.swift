//
//  SettingsView.swift
//  CoinApp
//
//  Экран настроек приложения.
//  Содержит информацию о приложении и опции настройки.
//

import SwiftUI

/// View настроек приложения
struct SettingsView: View {

    // MARK: - Properties

    /// Выбранная тема оформления
    @AppStorage("appearance") private var appearance: Appearance = .system

    /// Валюта по умолчанию
    @AppStorage("defaultCurrency") private var defaultCurrency: String = "usd"

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List {
                // Секция оформления
                Section("Оформление") {
                    Picker("Тема", selection: $appearance) {
                        ForEach(Appearance.allCases) { option in
                            Text(option.displayName)
                                .tag(option)
                        }
                    }
                }

                // Секция валюты
                Section("Валюта") {
                    Picker("Валюта по умолчанию", selection: $defaultCurrency) {
                        ForEach(Currency.allCases) { currency in
                            Text(currency.displayName)
                                .tag(currency.rawValue)
                        }
                    }
                }

                // Информация о приложении
                Section("О приложении") {
                    HStack {
                        Text("Версия")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    Link(destination: URL(string: "https://www.coingecko.com")!) {
                        HStack {
                            Text("Данные от CoinGecko")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                        }
                    }
                }

                // Информация о разработке
                Section("Разработка") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("CoinApp")
                            .font(.headline)
                        Text("Pet-проект для изучения:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        VStack(alignment: .leading, spacing: 4) {
                            bulletPoint("SwiftUI + MVVM")
                            bulletPoint("@Observable (iOS 17)")
                            bulletPoint("Async/Await")
                            bulletPoint("CoreData")
                            bulletPoint("Charts Framework")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Настройки")
        }
        // Применяем выбранную тему
        .preferredColorScheme(appearance.colorScheme)
    }

    // MARK: - Helpers

    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            Text(text)
        }
    }
}

// MARK: - Appearance Enum

/// Варианты оформления приложения
enum Appearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return "Системная"
        case .light: return "Светлая"
        case .dark: return "Темная"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}
