// Copyright © 2019 Stormbird PTE. LTD.

import UIKit

protocol EnabledServersViewControllerDelegate: class {
    func didSelectServers(servers: [RPCServer], in viewController: EnabledServersViewController)
    func didDismiss(viewController: EnabledServersViewController)
}

class EnabledServersViewController: UIViewController {
    private let roundedBackground = RoundedBackground()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var viewModel: EnabledServersViewModel?

    weak var delegate: EnabledServersViewControllerDelegate?

    init() {
        super.init(nibName: nil, bundle: nil)

        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .save, target: self, action: #selector(done))

        view.backgroundColor = GroupedTable.Color.background

        roundedBackground.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(roundedBackground)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = GroupedTable.Color.background
        tableView.tableFooterView = UIView.tableFooterToRemoveEmptyCellSeparators()
        tableView.register(ServerViewCell.self)
        tableView.register(RadioServerViewCell.self)

        roundedBackground.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: roundedBackground.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: roundedBackground.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: roundedBackground.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ] + roundedBackground.createConstraintsWithContainer(view: view))
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            delegate?.didDismiss(viewController: self)
        } else {
            //no-op
        }
    }

    func configure(viewModel: EnabledServersViewModel) {
        self.viewModel = viewModel
        tableView.dataSource = self
        title = viewModel.title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func done() {
        guard let viewModel = viewModel else { return }
        delegate?.didSelectServers(servers: viewModel.selectedServers, in: self)
    }
}

extension EnabledServersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.numberOfGroup() ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return 0 }
        return viewModel.numberItemSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: ServerViewCell = tableView.dequeueReusableCell(for: indexPath)
        let radioCell: RadioServerViewCell = tableView.dequeueReusableCell(for: indexPath)
        if let viewModel = viewModel {
            let server = viewModel.server(for: indexPath)
            let isRadio = viewModel.getSingleSelectionKey().contains(server.chainID)
            cell = isRadio ? radioCell : cell
            let cellViewModel = ServerViewModel(server: server, selected: viewModel.isServerSelected(server))
            cell.configure(viewModel: cellViewModel)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let isUsingHeader = (viewModel?.numberOfGroup() ?? 0) > 1
        let header: UIView = isUsingHeader ? ServerHeaderView() : UIView()
        (header as? ServerHeaderView)?.config(.init(name: viewModel?.nameSection(section) ?? ""))
        if !(header is ServerHeaderView) {
            header.heightAnchor.constraint(equalToConstant: 0).isActive = true
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let viewModel = viewModel else { return nil }
        let server = viewModel.server(for: indexPath)
        var canTouch = true

        if server.isAlwayVisible {
            canTouch = viewModel.numberOfGroup() != 1
        }

        if viewModel.getSingleSelectionKey().contains(server.chainID) {
            canTouch = !viewModel.selectedServers.contains(server)
        }
        return !canTouch ? nil : indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let viewModel = viewModel else { return }
        let server = viewModel.server(for: indexPath)
        let servers: [RPCServer]
        if viewModel.getSingleSelectionKey().contains(server.chainID) {
            var lastSelecteds = viewModel.selectedServers
            lastSelecteds.removeAll {$0.chainID == server.chainID}
            servers = lastSelecteds + [server]
        } else {
            if viewModel.selectedServers.contains(server) {
                servers = viewModel.selectedServers - [server]
            } else {
                servers = viewModel.selectedServers + [server]
            }
        }
        configure(viewModel: .init(servers: viewModel.servers, selectedServers: servers))
        tableView.reloadData()
        navigationItem.rightBarButtonItem?.isEnabled = !servers.isEmpty
    }
}
