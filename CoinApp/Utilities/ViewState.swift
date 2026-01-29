//
//  ViewState.swift
//  CoinApp
//
//  Универсальный enum для управления состояниями экрана.
//  Позволяет типобезопасно обрабатывать loading, error, empty и loaded состояния.
//

import Foundation

/// Состояние загрузки данных для View
/// Generic параметр T - тип загружаемых данных
enum ViewState<T> {
    /// Начальное состояние, данные еще не загружались
    case idle

    /// Идет загрузка данных
    case loading

    /// Данные успешно загружены
    case loaded(T)

    /// Произошла ошибка при загрузке
    case error(Error)

    /// Данные загружены, но пустые
    case empty
}

// MARK: - Computed Properties

extension ViewState {
    /// Проверка, идет ли загрузка
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }

    /// Проверка, есть ли ошибка
    var isError: Bool {
        if case .error = self {
            return true
        }
        return false
    }

    /// Получить загруженные данные (если есть)
    var data: T? {
        if case .loaded(let data) = self {
            return data
        }
        return nil
    }

    /// Получить ошибку (если есть)
    var error: Error? {
        if case .error(let error) = self {
            return error
        }
        return nil
    }

    /// Проверка на пустое состояние
    var isEmpty: Bool {
        if case .empty = self {
            return true
        }
        return false
    }

    /// Проверка на начальное состояние
    var isIdle: Bool {
        if case .idle = self {
            return true
        }
        return false
    }
}

// MARK: - Mapping

extension ViewState {
    /// Трансформация данных внутри состояния
    /// - Parameter transform: Функция преобразования
    /// - Returns: Новое состояние с преобразованными данными
    func map<U>(_ transform: (T) -> U) -> ViewState<U> {
        switch self {
        case .idle:
            return .idle
        case .loading:
            return .loading
        case .loaded(let data):
            return .loaded(transform(data))
        case .error(let error):
            return .error(error)
        case .empty:
            return .empty
        }
    }
}
