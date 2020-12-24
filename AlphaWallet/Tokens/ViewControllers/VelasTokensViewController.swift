//
//  VelasTokensViewController.swift
//  AlphaWallet
//

import UIKit

protocol VelasTokensViewControllerDelegate: TokensViewControllerDelegate {
    func didAddPopularTokenTapped(network: RPCServer)
}

class VelasTokensViewController: TokensViewController {
    
    let isSectionMode = true
    
    override var viewModel: TokensViewModel {
        get {
            return super.viewModel
        }
        set {
            super.viewModel = VelasTokensViewModel(filterTokensCoordinator: newValue.filterTokensCoordinator, tokens: newValue.tokens, tickers: newValue.tickers)
        }
    }
    
    override init(sessions: ServerDictionary<WalletSession>, account: Wallet, tokenCollection: TokenCollection, assetDefinitionStore: AssetDefinitionStore, eventsDataStore: EventsDataStoreProtocol, filterTokensCoordinator: FilterTokensCoordinator, config: Config) {
        super.init(sessions: sessions, account: account, tokenCollection: tokenCollection, assetDefinitionStore: assetDefinitionStore, eventsDataStore: eventsDataStore, filterTokensCoordinator: filterTokensCoordinator, config: config)
        tableView.registerHeaderFooterView(GroupNetworkTokensHeaderView.self)
        self.viewModel = VelasTokensViewModel(filterTokensCoordinator: filterTokensCoordinator, tokens: [], tickers: .init())
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
        return isSectionMode ? 70 : 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section < sections.count {
            return super.tableView(tableView, viewForHeaderInSection: section)
        }
        let header: GroupNetworkTokensHeaderView = tableView.dequeueReusableHeaderFooterView()
        let tokenSection = section - sections.count
        let item = viewModel.item(for: 0, section: tokenSection)
        let configuration: HeaderServer = isSectionMode ? .Server(server: item.server) : .Hide(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        header.configHeader(configuration)
        header.delegate = self
        return header
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let section = indexPath.section
        if section < sections.count {
            return super.tableView(tableView, trailingSwipeActionsConfigurationForRowAt: indexPath)
        }
        return trailingSwipeActionsConfiguration(forRowAt: IndexPath(row: indexPath.row, section: section - sections.count))
    }
}

extension VelasTokensViewController : GroupNetworkHeaderViewDelegate {
   
    func didTapAddToken(_ headerView: GroupNetworkTokensHeaderView, network: RPCServer?) {
        if let selectedNetwork = network {
            (delegate as? VelasTokensViewControllerDelegate)?.didAddPopularTokenTapped(network: selectedNetwork)
        }
    }

}
