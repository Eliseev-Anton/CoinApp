//
//  CoinDetail.swift
//  CoinApp
//
//  Детальная модель криптовалюты.
//  Содержит расширенную информацию, получаемую из эндпоинта /coins/{id}
//

import Foundation

/// Детальная информация о криптовалюте
struct CoinDetail: Decodable, Identifiable {

    // MARK: - Properties

    /// Уникальный идентификатор
    let id: String

    /// Символ монеты
    let symbol: String

    /// Название
    let name: String

    /// Описание монеты на разных языках
    let description: LocalizedDescription?

    /// Ссылки на ресурсы
    let links: CoinLinks?

    /// Изображения разных размеров
    let image: CoinImage?

    /// Рыночные данные
    let marketData: MarketData?

    /// Дата генезиса (создания) блокчейна
    let genesisDate: String?

    /// Рейтинг разработчиков
    let developerScore: Double?

    /// Рейтинг сообщества
    let communityScore: Double?

    /// Рейтинг ликвидности
    let liquidityScore: Double?

    // MARK: - CodingKeys

    enum CodingKeys: String, CodingKey {
        case id, symbol, name, description, links, image
        case marketData = "market_data"
        case genesisDate = "genesis_date"
        case developerScore = "developer_score"
        case communityScore = "community_score"
        case liquidityScore = "liquidity_score"
    }
}

// MARK: - LocalizedDescription

/// Описание монеты на разных языках
struct LocalizedDescription: Decodable {
    /// Описание на английском
    let en: String?
    /// Описание на русском
    let ru: String?

    /// Получить описание с приоритетом русского языка
    var localized: String {
        ru ?? en ?? "Описание недоступно"
    }
}

// MARK: - CoinLinks

/// Ссылки на ресурсы, связанные с монетой
struct CoinLinks: Decodable {
    /// Официальные сайты
    let homepage: [String]?
    /// Ссылки на блокчейн-эксплореры
    let blockchainSite: [String]?
    /// Twitter (X) аккаунт
    let twitterScreenName: String?
    /// Subreddit сообщества
    let subredditUrl: String?
    /// GitHub репозитории
    let reposUrl: ReposUrl?

    enum CodingKeys: String, CodingKey {
        case homepage
        case blockchainSite = "blockchain_site"
        case twitterScreenName = "twitter_screen_name"
        case subredditUrl = "subreddit_url"
        case reposUrl = "repos_url"
    }
}

/// Ссылки на репозитории
struct ReposUrl: Decodable {
    let github: [String]?
}

// MARK: - CoinImage

/// Изображения монеты разных размеров
struct CoinImage: Decodable {
    let thumb: String?
    let small: String?
    let large: String?
}

// MARK: - MarketData

/// Рыночные данные криптовалюты
struct MarketData: Decodable {
    /// Текущие цены в разных валютах
    let currentPrice: [String: Double]?

    /// Исторический максимум в разных валютах
    let ath: [String: Double]?

    /// Изменение от ATH в процентах
    let athChangePercentage: [String: Double]?

    /// Исторический минимум в разных валютах
    let atl: [String: Double]?

    /// Рыночная капитализация в разных валютах
    let marketCap: [String: Double]?

    /// Позиция по рыночной капитализации
    let marketCapRank: Int?

    /// Объем торгов за 24 часа
    let totalVolume: [String: Double]?

    /// Максимум за 24 часа
    let high24h: [String: Double]?

    /// Минимум за 24 часа
    let low24h: [String: Double]?

    /// Изменение цены за 24 часа в процентах
    let priceChangePercentage24h: Double?

    /// Изменение цены за 7 дней в процентах
    let priceChangePercentage7d: Double?

    /// Изменение цены за 30 дней в процентах
    let priceChangePercentage30d: Double?

    /// Изменение цены за 1 год в процентах
    let priceChangePercentage1y: Double?

    /// Количество в обращении
    let circulatingSupply: Double?

    /// Общее количество
    let totalSupply: Double?

    /// Максимальное количество
    let maxSupply: Double?

    enum CodingKeys: String, CodingKey {
        case currentPrice = "current_price"
        case ath
        case athChangePercentage = "ath_change_percentage"
        case atl
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case totalVolume = "total_volume"
        case high24h = "high_24h"
        case low24h = "low_24h"
        case priceChangePercentage24h = "price_change_percentage_24h"
        case priceChangePercentage7d = "price_change_percentage_7d"
        case priceChangePercentage30d = "price_change_percentage_30d"
        case priceChangePercentage1y = "price_change_percentage_1y"
        case circulatingSupply = "circulating_supply"
        case totalSupply = "total_supply"
        case maxSupply = "max_supply"
    }
}

// MARK: - Preview Helper

extension CoinDetail {
    /// Пример для Preview и тестов
    static var example: CoinDetail {
        CoinDetail(
            id: "bitcoin",
            symbol: "btc",
            name: "Bitcoin",
            description: LocalizedDescription(
                en: "Bitcoin is the first successful internet money.",
                ru: "Биткоин — первая успешная интернет-валюта."
            ),
            links: CoinLinks(
                homepage: ["https://bitcoin.org"],
                blockchainSite: ["https://blockchain.info"],
                twitterScreenName: "bitcoin",
                subredditUrl: "https://reddit.com/r/bitcoin",
                reposUrl: ReposUrl(github: ["https://github.com/bitcoin/bitcoin"])
            ),
            image: CoinImage(
                thumb: "https://assets.coingecko.com/coins/images/1/thumb/bitcoin.png",
                small: "https://assets.coingecko.com/coins/images/1/small/bitcoin.png",
                large: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png"
            ),
            marketData: MarketData(
                currentPrice: ["usd": 45000, "rub": 4000000],
                ath: ["usd": 69000],
                athChangePercentage: ["usd": -35],
                atl: ["usd": 67.81],
                marketCap: ["usd": 850000000000],
                marketCapRank: 1,
                totalVolume: ["usd": 25000000000],
                high24h: ["usd": 46000],
                low24h: ["usd": 44000],
                priceChangePercentage24h: 3.45,
                priceChangePercentage7d: 5.2,
                priceChangePercentage30d: 12.5,
                priceChangePercentage1y: 150.0,
                circulatingSupply: 19000000,
                totalSupply: 21000000,
                maxSupply: 21000000
            ),
            genesisDate: "2009-01-03",
            developerScore: 98.5,
            communityScore: 85.0,
            liquidityScore: 100.0
        )
    }
}
