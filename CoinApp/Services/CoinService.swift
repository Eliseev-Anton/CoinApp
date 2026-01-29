//
//  CoinService.swift
//  CoinApp
//
//  Сервис для работы с CoinGecko API.
//  Предоставляет методы для получения списка криптовалют и детальной информации.
//

import Foundation

// MARK: - Protocol

/// Протокол сервиса криптовалют для тестируемости
protocol CoinServiceProtocol {
    /// Получить список криптовалют
    /// - Parameters:
    ///   - currency: Валюта для отображения цен (usd, rub, eur)
    ///   - page: Номер страницы для пагинации
    ///   - perPage: Количество монет на страницу
    /// - Returns: Массив монет
    func fetchCoins(currency: String, page: Int, perPage: Int) async throws -> [Coin]

    /// Получить детальную информацию о монете
    /// - Parameter id: Идентификатор монеты (например: "bitcoin")
    /// - Returns: Детальная информация о монете
    func fetchCoinDetail(id: String) async throws -> CoinDetail

    /// Поиск монет по запросу
    /// - Parameter query: Поисковый запрос
    /// - Returns: Массив найденных монет
    func searchCoins(query: String) async throws -> [SearchCoin]
}

// MARK: - Search Result Model

/// Модель для результатов поиска
struct SearchCoin: Decodable, Identifiable {
    let id: String
    let name: String
    let symbol: String
    let thumb: String?
    let marketCapRank: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, symbol, thumb
        case marketCapRank = "market_cap_rank"
    }
}

/// Обертка для результатов поиска
struct SearchResponse: Decodable {
    let coins: [SearchCoin]
}

// MARK: - Implementation

/// Реализация сервиса для работы с CoinGecko API
final class CoinService: CoinServiceProtocol {

    // MARK: - Constants

    /// Базовый URL CoinGecko API
    private let baseURL = "https://api.coingecko.com/api/v3"

    // MARK: - Properties

    /// Сетевой сервис для выполнения запросов
    private let networkService: NetworkServiceProtocol

    // MARK: - Initialization

    /// Инициализация с внедрением зависимости
    /// - Parameter networkService: Сервис для сетевых запросов
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    // MARK: - CoinServiceProtocol

    /// Получить список криптовалют с рынка
    func fetchCoins(currency: String = "usd", page: Int = 1, perPage: Int = 50) async throws -> [Coin] {
        // Формируем URL с параметрами
        // sparkline=true добавляет данные для мини-графика
        var components = URLComponents(string: "\(baseURL)/coins/markets")!
        components.queryItems = [
            URLQueryItem(name: "vs_currency", value: currency),
            URLQueryItem(name: "order", value: "market_cap_desc"),
            URLQueryItem(name: "per_page", value: String(perPage)),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "sparkline", value: "true"),
            URLQueryItem(name: "price_change_percentage", value: "24h")
        ]

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        // Выполняем запрос через networkService
        let coins: [Coin] = try await networkService.fetch(url)
        return coins
    }

    /// Получить детальную информацию о монете
    func fetchCoinDetail(id: String) async throws -> CoinDetail {
        var components = URLComponents(string: "\(baseURL)/coins/\(id)")!
        components.queryItems = [
            URLQueryItem(name: "localization", value: "true"),
            URLQueryItem(name: "tickers", value: "false"),
            URLQueryItem(name: "market_data", value: "true"),
            URLQueryItem(name: "community_data", value: "true"),
            URLQueryItem(name: "developer_data", value: "true")
        ]

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        let detail: CoinDetail = try await networkService.fetch(url)
        return detail
    }

    /// Поиск монет
    func searchCoins(query: String) async throws -> [SearchCoin] {
        var components = URLComponents(string: "\(baseURL)/search")!
        components.queryItems = [
            URLQueryItem(name: "query", value: query)
        ]

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        let response: SearchResponse = try await networkService.fetch(url)
        return response.coins
    }
}

// MARK: - Singleton (опционально)

extension CoinService {
    /// Общий экземпляр сервиса
    /// Используется для простоты, но можно внедрять через DI
    static let shared = CoinService()
}
