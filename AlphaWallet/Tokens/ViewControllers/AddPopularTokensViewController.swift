//
//  AddPopularTokensViewController.swift
//  AlphaWallet
//

import UIKit
import StatefulViewController

protocol AddPopularTokensViewControllerDelegate: class {
    func didSaveSelected(_ viewController: AddPopularTokensViewController, tokens:[ERCToken])
}

class AddPopularTokensViewController: UIViewController {
    private let assetDefinitionStore: AssetDefinitionStore
    private let sessions: ServerDictionary<WalletSession>
    private var viewModel: AddPopularTokensViewModel
    private let searchController: UISearchController
    private var isSearchBarConfigured = false
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(FungibleTokenViewCell.self)
        tableView.register(NonFungibleTokenViewCell.self)
        tableView.register(EthTokenViewCell.self)
        tableView.estimatedRowHeight = 100
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .zero
        tableView.contentInset = .zero
        tableView.contentOffset = .zero
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    private var prefersLargeTitles: Bool?
    private let notificationCenter = NotificationCenter.default
    weak var delegate: AddPopularTokensViewControllerDelegate?

    init(viewModel: AddPopularTokensViewModel, sessions: ServerDictionary<WalletSession>, assetDefinitionStore: AssetDefinitionStore) {
        self.assetDefinitionStore = assetDefinitionStore
        self.sessions = sessions
        self.viewModel = viewModel
        searchController = UISearchController(searchResultsController: nil)
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true

        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem?.width = 30
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func loadView() {
        view = tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure(viewModel: viewModel)
        setupFilteringWithKeyword()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        prefersLargeTitles = navigationController?.navigationBar.prefersLargeTitles
        navigationController?.navigationBar.prefersLargeTitles = false

        reload()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        notificationCenter.removeObserver(self)

        if isMovingFromParent || isBeingDismissed {
            if let prefersLargeTitles = prefersLargeTitles {
                //This unfortunately breaks the smooth animation if we pop back and show the large title
                navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitles
            }
            return
        }
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let change = notification.keyboardInfo else {
            return
        }

        let bottom = change.endFrame.height - UIApplication.shared.bottomSafeAreaHeight

        UIView.setAnimationCurve(change.curve)
        UIView.animate(withDuration: change.duration, animations: {
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottom, right: 0)
            self.tableView.scrollIndicatorInsets = self.tableView.contentInset
        }, completion: { _ in

        })
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let change = notification.keyboardInfo else {
            return
        }

        UIView.setAnimationCurve(change.curve)
        UIView.animate(withDuration: change.duration, animations: {
            self.tableView.contentInset = .zero
            self.tableView.scrollIndicatorInsets = self.tableView.contentInset
        }, completion: { _ in

        })
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureSearchBarOnce()
    }

    private func configure(viewModel: AddPopularTokensViewModel) {
        title = viewModel.title
        tableView.backgroundColor = viewModel.backgroundColor
        view.backgroundColor = viewModel.backgroundColor
    }

    private func reload() {
        tableView.reloadData()
    }

    @objc func save() {
        delegate?.didSaveSelected(self, tokens: viewModel.selectedTokens)
    }
    
    fileprivate func nativeTokenObject(_ ercToken: ERCToken) -> TokenObject {
        let newToken = TokenObject(
                contract: ercToken.contract,
                server: ercToken.server,
                name: ercToken.name,
                symbol: ercToken.symbol,
                decimals: ercToken.decimals,
                value: "0",
                isCustom: true,
                type: ercToken.type
        )
        return newToken
    }
}

extension AddPopularTokensViewController: StatefulViewController {
    //Always return true, otherwise users will be stuck in the assets sub-tab when they have no assets
    func hasContent() -> Bool {
        true
    }
}

extension AddPopularTokensViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfItems(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let token = viewModel.item(atIndexPath: indexPath) else { return UITableViewCell() }
        let session = sessions[token.server]
        switch token.type {
        case .nativeCryptocurrency:
            let cell: EthTokenViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure(viewModel: .init(
                token: nativeTokenObject(token),
                ticker: viewModel.ticker(for: token),
                currencyAmount: session.balanceCoordinator.viewModel.currencyAmount,
                currencyAmountWithoutSymbol: session.balanceCoordinator.viewModel.currencyAmountWithoutSymbol,
                server: token.server,
                assetDefinitionStore: assetDefinitionStore
            ))
            cell.accessoryType = viewModel.isSelected(token) ? .checkmark : .none
            return cell
        case .erc20:
            let cell: FungibleTokenViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure(viewModel: .init(token: nativeTokenObject(token),
                server: token.server,
                assetDefinitionStore: assetDefinitionStore
            ))
            cell.accessoryType = viewModel.isSelected(token) ? .checkmark : .none
            return cell
        case .erc721, .erc721ForTickets:
            let cell: NonFungibleTokenViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure(viewModel: .init(token: nativeTokenObject(token),
                server: token.server,
                assetDefinitionStore: assetDefinitionStore
            ))
            cell.accessoryType = viewModel.isSelected(token) ? .checkmark : .none
            return cell
        case .erc875:
            let cell: NonFungibleTokenViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure(viewModel: .init(
                token: nativeTokenObject(token),
                server: token.server,
                assetDefinitionStore: assetDefinitionStore
            ))
            cell.accessoryType = viewModel.isSelected(token) ? .checkmark : .none
            return cell
        }
    }

}

extension AddPopularTokensViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectIndexPath(indexPath)
        reload()
    }
    
}

extension AddPopularTokensViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.searchText = searchController.searchBar.text ?? ""
            strongSelf.reload()
        }
    }
}

///Support searching/filtering tokens with keywords. This extension is set up so it's easier to copy and paste this functionality elsewhere
extension AddPopularTokensViewController {
    private func makeSwitchToAnotherTabWorkWhileFiltering() {
        definesPresentationContext = true
    }

    private func doNotDimTableViewToReuseTableForFilteringResult() {
        searchController.dimsBackgroundDuringPresentation = false
    }

    private func wireUpSearchController() {
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    private func fixTableViewBackgroundColor() {
        let v = UIView()
        v.backgroundColor = viewModel.backgroundColor
        tableView.backgroundView = v
    }

    private func fixNavigationBarAndStatusBarBackgroundColorForiOS13Dot1() {
        view.superview?.backgroundColor = viewModel.backgroundColor
    }

    private func setupFilteringWithKeyword() {
        wireUpSearchController()
        fixTableViewBackgroundColor()
        doNotDimTableViewToReuseTableForFilteringResult()
        makeSwitchToAnotherTabWorkWhileFiltering()
    }

    //Makes a difference where this is called from. Can't be too early
    private func configureSearchBarOnce() {
        guard !isSearchBarConfigured else { return }
        isSearchBarConfigured = true

        if let placeholderLabel = searchController.searchBar.firstSubview(ofType: UILabel.self) {
            placeholderLabel.textColor = Colors.lightGray
        }
        if let textField = searchController.searchBar.firstSubview(ofType: UITextField.self) {
            textField.textColor = Colors.appText
            if let imageView = textField.leftView as? UIImageView {
                imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
                imageView.tintColor = Colors.appText
            }
        }
        //Hack to hide the horizontal separator below the search bar
        searchController.searchBar.superview?.firstSubview(ofType: UIImageView.self)?.isHidden = true
    }
}
