//
//  NetworkError.swift
//  CoinApp
//
//  Типы ошибок для сетевого слоя.
//  Позволяет детально обрабатывать различные проблемы с сетью.
//

import Foundation

/// Ошибки сетевого слоя
enum NetworkError: Error, LocalizedError {
    /// Некорректный URL
    case invalidURL

    /// Некорректный ответ сервера (не HTTP ответ)
    case invalidResponse

    /// HTTP ошибка с кодом статуса
    case httpError(statusCode: Int)

    /// Ошибка декодирования JSON
    case decodingError(Error)

    /// Нет интернет-соединения
    case noConnection

    /// Таймаут запроса
    case timeout

    /// Превышен лимит запросов (rate limiting)
    case rateLimited

    /// Неизвестная ошибка
    case unknown(Error)

    // MARK: - LocalizedError

    /// Локализованное описание ошибки для отображения пользователю
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Некорректный адрес запроса"
        case .invalidResponse:
            return "Сервер вернул некорректный ответ"
        case .httpError(let statusCode):
            return "Ошибка сервера: \(statusCode)"
        case .decodingError:
            return "Ошибка обработки данных"
        case .noConnection:
            return "Нет интернет-соединения"
        case .timeout:
            return "Превышено время ожидания"
        case .rateLimited:
            return "Слишком много запросов. Попробуйте позже"
        case .unknown:
            return "Произошла неизвестная ошибка"
        }
    }

    /// Подробное описание для логирования
    var debugDescription: String {
        switch self {
        case .invalidURL:
            return "NetworkError.invalidURL"
        case .invalidResponse:
            return "NetworkError.invalidResponse"
        case .httpError(let statusCode):
            return "NetworkError.httpError(statusCode: \(statusCode))"
        case .decodingError(let error):
            return "NetworkError.decodingError(\(error.localizedDescription))"
        case .noConnection:
            return "NetworkError.noConnection"
        case .timeout:
            return "NetworkError.timeout"
        case .rateLimited:
            return "NetworkError.rateLimited"
        case .unknown(let error):
            return "NetworkError.unknown(\(error.localizedDescription))"
        }
    }
}

// MARK: - Equatable

extension NetworkError: Equatable {
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        case (.invalidResponse, .invalidResponse):
            return true
        case (.httpError(let lhsCode), .httpError(let rhsCode)):
            return lhsCode == rhsCode
        case (.noConnection, .noConnection):
            return true
        case (.timeout, .timeout):
            return true
        case (.rateLimited, .rateLimited):
            return true
        case (.decodingError, .decodingError):
            // Не сравниваем внутренние ошибки
            return true
        case (.unknown, .unknown):
            return true
        default:
            return false
        }
    }
}
