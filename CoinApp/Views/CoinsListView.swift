//
//  CoinsListView.swift
//  CoinApp
//
//  Экран списка криптовалют.
//  Отображает монеты с возможностью поиска, пагинации и pull-to-refresh.
//

import SwiftUI

/// View списка криптовалют
struct CoinsListView: View {

    // MARK: - Properties

    /// ViewModel для управления данными
    /// @State с @Observable (iOS 17+) автоматически отслеживает изменения
    @State private var viewModel = CoinsListViewModel()

    /// Сервис для работы с избранным
    @EnvironmentObject private var coreDataService: CoreDataService

    // MARK: - Body

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Криптовалюты")
                .searchable(
                    text: $viewModel.searchText,
                    prompt: "Поиск по названию или символу"
                )
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        currencyPicker
                    }
                }
                .refreshable {
                    // Pull-to-refresh
                    await viewModel.refresh()
                }
        }
        .task {
            // Загружаем данные при появлении View
            // .task автоматически отменяется при исчезновении View
            await viewModel.loadCoins()
        }
    }

    // MARK: - Content Views

    /// Основной контент в зависимости от состояния
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            // Начальное состояние (не должно отображаться из-за .task)
            Color.clear

        case .loading:
            LoadingView(message: "Загрузка монет...")

        case .loaded:
            coinsList

        case .error(let error):
            ErrorView(error: error) {
                Task {
                    await viewModel.loadCoins()
                }
            }

        case .empty:
            EmptyStateView(
                title: "Ничего не найдено",
                message: viewModel.searchText.isEmpty
                    ? "Список монет пуст"
                    : "По запросу «\(viewModel.searchText)» ничего не найдено",
                systemImage: "magnifyingglass"
            )
        }
    }

    /// Список монет
    private var coinsList: some View {
        List {
            ForEach(viewModel.filteredCoins) { coin in
                NavigationLink(value: coin) {
                    CoinRowView(
                        coin: coin,
                        isFavorite: coreDataService.isFavorite(coinID: coin.id)
                    )
                }
                // Загрузка следующей страницы при достижении последних элементов
                .onAppear {
                    loadMoreIfNeeded(currentCoin: coin)
                }
            }

            // Индикатор загрузки следующей страницы
            if viewModel.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding()
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .navigationDestination(for: Coin.self) { coin in
            CoinDetailView(coin: coin)
        }
    }

    /// Picker для выбора валюты
    private var currencyPicker: some View {
        Menu {
            ForEach(Currency.allCases) { currency in
                Button {
                    viewModel.currency = currency
                    Task {
                        await viewModel.loadCoins()
                    }
                } label: {
                    if viewModel.currency == currency {
                        Label(currency.displayName, systemImage: "checkmark")
                    } else {
                        Text(currency.displayName)
                    }
                }
            }
        } label: {
            Text(viewModel.currency.symbol)
                .font(.headline)
                .padding(8)
                .background(Color.orange.opacity(0.2))
                .clipShape(Circle())
        }
    }

    // MARK: - Private Methods

    /// Проверка необходимости загрузки следующей страницы
    /// - Parameter currentCoin: Текущая отображаемая монета
    private func loadMoreIfNeeded(currentCoin: Coin) {
        // Загружаем, когда пользователь видит последние 5 элементов
        let thresholdIndex = viewModel.filteredCoins.index(
            viewModel.filteredCoins.endIndex,
            offsetBy: -5,
            limitedBy: viewModel.filteredCoins.startIndex
        ) ?? viewModel.filteredCoins.startIndex

        if let currentIndex = viewModel.filteredCoins.firstIndex(where: { $0.id == currentCoin.id }),
           currentIndex >= thresholdIndex {
            Task {
                await viewModel.loadMoreCoins()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    CoinsListView()
        .environmentObject(CoreDataService.preview)
}
