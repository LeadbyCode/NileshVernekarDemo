

import Foundation

struct StockData: Codable {
    var data: Stock?
}

struct Stock: Codable {
    var userHolding: [UserHolding]
}

struct UserHolding: Codable {
    var symbol: String
    var quantity: Int
    var ltp, avgPrice, close: Double

    var currentValue: Double {
        return (ltp) * Double(quantity)
    }
    var investmentValue: Double {
        return avgPrice * Double(quantity)
    }
    var profitAndLoss: Double {
        return currentValue - investmentValue
    }
}

// MARK: Local DataModals
struct InvestmentResult {
    let totalCurrentValue: String
    let totalInvestment: String
    let totalProfitAndLoss: String
    let todaysProfitAndLoss: String
}
