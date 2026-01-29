//
//  CoreDataService.swift
//  CoinApp
//
//  Сервис для работы с CoreData.
//  Управляет сохранением избранных монет в локальное хранилище.
//  Использует паттерн ObservableObject для реактивного обновления UI.
//

import Foundation
import CoreData
import SwiftUI
import Combine

/// Сервис управления CoreData стеком и операциями с избранными монетами
final class CoreDataService: ObservableObject {

    // MARK: - Singleton

    /// Общий экземпляр сервиса
    static let shared = CoreDataService()

    // MARK: - Properties

    /// Контейнер CoreData
    /// Lazy инициализация для оптимизации запуска
    let container: NSPersistentContainer

    /// Список идентификаторов избранных монет
    /// @Published для автоматического обновления UI при изменениях
    @Published private(set) var favoriteIDs: Set<String> = []

    // MARK: - Initialization

    /// Инициализация CoreData стека
    /// - Parameter inMemory: Использовать in-memory store (для тестов и Preview)
    init(inMemory: Bool = false) {
        // Создаем модель программно (без .xcdatamodeld файла)
        container = Self.createContainer(inMemory: inMemory)

        // Загружаем persistent store
        container.loadPersistentStores { [weak self] description, error in
            if let error = error {
                // В продакшене здесь должна быть обработка ошибки
                // Например, миграция или очистка данных
                fatalError("CoreData failed to load: \(error.localizedDescription)")
            }

            #if DEBUG
            print("CoreData loaded: \(description.url?.absoluteString ?? "unknown")")
            #endif

            // Загружаем избранные после инициализации стека
            self?.loadFavorites()
        }

        // Настраиваем автоматическое слияние изменений из background контекстов
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // MARK: - Private Methods

    /// Создание NSPersistentContainer с программной моделью
    private static func createContainer(inMemory: Bool) -> NSPersistentContainer {
        // Создаем модель программно
        let model = createManagedObjectModel()
        let container = NSPersistentContainer(name: "CoinApp", managedObjectModel: model)

        if inMemory {
            // Для тестов используем in-memory store
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        return container
    }

    /// Создание NSManagedObjectModel программно
    /// Альтернатива использованию .xcdatamodeld файла
    private static func createManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // Создаем entity для избранной монеты
        let favoriteEntity = NSEntityDescription()
        favoriteEntity.name = "FavoriteCoin"
        favoriteEntity.managedObjectClassName = NSStringFromClass(FavoriteCoin.self)

        // Атрибуты entity
        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .stringAttributeType
        idAttribute.isOptional = false

        let nameAttribute = NSAttributeDescription()
        nameAttribute.name = "name"
        nameAttribute.attributeType = .stringAttributeType
        nameAttribute.isOptional = true

        let symbolAttribute = NSAttributeDescription()
        symbolAttribute.name = "symbol"
        symbolAttribute.attributeType = .stringAttributeType
        symbolAttribute.isOptional = true

        let imageURLAttribute = NSAttributeDescription()
        imageURLAttribute.name = "imageURL"
        imageURLAttribute.attributeType = .stringAttributeType
        imageURLAttribute.isOptional = true

        let addedDateAttribute = NSAttributeDescription()
        addedDateAttribute.name = "addedDate"
        addedDateAttribute.attributeType = .dateAttributeType
        addedDateAttribute.isOptional = false

        favoriteEntity.properties = [
            idAttribute,
            nameAttribute,
            symbolAttribute,
            imageURLAttribute,
            addedDateAttribute
        ]

        model.entities = [favoriteEntity]
        return model
    }

    /// Загрузка избранных монет из CoreData
    private func loadFavorites() {
        let context = container.viewContext
        let request = FavoriteCoin.fetchRequest()

        do {
            let favorites = try context.fetch(request)
            favoriteIDs = Set(favorites.compactMap { $0.id })
        } catch {
            print("Failed to load favorites: \(error)")
            favoriteIDs = []
        }
    }

    // MARK: - Public Methods

    /// Проверить, добавлена ли монета в избранное
    /// - Parameter coinID: Идентификатор монеты
    /// - Returns: true если монета в избранном
    func isFavorite(coinID: String) -> Bool {
        favoriteIDs.contains(coinID)
    }

    /// Добавить монету в избранное
    /// - Parameter coin: Монета для добавления
    /// Выполняется на background контексте для производительности
    func addToFavorites(_ coin: Coin) {
        // Используем background контекст для записи
        let context = container.newBackgroundContext()

        // Выполняем на background очереди
        context.perform { [weak self] in
            // Создаем новую запись
            let favorite = FavoriteCoin(context: context)
            favorite.id = coin.id
            favorite.name = coin.name
            favorite.symbol = coin.symbol
            favorite.imageURL = coin.image
            favorite.addedDate = Date()

            do {
                try context.save()

                // Обновляем UI на главной очереди
                DispatchQueue.main.async {
                    self?.favoriteIDs.insert(coin.id)
                }
            } catch {
                print("Failed to save favorite: \(error)")
            }
        }
    }

    /// Удалить монету из избранного
    /// - Parameter coinID: Идентификатор монеты
    func removeFromFavorites(coinID: String) {
        let context = container.newBackgroundContext()

        context.perform { [weak self] in
            let request = FavoriteCoin.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", coinID)

            do {
                let results = try context.fetch(request)
                results.forEach { context.delete($0) }
                try context.save()

                DispatchQueue.main.async {
                    self?.favoriteIDs.remove(coinID)
                }
            } catch {
                print("Failed to remove favorite: \(error)")
            }
        }
    }

    /// Переключить состояние избранного
    /// - Parameter coin: Монета
    func toggleFavorite(_ coin: Coin) {
        if isFavorite(coinID: coin.id) {
            removeFromFavorites(coinID: coin.id)
        } else {
            addToFavorites(coin)
        }
    }

    /// Получить все избранные монеты
    /// - Returns: Массив избранных монет
    func fetchAllFavorites() -> [FavoriteCoin] {
        let context = container.viewContext
        let request = FavoriteCoin.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FavoriteCoin.addedDate, ascending: false)]

        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch favorites: \(error)")
            return []
        }
    }
}

// MARK: - Preview Helper

extension CoreDataService {
    /// Экземпляр для Preview с in-memory store
    static var preview: CoreDataService {
        let service = CoreDataService(inMemory: true)
        // Добавляем тестовые данные
        let context = service.container.viewContext

        let btc = FavoriteCoin(context: context)
        btc.id = "bitcoin"
        btc.name = "Bitcoin"
        btc.symbol = "btc"
        btc.addedDate = Date()

        let eth = FavoriteCoin(context: context)
        eth.id = "ethereum"
        eth.name = "Ethereum"
        eth.symbol = "eth"
        eth.addedDate = Date()

        try? context.save()
        service.loadFavorites()

        return service
    }
}
