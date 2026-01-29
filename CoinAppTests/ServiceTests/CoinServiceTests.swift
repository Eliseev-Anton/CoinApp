//
//  CoinServiceTests.swift
//  CoinAppTests
//
//  Unit-тесты для CoinService.
//  Тестируем корректность формирования URL и обработку ответов.
//

import XCTest
@testable import CoinApp

final class CoinServiceTests: XCTestCase {

    // MARK: - Properties

    var sut: CoinService!
    var mockNetworkService: MockNetworkService!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        sut = CoinService(networkService: mockNetworkService)
    }

    override func tearDown() {
        sut = nil
        mockNetworkService = nil
        super.tearDown()
    }

    // MARK: - Tests

    /// Тест: fetchCoins формирует правильный URL
    func testFetchCoinsURLConstruction() async throws {
        // Given
        let mockCoins = [createMockCoin(id: "bitcoin")]
        try mockNetworkService.setResponse(mockCoins)

        // When
        _ = try await sut.fetchCoins(currency: "usd", page: 1, perPage: 50)

        // Then
        let url = mockNetworkService.lastRequestedURL
        XCTAssertNotNil(url)
        XCTAssertTrue(url!.absoluteString.contains("vs_currency=usd"))
        XCTAssertTrue(url!.absoluteString.contains("page=1"))
        XCTAssertTrue(url!.absoluteString.contains("per_page=50"))
        XCTAssertTrue(url!.absoluteString.contains("sparkline=true"))
    }

    /// Тест: fetchCoins возвращает корректные данные
    func testFetchCoinsReturnsCoins() async throws {
        // Given
        let mockCoins = [
            createMockCoin(id: "bitcoin", name: "Bitcoin"),
            createMockCoin(id: "ethereum", name: "Ethereum")
        ]
        try mockNetworkService.setResponse(mockCoins)

        // When
        let coins = try await sut.fetchCoins(currency: "usd", page: 1, perPage: 50)

        // Then
        XCTAssertEqual(coins.count, 2)
        XCTAssertEqual(coins[0].id, "bitcoin")
        XCTAssertEqual(coins[1].id, "ethereum")
    }

    /// Тест: fetchCoins пробрасывает ошибку сети
    func testFetchCoinsThrowsNetworkError() async {
        // Given
        mockNetworkService.mockError = NetworkError.noConnection

        // When/Then
        do {
            _ = try await sut.fetchCoins(currency: "usd", page: 1, perPage: 50)
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .noConnection)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    /// Тест: fetchCoinDetail формирует правильный URL
    func testFetchCoinDetailURLConstruction() async throws {
        // Given
        let mockDetail = createMockCoinDetail(id: "bitcoin")
        try mockNetworkService.setResponse(mockDetail)

        // When
        _ = try await sut.fetchCoinDetail(id: "bitcoin")

        // Then
        let url = mockNetworkService.lastRequestedURL
        XCTAssertNotNil(url)
        XCTAssertTrue(url!.absoluteString.contains("/coins/bitcoin"))
        XCTAssertTrue(url!.absoluteString.contains("market_data=true"))
    }

    // MARK: - Helpers

    /// Создать mock монету для тестов
    private func createMockCoin(
        id: String,
        name: String = "Test Coin"
    ) -> Coin {
        Coin(
            id: id,
            symbol: id.prefix(3).lowercased(),
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

    /// Создать mock детальной информации
    private func createMockCoinDetail(id: String) -> CoinDetail {
        CoinDetail(
            id: id,
            symbol: id.prefix(3).lowercased(),
            name: "Test \(id)",
            description: nil,
            links: nil,
            image: nil,
            marketData: nil,
            genesisDate: nil,
            developerScore: nil,
            communityScore: nil,
            liquidityScore: nil
        )
    }
}
