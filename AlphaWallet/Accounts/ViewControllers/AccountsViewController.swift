// Copyright © 2018 Stormbird PTE. LTD.

import UIKit
import PromiseKit

protocol AccountsViewControllerDelegate: class {
    func didSelectAccount(account: Wallet, in viewController: AccountsViewController)
    func didDeleteAccount(account: Wallet, in viewController: AccountsViewController)
    func didSelectInfoForAccount(account: Wallet, sender: UIView, in viewController: AccountsViewController)
}

class AccountsViewController: UIViewController {
    private let roundedBackground = RoundedBackground()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var viewModel: AccountsViewModel {
        AccountsViewModel(config: config, hdWallets: hdWallets, keystoreWallets: keystoreWallets, watchedWallets: watchedWallets)
    }
    private var hdWallets: [Wallet] = []
    private var keystoreWallets: [Wallet] = []
    private var watchedWallets: [Wallet] = []
    private var balances: [AlphaWallet.Address: Balance?] = [:]
    private let config: Config
    private let keystore: Keystore
    private let balanceCoordinator: GetNativeCryptoCurrencyBalanceCoordinator
    weak var delegate: AccountsViewControllerDelegate?
    var allowsAccountDeletion: Bool = false
    var hasWallets: Bool {
        return !keystore.wallets.isEmpty
    }

    init(config: Config, keystore: Keystore, balanceCoordinator: GetNativeCryptoCurrencyBalanceCoordinator) {
        self.config = config
        self.keystore = keystore
        self.balanceCoordinator = balanceCoordinator
        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = Colors.appBackground
        roundedBackground.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(roundedBackground)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = GroupedTable.Color.background
        tableView.register(AccountViewCell.self)
        roundedBackground.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: roundedBackground.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: roundedBackground.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: roundedBackground.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ] + roundedBackground.createConstraintsWithContainer(view: view))

        fetch()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetch()
        refreshWalletBalances()
    }

    func fetch() {
        hdWallets = keystore.wallets.filter { keystore.isHdWallet(wallet: $0) }.sorted { $0.address.eip55String < $1.address.eip55String }
        keystoreWallets = keystore.wallets.filter { keystore.isKeystore(wallet: $0) }.sorted { $0.address.eip55String < $1.address.eip55String }
        watchedWallets = keystore.wallets.filter { keystore.isWatched(wallet: $0) }.sorted { $0.address.eip55String < $1.address.eip55String }
        tableView.reloadData()
        configure(viewModel: viewModel)
    }

    func configure(viewModel: AccountsViewModel) {
        tableView.dataSource = self
        title = viewModel.title
    }

    private func account(for indexPath: IndexPath) -> Wallet {
        switch AccountViewTableSectionHeader.HeaderType(rawValue: indexPath.section) {
        case .some(.hdWallet):
            return viewModel.hdWallets[indexPath.row]
        case .some(.keystoreWallet):
            return viewModel.keystoreWallets[indexPath.row]
        case .some(.watchedWallet):
            return viewModel.watchedWallets[indexPath.row]
        case .none:
            //TODO really shouldn't be here
            return viewModel.hdWallets.first ?? (viewModel.keystoreWallets.first ?? viewModel.watchedWallets[0])
        }
    }

    private func confirmDelete(account: Wallet) {
        confirm(
            title: R.string.localizable.accountsConfirmDeleteTitle(),
            message: R.string.localizable.accountsConfirmDeleteMessage(),
            okTitle: R.string.localizable.accountsConfirmDeleteOkTitle(),
            okStyle: .destructive
        ) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success:
                strongSelf.delete(account: account)
            case .failure: break
            }
        }
    }

    private func delete(account: Wallet) {
        navigationController?.displayLoading(text: R.string.localizable.deleting())
        let result = keystore.delete(wallet: account)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.navigationController?.hideLoading()

            switch result {
            case .success:
                strongSelf.fetch()
                strongSelf.delegate?.didDeleteAccount(account: account, in: strongSelf)
            case .failure(let error):
                strongSelf.displayError(error: error)
            }
        }
    }

    private func refreshWalletBalances() {
        let addresses = (hdWallets + keystoreWallets + watchedWallets).compactMap { $0.address }

        let group = DispatchGroup()
        
        for address in addresses {
            group.enter()

            balanceCoordinator.getBalance(for: address) { [weak self] result in
                self?.balances[address] = result.value
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.tableView.reloadData()
        }
    }

    private func getAccountViewModels(for path: IndexPath) -> AccountViewModel {
        let account = self.account(for: path)
        let walletName = viewModel.walletName(forAccount: account)
        let balance = self.balances[account.address].flatMap { $0 }
        let model = AccountViewModel(wallet: account, current: keystore.currentWallet, walletBalance: balance, server: balanceCoordinator.server, walletName: walletName)
        return model
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }
}

extension AccountsViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch AccountViewTableSectionHeader.HeaderType(rawValue: section) {
        case .some(.hdWallet):
            return viewModel.hdWallets.count
        case .some(.keystoreWallet):
            return viewModel.keystoreWallets.count
        case .some(.watchedWallet):
            return viewModel.watchedWallets.count
        case .none:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AccountViewCell = tableView.dequeueReusableCell(for: indexPath)
        var cellViewModel = getAccountViewModels(for: indexPath)
        cell.configure(viewModel: cellViewModel)
        cell.account = cellViewModel.wallet

        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
        gesture.minimumPressDuration = 0.6
        cell.addGestureRecognizer(gesture)

        let serverToResolveEns = RPCServer.main
        let address = cellViewModel.address
        ENSReverseLookupCoordinator(server: serverToResolveEns).getENSNameFromResolver(forAddress: address) { result in
            guard let ensName = result.value else { return }
            //Cell might have been reused. Check
            guard let cellAddress = cell.viewModel?.address, cellAddress.sameContract(as: address) else { return }
            cellViewModel.ensName = ensName
            cell.configure(viewModel: cellViewModel)
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard allowsAccountDeletion else { return false }
        switch AccountViewTableSectionHeader.HeaderType(rawValue: indexPath.section) {
        case .some(.hdWallet):
            return keystore.currentWallet != viewModel.hdWallets[indexPath.row]
        case .some(.keystoreWallet):
            return keystore.currentWallet != viewModel.keystoreWallets[indexPath.row]
        case .some(.watchedWallet):
            return keystore.currentWallet != viewModel.watchedWallets[indexPath.row]
        case .none:
            return false
        }
    }

    @objc private func didLongPress(_ recognizer: UILongPressGestureRecognizer) {
        guard let cell = recognizer.view as? AccountViewCell, let account = cell.account, recognizer.state == .began else { return }

        delegate?.didSelectInfoForAccount(account: account, sender: cell, in: self)
    }
}

extension AccountsViewController: UITableViewDelegate {
    //We don't show the section headers unless there are 2 "types" of wallets
    private func shouldHideAllSectionHeaders() -> Bool {
        if viewModel.keystoreWallets.isEmpty && viewModel.watchedWallets.isEmpty {
            return true
        }
        if viewModel.hdWallets.isEmpty && viewModel.keystoreWallets.isEmpty {
            return true
        }
        if viewModel.hdWallets.isEmpty && viewModel.watchedWallets.isEmpty {
            return true
        }
        return false
    }

    private func shouldHideHeader(in section: Int) -> (shouldHide: Bool, section: AccountViewTableSectionHeader.HeaderType)? {
        let shouldHideSectionHeaders = shouldHideAllSectionHeaders()
        switch AccountViewTableSectionHeader.HeaderType(rawValue: section) {
        case .some(.hdWallet):
            return (viewModel.hdWallets.isEmpty, .hdWallet)
        case .some(.keystoreWallet):
            return (shouldHideSectionHeaders || viewModel.keystoreWallets.isEmpty, .keystoreWallet)
        case .some(.watchedWallet):
            return (shouldHideSectionHeaders || viewModel.watchedWallets.isEmpty, .watchedWallet)
        case .none:
            break
        }
        return nil
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch shouldHideHeader(in: section) {
        case .some(let value):
            let headerView = AccountViewTableSectionHeader()
            headerView.configure(type: value.section, shouldHide: value.shouldHide)
            return headerView
        case .none:
            return nil
        }
    }

    //Hide the footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        nil
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let copyAction = UIContextualAction(style: .normal, title: R.string.localizable.copyAddress()) { _, _, complete in
            let account = self.account(for: indexPath)
            UIPasteboard.general.string = account.address.eip55String
            complete(true)
        }

        copyAction.image = R.image.copy()?.withRenderingMode(.alwaysTemplate)
        copyAction.backgroundColor = R.color.azure()

        let deleteAction = UIContextualAction(style: .normal, title: R.string.localizable.accountsConfirmDeleteAction()) { _, _, complete in
            let account = self.account(for: indexPath)
            self.confirmDelete(account: account)

            complete(true)
        }

        deleteAction.image = R.image.close()?.withRenderingMode(.alwaysTemplate)
        deleteAction.backgroundColor = R.color.danger()

        let configuration = UISwipeActionsConfiguration(actions: [copyAction, deleteAction])
        configuration.performsFirstActionWithFullSwipe = true

        return configuration
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let account = self.account(for: indexPath)
        guard keystore.currentWallet != account else { return }

        delegate?.didSelectAccount(account: account, in: self)
    }
}
