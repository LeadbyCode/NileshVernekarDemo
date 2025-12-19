import UIKit

class BottomFooterView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    private let profitAndLossTextLabel = UILabel()
    private let profitAndLossValueLable = UILabel()
    private let expandCollapseButton = UIButton(type: .system)
    private var investmentResult: InvestmentResult?

    private let tableView = UITableView()
    private let separatorLine = UIView()
    
    private var isExpanded = false
    private var heightConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)

        // Add border and corner radius
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.lightGray.cgColor
        layer.cornerRadius = 4.0
        layer.masksToBounds = true

        configureLabels()
        configureButton()
        
        addSubview(profitAndLossTextLabel)
        addSubview(expandCollapseButton)
        addSubview(profitAndLossValueLable)
        addSubview(tableView)  // Add table view
        addSubview(separatorLine)  // Add separator line

        // Configure separator line
        separatorLine.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)

        setupConstraints()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ExpandedFooterTableViewCell.self, forCellReuseIdentifier: "ExpandedFooterTableViewCell")
        tableView.isHidden = true // Initially hidden
        tableView.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        tableView.separatorStyle = .none
        tableView.separatorColor = .clear
        tableView.separatorInset = .zero
        tableView.layer.borderWidth = 0

        separatorLine.isHidden = true // Initially hidden
    }
    func bindDataToExpendedView(for investmentResult: InvestmentResult){
        self.investmentResult = investmentResult

        self.profitAndLossTextLabel.text = "Profit & Loss* "
        self.profitAndLossValueLable.text = investmentResult.totalProfitAndLoss

        // Apply color based on profit/loss
        let plText = investmentResult.totalProfitAndLoss
        if plText.hasPrefix("-") || plText.contains("-₹") {
            self.profitAndLossValueLable.textColor = .red
        } else {
            let cleanText = plText.replacingOccurrences(of: "₹", with: "").replacingOccurrences(of: ",", with: "")
            if let value = Double(cleanText), value != 0 {
                self.profitAndLossValueLable.textColor = value > 0 ? UIColor(red: 0/255, green: 128/255, blue: 0/255, alpha: 1) : .red
            } else {
                self.profitAndLossValueLable.textColor = .black
            }
        }

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLabels() {
        profitAndLossTextLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        profitAndLossValueLable.font = UIFont.systemFont(ofSize: 12, weight: .regular)
    }
    
    private func configureButton() {
        // Use SF Symbol for chevron up with smaller size
        let configuration = UIImage.SymbolConfiguration(pointSize: 10, weight: .regular)
        let chevronUpImage = UIImage(systemName: "chevron.up", withConfiguration: configuration)
        expandCollapseButton.setImage(chevronUpImage, for: .normal)
        expandCollapseButton.tintColor = .black
        expandCollapseButton.contentHorizontalAlignment = .center
        expandCollapseButton.addTarget(self, action: #selector(toggleExpandCollapse), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        profitAndLossTextLabel.translatesAutoresizingMaskIntoConstraints = false
        profitAndLossValueLable.translatesAutoresizingMaskIntoConstraints = false
        expandCollapseButton.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            profitAndLossTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            profitAndLossTextLabel.centerYAnchor.constraint(equalTo: bottomAnchor, constant: -30),

            expandCollapseButton.leadingAnchor.constraint(equalTo: profitAndLossTextLabel.trailingAnchor), // Reduced spacing
                expandCollapseButton.centerYAnchor.constraint(equalTo: profitAndLossTextLabel.centerYAnchor),


            profitAndLossValueLable.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            profitAndLossValueLable.centerYAnchor.constraint(equalTo: profitAndLossTextLabel.centerYAnchor),
            
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: separatorLine.topAnchor),
            tableView.topAnchor.constraint(equalTo: topAnchor, constant: 5),

            separatorLine.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            separatorLine.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            separatorLine.bottomAnchor.constraint(equalTo: profitAndLossTextLabel.topAnchor, constant: -15),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
        ])
        
        heightConstraint = heightAnchor.constraint(equalToConstant: 60)
        heightConstraint.isActive = true
    }
    
    @objc private func toggleExpandCollapse() {
        isExpanded.toggle()

        // Update button image with SF Symbols and smaller size
        let configuration = UIImage.SymbolConfiguration(pointSize: 10, weight: .regular)
        let chevronImage = isExpanded ?
            UIImage(systemName: "chevron.down", withConfiguration: configuration) :
            UIImage(systemName: "chevron.up", withConfiguration: configuration)
        expandCollapseButton.setImage(chevronImage, for: .normal)

        let newHeight: CGFloat = isExpanded ? 180 : 60

        UIView.animate(withDuration: 0.3, animations: {
            self.heightConstraint.constant = newHeight
            self.layoutIfNeeded()
        })

        tableView.isHidden = !isExpanded
        separatorLine.isHidden = !isExpanded
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExpandedFooterTableViewCell", for: indexPath) as? ExpandedFooterTableViewCell else {
            return UITableViewCell()
        }
        
        switch indexPath.row {
        case 0:
            cell.configureCell(investmentText: investmentResult?.totalCurrentValue ?? "", amountText: "Current value*")
        case 1:
            cell.configureCell(investmentText: investmentResult?.totalInvestment ?? "", amountText: "Total investment*")
        case 2:
            cell.configureCell(investmentText: investmentResult?.todaysProfitAndLoss ?? "", amountText: "Today's Profit & Loss*")
        default:
            print("INVALID - INDEXPATH")
        }

        return  cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
}
