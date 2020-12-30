//
//  GroupNetworkTokensHeaderView.swift
//  AlphaWallet
//

import UIKit

protocol GroupNetworkHeaderViewDelegate: class {
    func didTapAddToken(_ headerView:GroupNetworkTokensHeaderView, network: RPCServer?)
    func didTapHeaderName(_ headerView:GroupNetworkTokensHeaderView, network: RPCServer?)
}

class GroupNetworkTokensHeaderView: UITableViewHeaderFooterView {
   
    private let addTokenTitleLeftInset: CGFloat = 7
    private let titleParentViewSideInset: CGFloat = 12
    private static let headerNameStackHeight: CGFloat = 80
    private static let addTokenStackHeight: CGFloat = 30
    
    public static var entireHeaderHeight: CGFloat {
        headerNameStackHeight + addTokenStackHeight
    }
    
    weak var delegate: GroupNetworkHeaderViewDelegate?
    private var network: RPCServer?
    private var addTokenButtonStack: UIStackView?
    private var entireViewContainer: UIView?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
     
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private lazy var subtTitle: UIButton = {
        let label = UIButton()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.titleLabel?.font = Fonts.semibold(size: 14)
        label.setTitleColor(Colors.appWhite, for: .normal)
        label.addTarget(self, action: #selector(handleButtonClicked), for: .touchUpInside)
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonts.bold(size: 24)
        label.textColor = .white
        return label
    }()
    
    private lazy var addTokenButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.semanticContentAttribute = .forceRightToLeft
        button.imageView?.contentMode = .scaleAspectFit
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: addTokenTitleLeftInset)
               button.clipsToBounds = true
        button.setImage(R.image.icon_add_white(), for: .normal)
        button.contentVerticalAlignment = .center
        button.contentHorizontalAlignment = .center
        button.addTarget(self, action: #selector(handleButtonClicked), for: .touchUpInside)
        return button
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .white
        contentView.backgroundColor = .white

        let headerContainer: UIView = .init()
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.clipsToBounds = true
        headerContainer.layer.cornerRadius = 8
        entireViewContainer = headerContainer
        
        let stack = [titleLabel, subtTitle].asStackView(axis: .vertical, alignment: .leading)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let btnStack = [addTokenButton].asStackView(axis: .vertical,distribution: .fillProportionally, alignment: .trailing)
        btnStack.translatesAutoresizingMaskIntoConstraints = false
        addTokenButtonStack = btnStack
        let verticalStack = [stack, btnStack].asStackView(axis: .vertical, distribution: .fill, alignment: .fill)
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        
        headerContainer.addSubview(verticalStack)
        contentView.addSubview(headerContainer)

        NSLayoutConstraint.activate([
            headerContainer.anchorsConstraint(to: contentView, edgeInsets: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)),
            verticalStack.anchorsConstraint(to: headerContainer, edgeInsets: UIEdgeInsets(top: 10, left: titleParentViewSideInset, bottom: 8, right: titleParentViewSideInset)),
            stack.heightAnchor.constraint(equalToConstant: GroupNetworkTokensHeaderView.headerNameStackHeight),
            btnStack.heightAnchor.constraint(equalToConstant: GroupNetworkTokensHeaderView.addTokenStackHeight),
            addTokenButton.heightAnchor.constraint(equalToConstant: 30),
            addTokenButton.widthAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    public func configHeader(_ header: HeaderServer) {
        switch header {
        case .Server(let info):
            network = info?.server
            titleLabel.text = info?.name
            addTokenButton.isHidden = network == nil
            subtTitle.setTitle(info?.subTitle ?? "", for: .normal)
            entireViewContainer?.backgroundColor = sectionColor()
        case .Hide(let color):
            entireViewContainer?.backgroundColor = color
            network = nil
        }
    }

    @objc private func handleButtonClicked(_ button: UIButton) {
        if button == addTokenButton {
            delegate?.didTapAddToken(self, network: self.network)
        } else if button == subtTitle {
            delegate?.didTapHeaderName(self, network: self.network)
        }
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
    case Server(_ info: HeaderInfo?)
    case Hide(color: UIColor)
 }

struct HeaderInfo {
    let server: RPCServer?
    let image: UIImage?
    let name: String?
    let subTitle: String?
}
