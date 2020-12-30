//
//  VelasTokensViewController.swift
//  AlphaWallet
//

import UIKit
import MBProgressHUD

protocol VelasTokensViewControllerDelegate: TokensViewControllerDelegate {
    func didAddPopularTokenTapped(network: RPCServer)
}

class VelasTokensViewController: TokensViewController {
    
    let isSectionMode = true
    let config: Config
    
    override var viewModel: TokensViewModel {
        get {
            return super.viewModel
        }
        set {
            super.viewModel = VelasTokensViewModel(filterTokensCoordinator: newValue.filterTokensCoordinator, tokens: newValue.tokens, tickers: newValue.tickers)
            (self.viewModel as? VelasTokensViewModel)?.config = config
        }
    }
    
    override init(sessions: ServerDictionary<WalletSession>, account: Wallet, tokenCollection: TokenCollection, assetDefinitionStore: AssetDefinitionStore, eventsDataStore: EventsDataStoreProtocol, filterTokensCoordinator: FilterTokensCoordinator, config: Config, walletConnectCoordinator: WalletConnectCoordinator) {
        self.config = config

        super.init(sessions: sessions, account: account, tokenCollection: tokenCollection, assetDefinitionStore: assetDefinitionStore, eventsDataStore: eventsDataStore, filterTokensCoordinator: filterTokensCoordinator, config: config, walletConnectCoordinator: walletConnectCoordinator)

        tableView.registerHeaderFooterView(GroupNetworkTokensHeaderView.self)
        self.viewModel = VelasTokensViewModel(filterTokensCoordinator: filterTokensCoordinator, tokens: [], tickers: .init())
        (self.viewModel as? VelasTokensViewModel)?.config = config
        sections = [.addHideToken, .tokens]
        navigationItem.searchController = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // TableView Delegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var section = indexPath.section
        if section < sections.count {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        section -= sections.count
        let token = viewModel.item(for: indexPath.row, section: section)
        let server = token.server
        let session = sessions[server]
        switch token.type {
        case .nativeCryptocurrency:
            let cell: EthTokenViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure(viewModel: .init( token: token,
                           ticker: viewModel.ticker(for: token),
                           currencyAmount: session.balanceCoordinator.viewModel.currencyAmount,
                           currencyAmountWithoutSymbol: session.balanceCoordinator.viewModel.currencyAmountWithoutSymbol,
                           server: server,
                           assetDefinitionStore: assetDefinitionStore))
                return cell
        case .erc20:
                let cell: FungibleTokenViewCell = tableView.dequeueReusableCell(for: indexPath)
                cell.configure(viewModel: .init(token: token, server: server, assetDefinitionStore: assetDefinitionStore))
                return cell
        case .erc721, .erc721ForTickets:
                let cell: NonFungibleTokenViewCell = tableView.dequeueReusableCell(for: indexPath)
                cell.configure(viewModel: .init(token: token, server: server, assetDefinitionStore: assetDefinitionStore))
                return cell
        case .erc875:
                let cell: NonFungibleTokenViewCell = tableView.dequeueReusableCell(for: indexPath)
                cell.configure(viewModel: .init(token: token, server: server, assetDefinitionStore: assetDefinitionStore))
                return cell
        }
    }
    
    // TableView Datasource
    override func numberOfSections(in tableView: UITableView) -> Int {
        super.numberOfSections(in: tableView) + viewModel.numberOfGroup()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < sections.count {
            if sections[section] == .tokens {
                return 0
            }
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
        let tokenSection = section - sections.count
        return viewModel.numberItemsOfGroup(tokenSection)
    }
}

extension VelasTokensViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let validSection = section < sections.count ? indexPath : IndexPath(row: indexPath.row, section: section - sections.count)
        super.tableView(tableView, didSelectRowAt: validSection)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section < sections.count {
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
        return isSectionMode ? GroupNetworkTokensHeaderView.entireHeaderHeight : 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section < sections.count {
            return super.tableView(tableView, viewForHeaderInSection: section)
        }
        let header: GroupNetworkTokensHeaderView = tableView.dequeueReusableHeaderFooterView()
        let tokenSection = section - sections.count
        let server = (viewModel as? VelasTokensViewModel)?.serverForSection(tokenSection)
        var address = server != nil ? currentAccount.address.eip55String : ""
        if server != nil {
            address = VelasConvertUtil.convertVlxStringIfNeed(server: server!, address: address)
        }
        let serverInfo = HeaderInfo(server: server, image: nil, name: server?.name ?? "Other", subTitle: address.truncatedMiddle)
        let serverHeaderConfig : HeaderServer = .Server(serverInfo)
        let configuration: HeaderServer = isSectionMode ? serverHeaderConfig : .Hide(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        header.configHeader(configuration)
        header.delegate = self
        return header
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let section = indexPath.section
        if section < sections.count {
            return super.tableView(tableView, trailingSwipeActionsConfigurationForRowAt: indexPath)
        }
        return velasTrailingSwipeActionsConfiguration(forRowAt: indexPath)
    }
    
    func velasTrailingSwipeActionsConfiguration(forRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let title = R.string.localizable.walletsHideTokenTitle()
        let hideAction = UIContextualAction(style: .destructive, title: title) { [weak self] (_, _, completionHandler) in
            guard let strongSelf = self else { return }
            let tokenSection = indexPath.section >= strongSelf.sections.count ? indexPath.section - strongSelf.sections.count : indexPath.section
            let token = strongSelf.viewModel.item(for: indexPath.row, section: tokenSection)
            strongSelf.delegate?.didHide(token: token, in: strongSelf)
            let didHideToken = strongSelf.viewModel.markTokenHidden(token: token)
            strongSelf.reloadTableData()
            completionHandler(didHideToken)
        }

        hideAction.backgroundColor = R.color.danger()
        hideAction.image = R.image.hideToken()
        let configuration = UISwipeActionsConfiguration(actions: [hideAction])
        configuration.performsFirstActionWithFullSwipe = true

        return configuration
    }
}

extension VelasTokensViewController : GroupNetworkHeaderViewDelegate {
   
    func didTapAddToken(_ headerView: GroupNetworkTokensHeaderView, network: RPCServer?) {
        if let selectedNetwork = network {
            (delegate as? VelasTokensViewControllerDelegate)?.didAddPopularTokenTapped(network: selectedNetwork)
        }
    }
    
    func didTapHeaderName(_ headerView: GroupNetworkTokensHeaderView, network: RPCServer?) {
        
        guard let server = network else {
            return
        }
        let copiedAddress = VelasConvertUtil.convertVlxStringIfNeed(server: server, address: currentAccount.address.eip55String)
        UIPasteboard.general.string = copiedAddress
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .text
        hud.label.text = "Copied \(copiedAddress)"
        hud.hide(animated: true, afterDelay: 1.5)
    }

}
