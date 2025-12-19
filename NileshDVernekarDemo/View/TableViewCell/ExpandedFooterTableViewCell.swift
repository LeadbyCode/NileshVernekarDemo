
import UIKit

class ExpandedFooterTableViewCell: UITableViewCell {

    // Define the two labels with specific names
    private let investmentLabel = UILabel()
    private let amountLabel = UILabel()


    var investmentLabelText: String? {
        didSet { investmentLabel.text = investmentLabelText }
    }
    var amountLabelText: String? {
        didSet { amountLabel.text = amountLabelText }
    }
    
    // Initializer for the custom table view cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        selectionStyle = .none
        separatorInset = .zero
        // Configure labels
        configureLabels()
        
        // Add labels to the content view (standard for table view cells)
        contentView.addSubview(investmentLabel)
        contentView.addSubview(amountLabel)

        // Enable Auto Layout
        investmentLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up constraints
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        // Configure labels
        configureLabels()
        
        // Add labels to the content view
        contentView.addSubview(investmentLabel)
        contentView.addSubview(amountLabel)

        // Enable Auto Layout
        investmentLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up constraints
        setupConstraints()
    }
    
    private func configureLabels() {
        investmentLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        amountLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            amountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            amountLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
        ])

        NSLayoutConstraint.activate([
            investmentLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            investmentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }

    func configureCell(investmentText: String, amountText: String) {
        investmentLabel.text = investmentText
        amountLabel.text = amountText

        // Apply color only for "Today's Profit & Loss*"
        if amountText == "Today's Profit & Loss*" {
            if investmentText.hasPrefix("-") || investmentText.contains("-₹") {
                investmentLabel.textColor = .red
            } else {
                let cleanText = investmentText.replacingOccurrences(of: "₹", with: "").replacingOccurrences(of: ",", with: "")
                if let value = Double(cleanText), value != 0 {
                    investmentLabel.textColor = value > 0 ? UIColor(red: 0/255, green: 128/255, blue: 0/255, alpha: 1) : .red
                } else {
                    investmentLabel.textColor = .black
                }
            }
        } else {
            investmentLabel.textColor = .black
        }
    }
}
