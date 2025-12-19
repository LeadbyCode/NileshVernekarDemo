import Foundation

class HoldingsViewModel: HoldingsViewModelProtocol {

    // MARK: - Properties

    var reloadTableView: (() -> Void)?
    var userHoldings: [UserHolding]?

    private lazy var persistenceManager = HoldingsPersistenceManager.shared

    // MARK: - Public Methods

    func numberOfUserStocks() -> Int {
        return userHoldings?.count ?? 0
    }

    func UserStocks(at index: Int) -> UserHolding? {
        return userHoldings?[index]
    }

    func loadInitialData() {
        DispatchQueue.main.async { [weak self] in
            self?.loadCachedHoldings()
            self?.fetchStock()
        }
    }

    func fetchStock() {
        fetchJSON(from: "https://35dee773a9ec441e9f38d5fc249406ce.api.mockbin.io/", decodeType: StockData.self) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let item):
                DispatchQueue.main.async {
                    self.userHoldings = item.data?.userHolding ?? []
                    self.persistenceManager.saveHoldings(item.data?.userHolding ?? [])
                    self.reloadTableView?()
                }
            case .failure(let error):
                print("Network Error:", error.localizedDescription)
                DispatchQueue.main.async {
                    self.loadCachedHoldings()
                    self.reloadTableView?()
                }
            }
        }
    }

    func getInvestmentResult() -> InvestmentResult? {
        guard let userHoldings else { return nil }

        var totalCurrentValue: Double = 0
        var totalInvestment: Double = 0
        var todaysProfitAndLoss: Double = 0

        for userHolding in userHoldings {
            totalCurrentValue += userHolding.currentValue
            totalInvestment += userHolding.investmentValue
            todaysProfitAndLoss += (Double(userHolding.close) - userHolding.ltp) * Double(userHolding.quantity)
        }

        let totalProfitAndLoss: Double = totalCurrentValue - totalInvestment

        return InvestmentResult(
            totalCurrentValue: Constants.CustomStringFormats.formatIndianCurrency(totalCurrentValue),
            totalInvestment: Constants.CustomStringFormats.formatIndianCurrency(totalInvestment),
            totalProfitAndLoss: Constants.CustomStringFormats.formatIndianCurrency(totalProfitAndLoss),
            todaysProfitAndLoss: Constants.CustomStringFormats.formatIndianCurrency(todaysProfitAndLoss)
        )
    }

    // MARK: - Private Methods

    private func loadCachedHoldings() {
        let holdings = persistenceManager.fetchHoldings()
        self.userHoldings = holdings

        if holdings.isEmpty {
            print("ℹ️ No cached data available in Core Data")
        } else {
            print("✅ Loaded \(holdings.count) holdings from Core Data (offline mode)")
        }
    }

    func fetchJSON<T: Decodable>(from urlString: String, decodeType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Status code:", httpResponse.statusCode)
            }

            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode(decodeType, from: data)
                    completion(.success(decodedData))
                } catch {
                    completion(.failure(error))
                }
            }
        }

        task.resume()
    }
}
