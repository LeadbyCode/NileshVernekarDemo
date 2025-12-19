import UIKit

class HoldingsViewController: UIViewController {

    // MARK: - UI Components

    private let tableView = UITableView()
    private let headerView = UIView()
    private let tableContainerView = UIView()
    private let bottomFooterView = BottomFooterView()
    private var viewModel: HoldingsViewModelProtocol = HoldingsViewModel()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .gray
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        setupBottomFooterView()
        setupHeaderView()
        setupViewModel()
        setupActivityIndicator()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }

    // MARK: - Setup Methods

    private func setupTableView() {
        tableContainerView.backgroundColor = .lightGray
        tableContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableContainerView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserHoldingTableViewCell.self, forCellReuseIdentifier: Constants.XibName.userHoldingTableViewCell)
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .gray
        tableContainerView.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tableContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),

            tableView.leadingAnchor.constraint(equalTo: tableContainerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: tableContainerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: tableContainerView.bottomAnchor)
        ])
    }

    private func setupHeaderView() {
        headerView.backgroundColor = UIColor(red: 19/255, green: 51/255, blue: 97/255, alpha: 1)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.layer.borderColor = UIColor.gray.cgColor
        headerView.layer.borderWidth = 0.5
        view.addSubview(headerView)

        let profileImageView = createImageView(systemName: "person.circle", size: 25)
        let portfolioLabel = createLabel(text: "Portfolio", fontSize: 18)
        let sortImageView = createImageView(named: "updown", size: 20)
        let searchImageView = createImageView(systemName: "magnifyingglass", size: 20)

        headerView.addSubview(profileImageView)
        headerView.addSubview(portfolioLabel)
        headerView.addSubview(sortImageView)
        headerView.addSubview(searchImageView)

        let positionsButton = createButton(title: "POSITIONS", isSelected: false)
        let holdingsButton = createButton(title: "HOLDINGS", isSelected: true)

        positionsButton.addTarget(self, action: #selector(positionsButtonTapped), for: .touchUpInside)
        holdingsButton.addTarget(self, action: #selector(holdingsButtonTapped), for: .touchUpInside)

        headerView.addSubview(positionsButton)
        headerView.addSubview(holdingsButton)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 150),
            headerView.bottomAnchor.constraint(equalTo: tableView.topAnchor),

            profileImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10),
            profileImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            portfolioLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            portfolioLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            searchImageView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            searchImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            sortImageView.trailingAnchor.constraint(equalTo: searchImageView.leadingAnchor, constant: -30),
            sortImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            positionsButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            positionsButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            positionsButton.trailingAnchor.constraint(equalTo: headerView.centerXAnchor),
            positionsButton.heightAnchor.constraint(equalToConstant: 50),

            holdingsButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            holdingsButton.leadingAnchor.constraint(equalTo: headerView.centerXAnchor),
            holdingsButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            holdingsButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupBottomFooterView() {
        tableContainerView.addSubview(bottomFooterView)
        bottomFooterView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bottomFooterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomFooterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomFooterView.bottomAnchor.constraint(equalTo: tableContainerView.bottomAnchor)
        ])
    }

    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupViewModel() {
        viewModel.reloadTableView = { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.activityIndicator.stopAnimating()
                let result = self.viewModel.getInvestmentResult() ?? InvestmentResult(
                    totalCurrentValue: "",
                    totalInvestment: "",
                    totalProfitAndLoss: "",
                    todaysProfitAndLoss: ""
                )
                self.bottomFooterView.bindDataToExpendedView(for: result)
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Helper Methods

    private func createImageView(systemName: String? = nil, named: String? = nil, size: CGFloat) -> UIImageView {
        let imageView = UIImageView()
        if let systemName = systemName {
            imageView.image = UIImage(systemName: systemName)
        } else if let named = named {
            imageView.image = UIImage(named: named)
        }
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: size).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: size).isActive = true
        return imageView
    }

    private func createLabel(text: String, fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func createButton(title: String, isSelected: Bool) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false

        if isSelected {
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .bold),
                .foregroundColor: UIColor.black,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .baselineOffset: 12
            ]
            let attributedString = NSMutableAttributedString(string: title, attributes: attrs)
            button.setAttributedTitle(attributedString, for: .normal)
        } else {
            button.setTitle(title, for: .normal)
            button.setTitleColor(.gray, for: .normal)
        }

        return button
    }

    private func loadData() {
        activityIndicator.startAnimating()
        Task { @MainActor in
            viewModel.loadInitialData()
        }
    }

    // MARK: - Actions

    @objc private func positionsButtonTapped() {
        print("Positions button tapped")
    }

    @objc private func holdingsButtonTapped() {
        print("Holdings button tapped")
    }
}

// MARK: - UITableViewDataSource

extension HoldingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfUserStocks()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.XibName.userHoldingTableViewCell,
            for: indexPath
        ) as? UserHoldingTableViewCell else {
            return UITableViewCell()
        }

        cell.userHoldingdata = viewModel.UserStocks(at: indexPath.row)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension HoldingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
