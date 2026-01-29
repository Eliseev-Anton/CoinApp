//
//  EmptyStateView.swift
//  CoinApp
//
//  Переиспользуемый компонент для пустого состояния.
//  Используется когда нет данных для отображения.
//

import SwiftUI

/// View для отображения пустого состояния
struct EmptyStateView: View {

    // MARK: - Properties

    /// Заголовок
    let title: String

    /// Описание
    let message: String

    /// SF Symbol для иконки
    let systemImage: String

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            // Иконка
            Image(systemName: systemImage)
                .font(.system(size: 60))
                .foregroundStyle(.secondary.opacity(0.5))

            // Заголовок
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)

            // Описание
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Preview

#Preview {
    EmptyStateView(
        title: "Нет избранных",
        message: "Добавьте монеты в избранное, нажав на звездочку",
        systemImage: "star"
    )
}
