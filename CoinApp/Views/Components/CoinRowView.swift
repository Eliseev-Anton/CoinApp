//
//  CoinRowView.swift
//  CoinApp
//
//  Строка монеты для списка.
//  Отображает основную информацию: изображение, название, цену и изменение.
//

import SwiftUI

/// View строки монеты в списке
struct CoinRowView: View {

    // MARK: - Properties

    /// Монета для отображения
    let coin: Coin

    /// Флаг избранного
    let isFavorite: Bool

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            // Ранг
            rankView

            // Изображение
            coinImage

            // Название и символ
            nameSection

            Spacer()

            // Цена и изменение
            priceSection
        }
        .padding(.vertical, 4)
    }

    // MARK: - Subviews

    /// Ранг монеты
    private var rankView: some View {
        Text("\(coin.marketCapRank ?? 0)")
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(width: 24)
    }

    /// Изображение монеты
    private var coinImage: some View {
        AsyncImage(url: URL(string: coin.image)) { phase in
            switch phase {
            case .empty:
                // Плейсхолдер во время загрузки
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay {
                        ProgressView()
                            .scaleEffect(0.5)
                    }
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
            case .failure:
                // Плейсхолдер при ошибке
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay {
                        Image(systemName: "questionmark")
                            .foregroundStyle(.secondary)
                    }
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: 36, height: 36)
    }

    /// Секция с названием
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Text(coin.name)
                    .font(.headline)
                    .lineLimit(1)

                // Индикатор избранного
                if isFavorite {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }

            Text(coin.symbol.uppercased())
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    /// Секция с ценой
    private var priceSection: some View {
        VStack(alignment: .trailing, spacing: 2) {
            // Текущая цена
            Text(formattedPrice)
                .font(.subheadline)
                .fontWeight(.semibold)

            // Изменение за 24 часа
            Text(formattedChange)
                .font(.caption)
                .foregroundStyle(changeColor)
        }
    }

    // MARK: - Computed Properties

    /// Форматированная цена
    private var formattedPrice: String {
        let price = coin.currentPrice

        // Для маленьких цен показываем больше знаков
        if price < 1 {
            return "$\(price.formatted(.number.precision(.significantDigits(4))))"
        } else {
            return "$\(price.formatted(.number.precision(.fractionLength(2))))"
        }
    }

    /// Форматированное изменение
    private var formattedChange: String {
        guard let change = coin.priceChangePercentage24h else {
            return "N/A"
        }

        let sign = change >= 0 ? "+" : ""
        return "\(sign)\(change.formatted(.number.precision(.fractionLength(2))))%"
    }

    /// Цвет изменения
    private var changeColor: Color {
        guard let change = coin.priceChangePercentage24h else {
            return .secondary
        }
        return change >= 0 ? .green : .red
    }
}

// MARK: - Preview

#Preview {
    List {
        CoinRowView(coin: .example, isFavorite: true)
        CoinRowView(coin: .example, isFavorite: false)
    }
    .listStyle(.plain)
}
