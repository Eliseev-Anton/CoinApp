//
//  NetworkService.swift
//  CoinApp
//
//  Базовый сетевой сервис для выполнения HTTP запросов.
//  Использует async/await для асинхронных операций.
//  Реализует паттерн Protocol-Oriented Programming для тестируемости.
//

import Foundation

// MARK: - Protocol

/// Протокол сетевого сервиса для внедрения зависимостей и мокирования в тестах
protocol NetworkServiceProtocol {
    /// Выполнить GET запрос и декодировать ответ
    /// - Parameter url: URL для запроса
    /// - Returns: Декодированный объект типа T
    /// - Throws: NetworkError при ошибках
    func fetch<T: Decodable>(_ url: URL) async throws -> T
}

// MARK: - Implementation

/// Реализация сетевого сервиса
final class NetworkService: NetworkServiceProtocol {

    // MARK: - Properties

    /// URLSession для выполнения запросов
    /// Можно заменить на кастомную сессию для тестов
    private let session: URLSession

    /// JSON декодер с настройками для CoinGecko API
    private let decoder: JSONDecoder

    // MARK: - Initialization

    /// Инициализация сервиса
    /// - Parameter session: URLSession (по умолчанию .shared)
    init(session: URLSession = .shared) {
        self.session = session

        // Настраиваем декодер
        self.decoder = JSONDecoder()
        // CoinGecko возвращает даты в ISO 8601 формате
        self.decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - NetworkServiceProtocol

    /// Выполнить GET запрос
    /// - Parameter url: URL для запроса
    /// - Returns: Декодированный объект
    func fetch<T: Decodable>(_ url: URL) async throws -> T {
        do {
            // Выполняем запрос
            // data(from:) автоматически использует фоновую очередь
            let (data, response) = try await session.data(from: url)

            // Проверяем, что получили HTTP ответ
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            // Обрабатываем HTTP статус коды
            switch httpResponse.statusCode {
            case 200...299:
                // Успешный ответ - декодируем
                break
            case 429:
                // Rate limiting от CoinGecko
                throw NetworkError.rateLimited
            default:
                throw NetworkError.httpError(statusCode: httpResponse.statusCode)
            }

            // Декодируем JSON в модель
            do {
                let decoded = try decoder.decode(T.self, from: data)
                return decoded
            } catch {
                // Логируем ошибку декодирования для отладки
                #if DEBUG
                print("Decoding error: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response JSON: \(jsonString.prefix(500))")
                }
                #endif
                throw NetworkError.decodingError(error)
            }

        } catch let error as NetworkError {
            // Пробрасываем наши ошибки как есть
            throw error
        } catch let error as URLError {
            // Преобразуем URLError в наши типы ошибок
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw NetworkError.noConnection
            case .timedOut:
                throw NetworkError.timeout
            default:
                throw NetworkError.unknown(error)
            }
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}

// MARK: - Request Builder

extension NetworkService {
    /// Создать URLRequest с заголовками
    /// - Parameters:
    ///   - url: URL запроса
    ///   - method: HTTP метод (по умолчанию GET)
    /// - Returns: Настроенный URLRequest
    static func makeRequest(url: URL, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30
        return request
    }
}
