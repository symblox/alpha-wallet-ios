//
//  GroupNetworkTokensHeaderView.swift
//  AlphaWallet
//

import UIKit

protocol GroupNetworkHeaderViewDelegate: class {
    func didTapAddToken(_ headerView:GroupNetworkTokensHeaderView, network: RPCServer?)
}

class GroupNetworkTokensHeaderView: UITableViewHeaderFooterView {
    
    weak var delegate: GroupNetworkHeaderViewDelegate?
    private var network: RPCServer?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
     
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private lazy var tokenIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonts.bold(size: 24)
        label.textColor = .white
        label.text = "Section"
        return label
    }()
    
    private lazy var addOptionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = Fonts.semibold(size: 18)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitle("ADD +", for: .normal)
        button.titleLabel?.textAlignment = .left
        button.addTarget(self, action: #selector(handleButtonClicked(_:)), for: .touchUpInside)
        return button
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .white
        contentView.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        let stack = [tokenIconImageView, titleLabel, UIView.spacerWidth(flexible: true)].asStackView(spacing: 10, alignment: .firstBaseline)
        stack.translatesAutoresizingMaskIntoConstraints = false
        let addStackView = [UIView.spacerWidth(flexible: true), addOptionButton].asStackView(alignment: .trailing)
        addStackView.translatesAutoresizingMaskIntoConstraints = false
        let verticalStack = [stack, addStackView].asStackView(axis: .vertical, spacing: 10)
        verticalStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(verticalStack)
        NSLayoutConstraint.activate([
            tokenIconImageView.widthAnchor.constraint(equalToConstant: 30),
            tokenIconImageView.heightAnchor.constraint(equalToConstant: 30),
            verticalStack.anchorsConstraint(to: contentView, edgeInsets: .init(top: 10, left: 20, bottom: 10, right: 16)),
        ])
    }
    
    public func configHeader(_ header: HeaderServer) {
        switch header {
        case .Server(let server, let image,  let name):
            network = server
            titleLabel.text = name
            tokenIconImageView.image = image
            addOptionButton.isHidden = server == nil
            contentView.backgroundColor = sectionColor()
        case .Hide(let color):
            contentView.backgroundColor = color
            network = nil
        }
    }

    @objc private func handleButtonClicked(_ button: UIButton) {
        delegate?.didTapAddToken(self, network: self.network)
    }
    
    private func sectionColor() -> UIColor {
        guard let legalNetwork = network else {
            return #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        }
        if legalNetwork.isVelasFamily {
            return #colorLiteral(red: 0.2666666667, green: 0.4235294118, blue: 0.7843137255, alpha: 1)
        } else if legalNetwork == .main {
            return #colorLiteral(red: 1, green: 0.5843137255, blue: 0, alpha: 1)
        } else {
            return #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        }
    }
}
enum HeaderServer {
    case Server(server: RPCServer? , icon: UIImage? ,name: String)
    case Hide(color: UIColor)
 }
