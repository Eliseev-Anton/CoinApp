//
//  FavoriteCoin.swift
//  CoinApp
//
//  CoreData entity для хранения избранных монет.
//  NSManagedObject подкласс с типизированными свойствами.
//

import Foundation
import CoreData

/// Entity для хранения избранной криптовалюты в CoreData
@objc(FavoriteCoin)
public final class FavoriteCoin: NSManagedObject {

    // MARK: - Properties

    /// Уникальный идентификатор монеты (например: "bitcoin")
    @NSManaged public var id: String?

    /// Название монеты
    @NSManaged public var name: String?

    /// Символ монеты (например: "btc")
    @NSManaged public var symbol: String?

    /// URL изображения монеты
    @NSManaged public var imageURL: String?

    /// Дата добавления в избранное
    @NSManaged public var addedDate: Date?
}

// MARK: - Fetch Request

extension FavoriteCoin {
    /// Создание типизированного fetch request
    /// - Returns: NSFetchRequest для FavoriteCoin
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteCoin> {
        return NSFetchRequest<FavoriteCoin>(entityName: "FavoriteCoin")
    }
}

// MARK: - Identifiable

extension FavoriteCoin: Identifiable {
    // Используем id как уникальный идентификатор
    // CoreData уже предоставляет objectID, но id удобнее для нашего случая
}

// MARK: - Convenience

extension FavoriteCoin {
    /// Безопасное получение id (не optional)
    var coinID: String {
        id ?? ""
    }

    /// Безопасное получение имени
    var displayName: String {
        name ?? "Unknown"
    }

    /// Безопасное получение символа в верхнем регистре
    var displaySymbol: String {
        (symbol ?? "").uppercased()
    }

    /// URL изображения
    var imageURLValue: URL? {
        guard let urlString = imageURL else { return nil }
        return URL(string: urlString)
    }
}
