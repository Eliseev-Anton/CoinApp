//
//  ViewStateTests.swift
//  CoinAppTests
//
//  Unit-тесты для ViewState enum.
//

import XCTest
@testable import CoinApp

final class ViewStateTests: XCTestCase {

    // MARK: - isLoading Tests

    func testIsLoadingReturnsTrueForLoadingState() {
        let state: ViewState<String> = .loading
        XCTAssertTrue(state.isLoading)
    }

    func testIsLoadingReturnsFalseForOtherStates() {
        let idleState: ViewState<String> = .idle
        let loadedState: ViewState<String> = .loaded("test")
        let errorState: ViewState<String> = .error(NetworkError.unknown(NSError()))
        let emptyState: ViewState<String> = .empty

        XCTAssertFalse(idleState.isLoading)
        XCTAssertFalse(loadedState.isLoading)
        XCTAssertFalse(errorState.isLoading)
        XCTAssertFalse(emptyState.isLoading)
    }

    // MARK: - data Tests

    func testDataReturnsValueForLoadedState() {
        let state: ViewState<String> = .loaded("test data")
        XCTAssertEqual(state.data, "test data")
    }

    func testDataReturnsNilForOtherStates() {
        let idleState: ViewState<String> = .idle
        let loadingState: ViewState<String> = .loading
        let errorState: ViewState<String> = .error(NetworkError.unknown(NSError()))

        XCTAssertNil(idleState.data)
        XCTAssertNil(loadingState.data)
        XCTAssertNil(errorState.data)
    }

    // MARK: - error Tests

    func testErrorReturnsValueForErrorState() {
        let testError = NetworkError.noConnection
        let state: ViewState<String> = .error(testError)

        XCTAssertNotNil(state.error)
        XCTAssertEqual(state.error as? NetworkError, .noConnection)
    }

    func testErrorReturnsNilForOtherStates() {
        let loadedState: ViewState<String> = .loaded("test")
        XCTAssertNil(loadedState.error)
    }

    // MARK: - map Tests

    func testMapTransformsLoadedData() {
        let state: ViewState<Int> = .loaded(5)
        let mapped = state.map { $0 * 2 }

        XCTAssertEqual(mapped.data, 10)
    }

    func testMapPreservesLoadingState() {
        let state: ViewState<Int> = .loading
        let mapped = state.map { $0 * 2 }

        XCTAssertTrue(mapped.isLoading)
    }

    func testMapPreservesErrorState() {
        let state: ViewState<Int> = .error(NetworkError.noConnection)
        let mapped = state.map { $0 * 2 }

        XCTAssertTrue(mapped.isError)
    }

    // MARK: - isEmpty Tests

    func testIsEmptyReturnsTrueForEmptyState() {
        let state: ViewState<[String]> = .empty
        XCTAssertTrue(state.isEmpty)
    }

    func testIsEmptyReturnsFalseForLoadedState() {
        let state: ViewState<[String]> = .loaded(["item"])
        XCTAssertFalse(state.isEmpty)
    }
}
