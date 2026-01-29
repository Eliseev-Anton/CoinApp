//
//  ErrorView.swift
//  CoinApp
//
//  Переиспользуемый компонент для отображения ошибок.
//  Позволяет повторить действие.
//

import SwiftUI

/// View для отображения ошибки с возможностью повтора
struct ErrorView: View {

    // MARK: - Properties

    /// Ошибка для отображения
    let error: Error

    /// Действие при нажатии "Повторить"
    let retryAction: () -> Void

    // MARK: - Body

    var body: some View {
        VStack(spacing: 20) {
            // Иконка ошибки
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.orange)

            // Заголовок
            Text("Произошла ошибка")
                .font(.title2)
                .fontWeight(.semibold)

            // Описание ошибки
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Кнопка повтора
            Button {
                retryAction()
            } label: {
                Label("Повторить", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .clipShape(Capsule())
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Preview

#Preview {
    ErrorView(error: NetworkError.noConnection) {
        print("Retry tapped")
    }
}
