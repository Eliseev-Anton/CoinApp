//
//  CoinsListViewModelTests.swift
//  CoinAppTests
//
//  Unit-тесты для CoinsListViewModel.
//  Тестируем логику загрузки, состояния и фильтрации.
//

import XCTest
@testable import CoinApp

/// Mock CoinService для тестирования ViewModel
final class MockCoinService: CoinServiceProtocol {
    var coinsToReturn: [Coin] = []
    var detailToReturn: CoinDetail?
    var searchResultsToReturn: [SearchCoin] = []
    var errorToThrow: Error?

    var fetchCoinsCallCount = 0
    var lastCurrency: String?
    var lastPage: Int?

    func fetchCoins(currency: String, page: Int, perPage: Int) async throws -> [Coin] {
        fetchCoinsCallCount += 1
        lastCurrency = currency
        lastPage = page

        if let error = errorToThrow {
            throw error
        }
        return coinsToReturn
    }

    func fetchCoinDetail(id: String) async throws -> CoinDetail {
        if let error = errorToThrow {
            throw error
        }
        return detailToReturn ?? CoinDetail.example
    }

    func searchCoins(query: String) async throws -> [SearchCoin] {
        if let error = errorToThrow {
            throw error
        }
        return searchResultsToReturn
    }
}

@MainActor
final class CoinsListViewModelTests: XCTestCase {

    // MARK: - Properties

    var sut: CoinsListViewModel!
    var mockService: MockCoinService!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        mockService = MockCoinService()
        sut = CoinsListViewModel(coinService: mockService)
    }

    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }

    // MARK: - Tests

    /// Тест: начальное состояние - idle
    func testInitialStateIsIdle() {
        XCTAssertTrue(sut.state.isIdle)
        XCTAssertTrue(sut.filteredCoins.isEmpty)
        XCTAssertFalse(sut.isLoadingMore)
    }

    /// Тест: успешная загрузка устанавливает состояние loaded
    func testLoadCoinsSuccess() async {
        // Given
        let mockCoins = [Coin.example]
        mockService.coinsToReturn = mockCoins

        // When
        await sut.loadCoins()

        // Then
        XCTAssertNotNil(sut.state.data)
        XCTAssertEqual(sut.filteredCoins.count, 1)
        XCTAssertEqual(sut.filteredCoins.first?.id, "bitcoin")
    }

    /// Тест: ошибка загрузки устанавливает состояние error
    func testLoadCoinsError() async {
        // Given
        mockService.errorToThrow = NetworkError.noConnection

        // When
        await sut.loadCoins()

        // Then
        XCTAssertTrue(sut.state.isError)
        XCTAssertNotNil(sut.state.error)
    }

    /// Тест: пустой ответ устанавливает состояние empty
    func testLoadCoinsEmpty() async {
        // Given
        mockService.coinsToReturn = []

        // When
        await sut.loadCoins()

        // Then
        XCTAssertTrue(sut.state.isEmpty)
    }

    /// Тест: фильтрация по имени работает
    func testFilterByName() async {
        // Given
        let btc = createCoin(id: "bitcoin", name: "Bitcoin", symbol: "btc")
        let eth = createCoin(id: "ethereum", name: "Ethereum", symbol: "eth")
        mockService.coinsToReturn = [btc, eth]

        // When
        await sut.loadCoins()
        sut.searchText = "bit"

        // Then
        XCTAssertEqual(sut.filteredCoins.count, 1)
        XCTAssertEqual(sut.filteredCoins.first?.id, "bitcoin")
    }

    /// Тест: фильтрация по символу работает
    func testFilterBySymbol() async {
        // Given
        let btc = createCoin(id: "bitcoin", name: "Bitcoin", symbol: "btc")
        let eth = createCoin(id: "ethereum", name: "Ethereum", symbol: "eth")
        mockService.coinsToReturn = [btc, eth]

        // When
        await sut.loadCoins()
        sut.searchText = "eth"

        // Then
        XCTAssertEqual(sut.filteredCoins.count, 1)
        XCTAssertEqual(sut.filteredCoins.first?.id, "ethereum")
    }

    /// Тест: пустой поиск показывает все монеты
    func testEmptySearchShowsAllCoins() async {
        // Given
        let coins = [
            createCoin(id: "bitcoin", name: "Bitcoin", symbol: "btc"),
            createCoin(id: "ethereum", name: "Ethereum", symbol: "eth")
        ]
        mockService.coinsToReturn = coins

        // When
        await sut.loadCoins()
        sut.searchText = "bit"
        sut.searchText = ""

        // Then
        XCTAssertEqual(sut.filteredCoins.count, 2)
    }

    /// Тест: пагинация загружает следующую страницу
    func testLoadMoreCoins() async {
        // Given
        let firstPage = (1...50).map { createCoin(id: "coin\($0)", name: "Coin \($0)", symbol: "C\($0)") }
        mockService.coinsToReturn = firstPage

        await sut.loadCoins()

        let secondPage = (51...60).map { createCoin(id: "coin\($0)", name: "Coin \($0)", symbol: "C\($0)") }
        mockService.coinsToReturn = secondPage

        // When
        await sut.loadMoreCoins()

        // Then
        XCTAssertEqual(mockService.lastPage, 2)
        XCTAssertEqual(sut.filteredCoins.count, 60)
    }

    /// Тест: смена валюты перезагружает данные
    func testChangeCurrencyReloadsData() async {
        // Given
        mockService.coinsToReturn = [Coin.example]
        await sut.loadCoins()

        // When
        sut.currency = .eur
        await sut.loadCoins()

        // Then
        XCTAssertEqual(mockService.lastCurrency, "eur")
        XCTAssertEqual(mockService.fetchCoinsCallCount, 2)
    }

    // MARK: - Helpers

    private func createCoin(id: String, name: String, symbol: String) -> Coin {
        Coin(
            id: id,
            symbol: symbol,
            name: name,
            image: "https://example.com/\(id).png",
            currentPrice: 100.0,
            marketCap: 1000000,
            marketCapRank: 1,
            fullyDilutedValuation: nil,
            totalVolume: 50000,
            high24h: 105,
            low24h: 95,
            priceChange24h: 5,
            priceChangePercentage24h: 5.0,
            marketCapChange24h: nil,
            marketCapChangePercentage24h: nil,
            circulatingSupply: 1000,
            totalSupply: 2000,
            maxSupply: 2000,
            ath: 200,
            athChangePercentage: -50,
            athDate: nil,
            atl: 10,
            atlChangePercentage: 900,
            atlDate: nil,
            lastUpdated: nil,
            sparklineIn7d: nil
        )
    }
}
