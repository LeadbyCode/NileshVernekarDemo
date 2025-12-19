import UIKit

class UserHoldingTableViewCell: UITableViewCell {

    // MARK: - UI Components

    private let symbolLabel = UILabel()
    private let ltpLabel = UILabel()
    private let quantityStackView = CustomView(smallLabelText: "NET QTY:", largeLabelText: "")
    private let profitAndLossLabelView = CustomView(smallLabelText: "P&L:", largeLabelText: "")

    // MARK: - Properties

    var userHoldingdata: UserHolding? {
        didSet {
            bindCellData(for: userHoldingdata)
        }
    }

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        symbolLabel.text = nil
        ltpLabel.attributedText = nil
        quantityStackView.reset()
        profitAndLossLabelView.reset()
    }

    // MARK: - Setup Methods

    private func setupUI() {
        ltpLabel.textAlignment = .right
        symbolLabel.font = UIFont.systemFont(ofSize: Constants.FontConstant.commonFontHeight + 2, weight: .bold)

        contentView.addSubview(symbolLabel)
        contentView.addSubview(ltpLabel)
        contentView.addSubview(quantityStackView)
        contentView.addSubview(profitAndLossLabelView)

        symbolLabel.translatesAutoresizingMaskIntoConstraints = false
        ltpLabel.translatesAutoresizingMaskIntoConstraints = false
        quantityStackView.translatesAutoresizingMaskIntoConstraints = false
        profitAndLossLabelView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            symbolLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            symbolLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),

            ltpLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            ltpLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),

            quantityStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            quantityStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            profitAndLossLabelView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            profitAndLossLabelView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            profitAndLossLabelView.leadingAnchor.constraint(equalTo: ltpLabel.leadingAnchor)
        ])
    }

    // MARK: - Data Binding

    private func bindCellData(for dataForCurrentCell: UserHolding?) {
        guard let dataForCurrentCell else { return }
        symbolLabel.text = dataForCurrentCell.symbol.uppercased()
        ltpLabel.attributedText = getAttributedText(with: "LTP", and: dataForCurrentCell.ltp)
        quantityStackView.updateNetQty("\(dataForCurrentCell.quantity)", "NET QTY:")
        profitAndLossLabelView.updateProfitLossLabel(dataForCurrentCell.profitAndLoss, "P&L:")
    }

    private func getAttributedText(with prefix: String, and amount: Double) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString()

        let prefixAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .thin)
        ]
        let prefixAttributedString = NSAttributedString(string: "\(prefix): ", attributes: prefixAttributes)
        attributedString.append(prefixAttributedString)

        let formattedAmount = Constants.CustomStringFormats.formatIndianCurrency(amount)
        let amountAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15, weight: .regular)
        ]
        let boldedString = NSAttributedString(string: formattedAmount, attributes: amountAttributes)
        attributedString.append(boldedString)

        return attributedString
    }
}

// MARK: - CustomView

class CustomView: UIView {

    // MARK: - UI Components

    private let smallLabel = UILabel()
    private let largeLabel = UILabel()
    private let labelStackView = UIStackView()

    // MARK: - Initialization

    init(smallLabelText: String, largeLabelText: String) {
        super.init(frame: .zero)
        smallLabel.text = smallLabelText
        largeLabel.text = largeLabelText
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Methods

    private func setupUI() {
        configureLabels()
        configureStackView()
        addSubview(labelStackView)
        setupConstraints()
    }

    private func configureLabels() {
        smallLabel.font = UIFont.systemFont(ofSize: 11, weight: .thin)
        largeLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        smallLabel.textAlignment = .right
        largeLabel.textAlignment = .right
    }

    private func configureStackView() {
        labelStackView.axis = .horizontal
        labelStackView.alignment = .center
        labelStackView.spacing = 2
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        labelStackView.addArrangedSubview(smallLabel)
        labelStackView.addArrangedSubview(largeLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            labelStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            labelStackView.topAnchor.constraint(equalTo: topAnchor),
            labelStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            labelStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // MARK: - Public Methods

    func updateProfitLossLabel(_ amount: Double, _ prefix: String) {
        smallLabel.text = prefix + " "
        largeLabel.attributedText = createProfitLossAttributedText(amount: amount)
    }

    func updateNetQty(_ quantity: String, _ prefix: String) {
        smallLabel.text = prefix + " "
        largeLabel.text = quantity
    }

    func reset() {
        smallLabel.text = nil
        largeLabel.text = nil
        largeLabel.attributedText = nil
        largeLabel.textColor = .black
    }

    // MARK: - Private Methods

    private func createProfitLossAttributedText(amount: Double) -> NSMutableAttributedString {
        let formattedAmount = Constants.CustomStringFormats.formatIndianCurrency(amount)
        let color: UIColor = amount < 0 ? .red : UIColor(red: 0/255, green: 128/255, blue: 0/255, alpha: 1)
        let amountAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15, weight: .regular),
            .foregroundColor: color
        ]

        return NSMutableAttributedString(string: formattedAmount, attributes: amountAttributes)
    }
}
