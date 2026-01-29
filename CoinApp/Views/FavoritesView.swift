//
//  FavoritesView.swift
//  CoinApp
//
//  Экран избранных криптовалют.
//  Отображает монеты, сохраненные в CoreData.
//

import SwiftUI

/// View списка избранных монет
struct FavoritesView: View {

    // MARK: - Properties

    /// ViewModel для управления избранными
    @State private var viewModel = FavoritesViewModel()

    /// Сервис CoreData для отслеживания изменений
    @EnvironmentObject private var coreDataService: CoreDataService

    // MARK: - Body

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Избранное")
        }
        .onAppear {
            viewModel.loadFavorites()
        }
        // Обновляем при изменении избранного
        .onChange(of: coreDataService.favoriteIDs) { _, _ in
            viewModel.loadFavorites()
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            LoadingView(message: "Загрузка избранного...")

        case .loaded(let favorites):
            favoritesList(favorites)

        case .empty:
            EmptyStateView(
                title: "Нет избранных",
                message: "Добавьте монеты в избранное, нажав на звездочку",
                systemImage: "star"
            )

        case .error(let error):
            ErrorView(error: error) {
                viewModel.loadFavorites()
            }
        }
    }

    /// Список избранных монет
    private func favoritesList(_ favorites: [FavoriteCoin]) -> some View {
        List {
            ForEach(favorites) { favorite in
                FavoriteRowView(favorite: favorite)
            }
            .onDelete { indexSet in
                // Удаление свайпом
                indexSet.forEach { index in
                    viewModel.removeFavorite(favorites[index])
                }
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - Favorite Row View

/// Строка избранной монеты
struct FavoriteRowView: View {
    let favorite: FavoriteCoin

    var body: some View {
        HStack(spacing: 12) {
            // Изображение
            AsyncImage(url: favorite.imageURLValue) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 44, height: 44)

            // Информация
            VStack(alignment: .leading, spacing: 4) {
                Text(favorite.displayName)
                    .font(.headline)

                Text(favorite.displaySymbol)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Дата добавления
            if let date = favorite.addedDate {
                Text(date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    FavoritesView()
        .environmentObject(CoreDataService.preview)
}
