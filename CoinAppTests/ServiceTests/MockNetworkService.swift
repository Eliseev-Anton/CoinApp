//
//  MockNetworkService.swift
//  CoinAppTests
//
//  Mock реализация NetworkService для тестирования.
//  Позволяет контролировать ответы и симулировать ошибки.
//

import Foundation
@testable import CoinApp

/// Mock сетевого сервиса для тестов
final class MockNetworkService: NetworkServiceProtocol {

    // MARK: - Properties

    /// Данные для возврата
    var mockData: Data?

    /// Ошибка для симуляции
    var mockError: Error?

    /// Количество вызовов fetch
    var fetchCallCount = 0

    /// Последний запрошенный URL
    var lastRequestedURL: URL?

    // MARK: - NetworkServiceProtocol

    func fetch<T: Decodable>(_ url: URL) async throws -> T {
        fetchCallCount += 1
        lastRequestedURL = url

        // Если задана ошибка - бросаем её
        if let error = mockError {
            throw error
        }

        // Если заданы данные - декодируем
        guard let data = mockData else {
            throw NetworkError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }

    // MARK: - Helpers

    /// Установить JSON данные для ответа
    func setResponse<T: Encodable>(_ object: T) throws {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        mockData = try encoder.encode(object)
    }

    /// Сбросить состояние мока
    func reset() {
        mockData = nil
        mockError = nil
        fetchCallCount = 0
        lastRequestedURL = nil
    }
}
