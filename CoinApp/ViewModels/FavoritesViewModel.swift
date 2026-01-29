//
//  FavoritesViewModel.swift
//  CoinApp
//
//  ViewModel для экрана избранных монет.
//  Интегрируется с CoreDataService для отображения сохраненных монет.
//

import Foundation
import Observation

/// ViewModel для управления избранными монетами
@Observable
final class FavoritesViewModel {

    // MARK: - Properties

    /// Состояние загрузки
    private(set) var state: ViewState<[FavoriteCoin]> = .idle

    /// Список избранных монет
    private(set) var favorites: [FavoriteCoin] = []

    // MARK: - Dependencies

    private let coreDataService: CoreDataService

    // MARK: - Initialization

    /// Инициализация с CoreData сервисом
    /// - Parameter coreDataService: Сервис для работы с CoreData
    init(coreDataService: CoreDataService = .shared) {
        self.coreDataService = coreDataService
    }

    // MARK: - Public Methods

    /// Загрузить список избранных
    @MainActor
    func loadFavorites() {
        state = .loading

        // CoreData операция выполняется синхронно на main thread
        // Для больших объемов данных следует использовать background context
        favorites = coreDataService.fetchAllFavorites()

        if favorites.isEmpty {
            state = .empty
        } else {
            state = .loaded(favorites)
        }
    }

    /// Удалить монету из избранного
    /// - Parameter favorite: Избранная монета для удаления
    @MainActor
    func removeFavorite(_ favorite: FavoriteCoin) {
        guard let id = favorite.id else { return }

        coreDataService.removeFromFavorites(coinID: id)

        // Обновляем локальный список
        favorites.removeAll { $0.id == id }

        if favorites.isEmpty {
            state = .empty
        } else {
            state = .loaded(favorites)
        }
    }

    /// Проверить, есть ли монета в избранном
    /// - Parameter coinID: Идентификатор монеты
    /// - Returns: true если в избранном
    func isFavorite(coinID: String) -> Bool {
        coreDataService.isFavorite(coinID: coinID)
    }
}
