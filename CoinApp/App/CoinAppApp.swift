//
//  CoinAppApp.swift
//  CoinApp
//
//  Главная точка входа в приложение.
//  Здесь инициализируется CoreData контейнер и внедряются зависимости.
//

import SwiftUI

@main
struct CoinAppApp: App {

    // MARK: - Properties

    /// Контроллер для управления CoreData стеком
    /// StateObject гарантирует, что объект создается один раз и переживает перерисовки
    @StateObject private var coreDataService = CoreDataService.shared

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            ContentView()
                // Внедряем CoreData контекст во все дочерние View
                .environment(\.managedObjectContext, coreDataService.container.viewContext)
                // Внедряем сервис для работы с избранным
                .environmentObject(coreDataService)
        }
    }
}
