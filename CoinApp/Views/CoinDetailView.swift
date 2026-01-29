//
//  CoinDetailView.swift
//  CoinApp
//
//  Детальный экран криптовалюты.
//  Отображает расширенную информацию, статистику и график.
//

import SwiftUI
import Charts

/// View с детальной информацией о монете
struct CoinDetailView: View {

    // MARK: - Properties

    /// ViewModel для загрузки детальных данных
    @State private var viewModel: CoinDetailViewModel

    /// Сервис избранного
    @EnvironmentObject private var coreDataService: CoreDataService

    /// Монета для отображения
    let coin: Coin

    // MARK: - Initialization

    init(coin: Coin) {
        self.coin = coin
        self._viewModel = State(initialValue: CoinDetailViewModel(coin: coin))
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Заголовок с ценой
                headerSection

                // График цены (sparkline)
                if let sparkline = coin.sparklineIn7d?.price, !sparkline.isEmpty {
                    chartSection(data: sparkline)
                }

                // Статистика
                statisticsSection

                // Детальная информация (если загружена)
                if case .loaded(let detail) = viewModel.state {
                    detailSection(detail: detail)
                }
            }
            .padding()
        }
        .navigationTitle(coin.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                favoriteButton
            }
        }
        .task {
            await viewModel.loadDetail()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Sections

    /// Секция заголовка с ценой
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Изображение монеты
            AsyncImage(url: URL(string: coin.image)) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 80, height: 80)

            // Символ и ранг
            HStack {
                Text(coin.symbol.uppercased())
                    .font(.headline)
                    .foregroundStyle(.secondary)

                if let rank = coin.marketCapRank {
                    Text("#\(rank)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.2))
                        .clipShape(Capsule())
                }
            }

            // Текущая цена
            Text(viewModel.formattedPrice)
                .font(.system(size: 36, weight: .bold))

            // Изменение за 24 часа
            Text(viewModel.priceChange24h)
                .font(.headline)
                .foregroundStyle(viewModel.isPriceUp ? .green : .red)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    /// Секция графика
    private func chartSection(data: [Double]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("График за 7 дней")
                .font(.headline)

            // SwiftUI Charts (iOS 16+)
            Chart {
                ForEach(Array(data.enumerated()), id: \.offset) { index, price in
                    LineMark(
                        x: .value("Час", index),
                        y: .value("Цена", price)
                    )
                    .foregroundStyle(
                        (data.last ?? 0) >= (data.first ?? 0)
                            ? Color.green.gradient
                            : Color.red.gradient
                    )

                    AreaMark(
                        x: .value("Час", index),
                        y: .value("Цена", price)
                    )
                    .foregroundStyle(
                        (data.last ?? 0) >= (data.first ?? 0)
                            ? Color.green.opacity(0.1).gradient
                            : Color.red.opacity(0.1).gradient
                    )
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 200)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    /// Секция статистики
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Статистика")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatisticItem(
                    title: "Рын. капитализация",
                    value: viewModel.formattedMarketCap
                )
                StatisticItem(
                    title: "Объем 24ч",
                    value: viewModel.formattedVolume
                )
                StatisticItem(
                    title: "Максимум 24ч",
                    value: formatPrice(coin.high24h)
                )
                StatisticItem(
                    title: "Минимум 24ч",
                    value: formatPrice(coin.low24h)
                )
                StatisticItem(
                    title: "ATH",
                    value: formatPrice(coin.ath)
                )
                StatisticItem(
                    title: "ATL",
                    value: formatPrice(coin.atl)
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    /// Секция детальной информации
    private func detailSection(detail: CoinDetail) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("О монете")
                .font(.headline)

            if let description = detail.description?.localized,
               !description.isEmpty {
                // Убираем HTML теги из описания
                Text(description.replacingOccurrences(
                    of: "<[^>]+>",
                    with: "",
                    options: .regularExpression
                ))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(10)
            }

            // Ссылки
            if let links = detail.links {
                linksSection(links: links)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    /// Секция ссылок
    @ViewBuilder
    private func linksSection(links: CoinLinks) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let homepage = links.homepage?.first(where: { !$0.isEmpty }),
               let url = URL(string: homepage) {
                Link(destination: url) {
                    Label("Официальный сайт", systemImage: "globe")
                }
            }

            if let twitter = links.twitterScreenName,
               let url = URL(string: "https://twitter.com/\(twitter)") {
                Link(destination: url) {
                    Label("Twitter", systemImage: "bird")
                }
            }

            if let reddit = links.subredditUrl,
               let url = URL(string: reddit) {
                Link(destination: url) {
                    Label("Reddit", systemImage: "bubble.left.and.bubble.right")
                }
            }
        }
        .font(.subheadline)
        .tint(.orange)
    }

    /// Кнопка избранного
    private var favoriteButton: some View {
        Button {
            coreDataService.toggleFavorite(coin)
        } label: {
            Image(systemName: coreDataService.isFavorite(coinID: coin.id)
                  ? "star.fill"
                  : "star")
                .foregroundStyle(.orange)
        }
    }

    // MARK: - Helpers

    private func formatPrice(_ price: Double?) -> String {
        guard let price = price else { return "N/A" }
        return "$\(price.formatted(.number.precision(.fractionLength(2...6))))"
    }
}

// MARK: - Statistic Item

/// Компонент для отображения статистики
struct StatisticItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CoinDetailView(coin: .example)
            .environmentObject(CoreDataService.preview)
    }
}
