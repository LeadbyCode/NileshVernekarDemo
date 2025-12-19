

import Foundation

protocol HoldingsViewModelProtocol {
    var reloadTableView: (() -> Void)? { get set }
    func fetchStock()
    func loadInitialData()
    func numberOfUserStocks() -> Int
    func UserStocks(at index: Int) -> UserHolding?
    func getInvestmentResult() -> InvestmentResult?
}
