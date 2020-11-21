import UIKit

class RadioServerViewCell: ServerViewCell {

    private var circleView: Radio = {
        var circle = Radio(color: #colorLiteral(red: 0.2156862745, green: 0.568627451, blue: 0.9647058824, alpha: 1))
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        return circle
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        if let stackView = contentView.subviews[0] as? UIStackView {
            stackView.addArrangedSubview(circleView)
            NSLayoutConstraint.activate([
                circleView.widthAnchor.constraint(equalToConstant: 17),
                circleView.centerYAnchor.constraint(equalToSystemSpacingBelow: stackView.centerYAnchor, multiplier: 0)
            ])
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setAccessoryType(type: UITableViewCell.AccessoryType) {
        circleView.isHidden = type == .none
    }
}
