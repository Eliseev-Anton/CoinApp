//
//  CoinDetailViewModel.swift
//  CoinApp
//
//  ViewModel для экрана детальной информации о криптовалюте.
//  Загружает расширенные данные о монете из API.
//

import Foundation
import Observation

/// ViewModel для детального экрана монеты
@Observable
final class CoinDetailViewModel {

    // MARK: - Properties

    /// Состояние загрузки детальной информации
    private(set) var state: ViewState<CoinDetail> = .idle

    /// Идентификатор монеты
    let coinID: String

    /// Базовая информация о монете (из списка)
    let coin: Coin

    // MARK: - Dependencies

    private let coinService: CoinServiceProtocol

    // MARK: - Initialization

    /// Инициализация с базовой информацией о монете
    /// - Parameters:
    ///   - coin: Монета из списка
    ///   - coinService: Сервис для загрузки данных
    init(coin: Coin, coinService: CoinServiceProtocol = CoinService.shared) {
        self.coin = coin
        self.coinID = coin.id
        self.coinService = coinService
    }

    // MARK: - Public Methods

    /// Загрузить детальную информацию
    @MainActor
    func loadDetail() async {
        state = .loading

        do {
            let detail = try await coinService.fetchCoinDetail(id: coinID)
            state = .loaded(detail)
        } catch {
            state = .error(error)
            #if DEBUG
            print("Failed to load coin detail: \(error)")
            #endif
        }
    }

    /// Обновить данные
    @MainActor
    func refresh() async {
        await loadDetail()
    }
}

// MARK: - Computed Properties

extension CoinDetailViewModel {
    /// Форматированная цена
    var formattedPrice: String {
        "$\(coin.currentPrice.formatted(.number.precision(.fractionLength(2...6))))"
    }

    /// Изменение за 24 часа
    var priceChange24h: String {
        guard let change = coin.priceChangePercentage24h else { return "N/A" }
        let sign = change >= 0 ? "+" : ""
        return "\(sign)\(change.formatted(.number.precision(.fractionLength(2))))%"
    }

    /// Цвет изменения (зеленый или красный)
    var isPriceUp: Bool {
        (coin.priceChangePercentage24h ?? 0) >= 0
    }

    /// Форматированная рыночная капитализация
    var formattedMarketCap: String {
        guard let marketCap = coin.marketCap else { return "N/A" }
        return formatLargeNumber(marketCap)
    }

    /// Форматированный объем торгов
    var formattedVolume: String {
        guard let volume = coin.totalVolume else { return "N/A" }
        return formatLargeNumber(volume)
    }

    // MARK: - Private Helpers

    /// Форматирование больших чисел (1B, 1M, 1K)
    private func formatLargeNumber(_ number: Double) -> String {
        let trillion = 1_000_000_000_000.0
        let billion = 1_000_000_000.0
        let million = 1_000_000.0
        let thousand = 1_000.0

        switch number {
        case trillion...:
            return "$\((number / trillion).formatted(.number.precision(.fractionLength(2))))T"
        case billion...:
            return "$\((number / billion).formatted(.number.precision(.fractionLength(2))))B"
        case million...:
            return "$\((number / million).formatted(.number.precision(.fractionLength(2))))M"
        case thousand...:
            return "$\((number / thousand).formatted(.number.precision(.fractionLength(2))))K"
        default:
            return "$\(number.formatted(.number.precision(.fractionLength(2))))"
        }
    }
}
