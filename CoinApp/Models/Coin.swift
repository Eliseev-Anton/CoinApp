//
//  Coin.swift
//  CoinApp
//
//  Модель криптовалюты, получаемая из CoinGecko API.
//  Соответствует JSON структуре эндпоинта /coins/markets
//

import Foundation

/// Основная модель криптовалюты для отображения в списке
/// Decodable - для парсинга JSON
/// Identifiable - для использования в SwiftUI списках
/// Hashable - для сравнения и использования в Set
struct Coin: Decodable, Identifiable, Hashable {

    // MARK: - Properties

    /// Уникальный идентификатор монеты (например: "bitcoin")
    let id: String

    /// Символ монеты (например: "btc")
    let symbol: String

    /// Полное название (например: "Bitcoin")
    let name: String

    /// URL изображения монеты
    let image: String

    /// Текущая цена в выбранной валюте
    let currentPrice: Double

    /// Рыночная капитализация
    let marketCap: Double?

    /// Позиция по рыночной капитализации
    let marketCapRank: Int?

    /// Полностью разбавленная оценка
    let fullyDilutedValuation: Double?

    /// Общий объем торгов за 24 часа
    let totalVolume: Double?

    /// Максимальная цена за 24 часа
    let high24h: Double?

    /// Минимальная цена за 24 часа
    let low24h: Double?

    /// Изменение цены за 24 часа в абсолютных значениях
    let priceChange24h: Double?

    /// Изменение цены за 24 часа в процентах
    let priceChangePercentage24h: Double?

    /// Изменение рыночной капитализации за 24 часа
    let marketCapChange24h: Double?

    /// Изменение рыночной капитализации за 24 часа в процентах
    let marketCapChangePercentage24h: Double?

    /// Количество монет в обращении
    let circulatingSupply: Double?

    /// Максимальное количество монет
    let totalSupply: Double?

    /// Абсолютный максимум количества монет
    let maxSupply: Double?

    /// Исторический максимум цены
    let ath: Double?

    /// Изменение от исторического максимума в процентах
    let athChangePercentage: Double?

    /// Дата достижения исторического максимума
    let athDate: String?

    /// Исторический минимум цены
    let atl: Double?

    /// Изменение от исторического минимума в процентах
    let atlChangePercentage: Double?

    /// Дата достижения исторического минимума
    let atlDate: String?

    /// Дата последнего обновления данных
    let lastUpdated: String?

    /// История цен за последние 7 дней (для спарклайна)
    let sparklineIn7d: SparklineData?

    // MARK: - CodingKeys

    /// Маппинг JSON ключей на свойства модели
    /// CoinGecko использует snake_case, Swift использует camelCase
    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case fullyDilutedValuation = "fully_diluted_valuation"
        case totalVolume = "total_volume"
        case high24h = "high_24h"
        case low24h = "low_24h"
        case priceChange24h = "price_change_24h"
        case priceChangePercentage24h = "price_change_percentage_24h"
        case marketCapChange24h = "market_cap_change_24h"
        case marketCapChangePercentage24h = "market_cap_change_percentage_24h"
        case circulatingSupply = "circulating_supply"
        case totalSupply = "total_supply"
        case maxSupply = "max_supply"
        case ath
        case athChangePercentage = "ath_change_percentage"
        case athDate = "ath_date"
        case atl
        case atlChangePercentage = "atl_change_percentage"
        case atlDate = "atl_date"
        case lastUpdated = "last_updated"
        case sparklineIn7d = "sparkline_in_7d"
    }
}

// MARK: - SparklineData

/// Данные для отображения мини-графика цены за 7 дней
struct SparklineData: Decodable, Hashable {
    /// Массив цен за последние 7 дней
    let price: [Double]?
}

// MARK: - Preview Helper

extension Coin {
    /// Пример монеты для использования в Preview и тестах
    static var example: Coin {
        Coin(
            id: "bitcoin",
            symbol: "btc",
            name: "Bitcoin",
            image: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png",
            currentPrice: 45000.0,
            marketCap: 850000000000,
            marketCapRank: 1,
            fullyDilutedValuation: 950000000000,
            totalVolume: 25000000000,
            high24h: 46000,
            low24h: 44000,
            priceChange24h: 1500,
            priceChangePercentage24h: 3.45,
            marketCapChange24h: 25000000000,
            marketCapChangePercentage24h: 3.0,
            circulatingSupply: 19000000,
            totalSupply: 21000000,
            maxSupply: 21000000,
            ath: 69000,
            athChangePercentage: -35,
            athDate: "2021-11-10T14:24:11.849Z",
            atl: 67.81,
            atlChangePercentage: 66000,
            atlDate: "2013-07-06T00:00:00.000Z",
            lastUpdated: "2024-01-15T12:00:00.000Z",
            sparklineIn7d: SparklineData(price: [44000, 44500, 45000, 44800, 45200, 45500, 45000])
        )
    }
}
