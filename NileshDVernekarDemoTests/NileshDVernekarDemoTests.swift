//
//  NileshDVernekarDemoTests.swift
//  NileshDVernekarDemoTests
//
//  Created by Nilesh Vernekar on 19/12/25.
//

import XCTest
@testable import NileshDVernekarDemo

final class UserHoldingTests: XCTestCase {

    func testCurrentValue() {
        // Test: Current value = LTP * quantity
        let holding = UserHolding(symbol: "TATA", quantity: 10, ltp: 150.0, avgPrice: 100.0, close: 140.0)
        let expectedCurrentValue = 150.0 * 10.0 // 1500.0

        XCTAssertEqual(holding.currentValue, expectedCurrentValue, accuracy: 0.01, "Current value should be LTP * quantity")
    }

    func testInvestmentValue() {
        // Test: Investment value = avgPrice * quantity
        let holding = UserHolding(symbol: "HDFC", quantity: 5, ltp: 200.0, avgPrice: 180.0, close: 195.0)
        let expectedInvestmentValue = 180.0 * 5.0 // 900.0

        XCTAssertEqual(holding.investmentValue, expectedInvestmentValue, accuracy: 0.01, "Investment value should be avgPrice * quantity")
    }

    func testProfitAndLoss() {
        // Test: P&L = currentValue - investmentValue
        let holding = UserHolding(symbol: "ICICIBANK", quantity: 8, ltp: 500.0, avgPrice: 450.0, close: 495.0)
        let expectedPnL = (500.0 * 8.0) - (450.0 * 8.0) // 4000 - 3600 = 400

        XCTAssertEqual(holding.profitAndLoss, expectedPnL, accuracy: 0.01, "P&L should be currentValue - investmentValue")
    }

    func testProfitAndLossNegative() {
        // Test negative P&L scenario
        let holding = UserHolding(symbol: "IDEA", quantity: 100, ltp: 8.0, avgPrice: 12.0, close: 9.0)
        let expectedPnL = (8.0 * 100.0) - (12.0 * 100.0) // 800 - 1200 = -400

        XCTAssertEqual(holding.profitAndLoss, expectedPnL, accuracy: 0.01, "P&L should be negative when current value < investment value")
    }
}

// MARK: - ViewModel Tests
final class HoldingsViewModelTests: XCTestCase {

    var viewModel: HoldingsViewModel!
    var mockUserHoldings: [UserHolding]!
    var url = "https://35dee773a9ec441e9f38d5fc249406ce.api.mockbin.io/"


    override func setUp() {
        super.setUp()

        // Initialize the view model and mock data
        viewModel = HoldingsViewModel()
        mockUserHoldings = [
            UserHolding(symbol: "TATA", quantity: 10, ltp: 10.0, avgPrice: 200.0, close: 100.0),
            UserHolding(symbol: "MAHINDRA", quantity: 5, ltp: 210.0, avgPrice: 100.0, close: 200.0)
        ]


    }

    override func tearDown() {
        viewModel = nil
        mockUserHoldings = nil
        MockURLProtocol.responseData = nil
        MockURLProtocol.responseError = nil

        super.tearDown()
    }

    func testNumberOfUserStocks() {
        viewModel.userHoldings = mockUserHoldings
        XCTAssertEqual(viewModel.numberOfUserStocks(), mockUserHoldings.count, "Number of user stocks should match the count of mock data")
    }

    func testUserStocksAtIndex() {
        viewModel.userHoldings = mockUserHoldings
        let index = 1
        let userStock = viewModel.UserStocks(at: index)
        XCTAssertEqual(userStock?.currentValue, mockUserHoldings[index].currentValue, "User stock at index should match mock data")
    }

    func testGetInvestmentResult() {
        viewModel.userHoldings = mockUserHoldings
        let result = viewModel.getInvestmentResult()

        // Expected calculations based on mock data:
        // TATA: ltp=10.0, quantity=10, avgPrice=200.0, close=100.0
        // MAHINDRA: ltp=210.0, quantity=5, avgPrice=100.0, close=200.0

        // Total Current Value = (10.0 * 10) + (210.0 * 5) = 100 + 1050 = 1150
        // Note: Indian locale adds thousand separators
        let expectedTotalCurrentValue = "₹1,150.00"

        // Total Investment = (200.0 * 10) + (100.0 * 5) = 2000 + 500 = 2500
        let expectedTotalInvestment = "₹2,500.00"

        // Total PNL = Current Value - Total Investment = 1150 - 2500 = -1350
        let expectedTotalProfitAndLoss = "₹-1,350.00"

        // Today's PNL = sum of ((Close - LTP) * quantity)
        // TATA: (100.0 - 10.0) * 10 = 90 * 10 = 900
        // MAHINDRA: (200.0 - 210.0) * 5 = -10 * 5 = -50
        // Total: 900 + (-50) = 850
        let expectedTodaysProfitAndLoss = "₹850.00"

        XCTAssertEqual(result?.totalCurrentValue, expectedTotalCurrentValue, "Total current value should match expected")
        XCTAssertEqual(result?.totalInvestment, expectedTotalInvestment, "Total investment should match expected")
        XCTAssertEqual(result?.totalProfitAndLoss, expectedTotalProfitAndLoss, "Total profit and loss should match expected")
        XCTAssertEqual(result?.todaysProfitAndLoss, expectedTodaysProfitAndLoss, "Today's profit and loss should match expected")
    }
    
    
    func testFetchJSONSuccess() {
           let expectation = XCTestExpectation(description: "Fetch JSON success")

        viewModel.fetchJSON(from: url, decodeType: StockData.self) { result in
               switch result {
               case .success(let decodedData):
                   XCTAssertEqual(decodedData.data?.userHolding[0].symbol, "MAHABANK")
               case .failure:
                   XCTFail("Expected success but received failure")
               }
               expectation.fulfill()
           }
           
           wait(for: [expectation], timeout: 1)
       }

       func testFetchJSONFailureWithError() {
           // Simulate an error
           MockURLProtocol.responseError = NSError(domain: "NetworkError", code: -1, userInfo: nil)

           let expectation = XCTestExpectation(description: "Fetch JSON error")
           
           viewModel.fetchJSON(from: url, decodeType: String.self) { result in
               switch result {
               case .success:
                   XCTFail("Expected failure but received success")
               case .failure(let error):
                   XCTAssertEqual((error as NSError).domain, "NSCocoaErrorDomain")
               }
               expectation.fulfill()
           }
           
           wait(for: [expectation], timeout: 1)
       }

       func testFetchJSONFailureWithInvalidData() {
           // Set up invalid JSON data
           let invalidJsonData = "Invalid JSON".data(using: .utf8)
           MockURLProtocol.responseData = invalidJsonData
           MockURLProtocol.responseCode = 200

           let expectation = XCTestExpectation(description: "Fetch JSON invalid data")
           
           viewModel.fetchJSON(from: url, decodeType: String.self) { result in
               switch result {
               case .success:
                   XCTFail("Expected failure due to invalid JSON data")
               case .failure:
                   // Expecting a decoding error
                   XCTAssertTrue(true)
               }
               expectation.fulfill()
           }
           
           wait(for: [expectation], timeout: 1)
       }

}

class MockURLProtocol: URLProtocol {
    // Properties to simulate responses
    static var responseData: Data?
    static var responseError: Error?
    static var responseCode: Int = 200

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        // Simulate a response with a status code and optional data/error
        if let error = MockURLProtocol.responseError {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            let httpResponse = HTTPURLResponse(
                url: request.url!,
                statusCode: MockURLProtocol.responseCode,
                httpVersion: nil,
                headerFields: nil
            )
            client?.urlProtocol(self, didReceive: httpResponse!, cacheStoragePolicy: .notAllowed)
            
            if let data = MockURLProtocol.responseData {
                client?.urlProtocol(self, didLoad: data)
            }
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
