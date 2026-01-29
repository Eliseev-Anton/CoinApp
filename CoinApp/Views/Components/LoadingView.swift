//
//  LoadingView.swift
//  CoinApp
//
//  Переиспользуемый компонент для отображения состояния загрузки.
//

import SwiftUI

/// View индикатора загрузки
struct LoadingView: View {

    // MARK: - Properties

    /// Сообщение для отображения
    let message: String

    // MARK: - Initialization

    init(message: String = "Загрузка...") {
        self.message = message
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview {
    LoadingView(message: "Загрузка монет...")
}
