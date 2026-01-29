//
//  CoinsListViewModel.swift
//  CoinApp
//
//  ViewModel для экрана списка криптовалют.
//  Использует @Observable макрос (iOS 17+) вместо ObservableObject.
//  Управляет загрузкой, пагинацией и состоянием списка.
//

import Foundation
import Observation

/// ViewModel для списка криптовалют
/// @Observable - новый макрос iOS 17 для автоматического отслеживания изменений
/// Преимущества: проще синтаксис, лучшая производительность, не нужен @Published
@Observable
final class CoinsListViewModel {

    // MARK: - Properties

    /// Текущее состояние экрана
    /// Использует generic ViewState для типобезопасности
    private(set) var state: ViewState<[Coin]> = .idle

    /// Текущая страница для пагинации
    private var currentPage = 1

    /// Флаг, идет ли загрузка следующей страницы
    private(set) var isLoadingMore = false

    /// Флаг, есть ли еще данные для загрузки
    private(set) var hasMoreData = true

    /// Поисковый запрос
    var searchText = "" {
        didSet {
            // Фильтруем локально при изменении поиска
            filterCoins()
        }
    }

    /// Все загруженные монеты (до фильтрации)
    private var allCoins: [Coin] = []

    /// Отфильтрованные монеты для отображения
    private(set) var filteredCoins: [Coin] = []

    /// Выбранная валюта для отображения цен
    var currency: Currency = .usd

    // MARK: - Dependencies

    /// Сервис для загрузки данных
    /// Внедряется через инициализатор для тестируемости
    private let coinService: CoinServiceProtocol

    // MARK: - Initialization

    /// Инициализация с внедрением зависимости
    /// - Parameter coinService: Сервис для работы с API
    init(coinService: CoinServiceProtocol = CoinService.shared) {
        self.coinService = coinService
    }

    // MARK: - Public Methods

    /// Загрузить список монет
    /// Сбрасывает пагинацию и загружает первую страницу
    @MainActor
    func loadCoins() async {
        // Устанавливаем состояние загрузки
        state = .loading
        currentPage = 1
        hasMoreData = true

        do {
            // Загружаем первую страницу
            // await автоматически переключает на background thread
            let coins = try await coinService.fetchCoins(
                currency: currency.rawValue,
                page: currentPage,
                perPage: 50
            )

            // Проверяем, есть ли данные
            if coins.isEmpty {
                state = .empty
                allCoins = []
                filteredCoins = []
            } else {
                allCoins = coins
                filterCoins()
                state = .loaded(filteredCoins)
            }

            // Проверяем, есть ли еще данные
            hasMoreData = coins.count == 50

        } catch {
            // Обрабатываем ошибку
            state = .error(error)
            #if DEBUG
            print("Failed to load coins: \(error)")
            #endif
        }
    }

    /// Загрузить следующую страницу (пагинация)
    /// Вызывается при достижении конца списка
    @MainActor
    func loadMoreCoins() async {
        // Проверяем условия для загрузки
        guard !isLoadingMore, hasMoreData else { return }

        isLoadingMore = true
        currentPage += 1

        do {
            let newCoins = try await coinService.fetchCoins(
                currency: currency.rawValue,
                page: currentPage,
                perPage: 50
            )

            // Добавляем новые монеты к существующим
            allCoins.append(contentsOf: newCoins)
            filterCoins()
            state = .loaded(filteredCoins)

            // Обновляем флаг наличия данных
            hasMoreData = newCoins.count == 50

        } catch {
            // При ошибке пагинации не сбрасываем существующие данные
            currentPage -= 1
            #if DEBUG
            print("Failed to load more coins: \(error)")
            #endif
        }

        isLoadingMore = false
    }

    /// Обновить список (pull-to-refresh)
    @MainActor
    func refresh() async {
        await loadCoins()
    }

    // MARK: - Private Methods

    /// Фильтрация монет по поисковому запросу
    private func filterCoins() {
        if searchText.isEmpty {
            filteredCoins = allCoins
        } else {
            let query = searchText.lowercased()
            filteredCoins = allCoins.filter { coin in
                coin.name.lowercased().contains(query) ||
                coin.symbol.lowercased().contains(query)
            }
        }

        // Обновляем state если были данные
        if case .loaded = state {
            state = filteredCoins.isEmpty && !searchText.isEmpty
                ? .empty
                : .loaded(filteredCoins)
        }
    }
}

// MARK: - Currency Enum

/// Поддерживаемые валюты для отображения цен
enum Currency: String, CaseIterable, Identifiable {
    case usd
    case rub
    case eur

    var id: String { rawValue }

    /// Отображаемое название
    var displayName: String {
        switch self {
        case .usd: return "USD ($)"
        case .rub: return "RUB (₽)"
        case .eur: return "EUR (€)"
        }
    }

    /// Символ валюты
    var symbol: String {
        switch self {
        case .usd: return "$"
        case .rub: return "₽"
        case .eur: return "€"
        }
    }
}
