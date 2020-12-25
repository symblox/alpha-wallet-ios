// Copyright © 2018 Stormbird PTE. LTD.

import UIKit

protocol EnabledServersCoordinatorDelegate: class {
    func didSelectServers(servers: [RPCServer], in coordinator: EnabledServersCoordinator)
    func didSelectDismiss(in coordinator: EnabledServersCoordinator)
}

class EnabledServersCoordinator: Coordinator {
    static let serversOrdered: [RPCServer] = ServersCoordinator.serversOrdered

    private let serverChoices = EnabledServersCoordinator.serversOrdered
    private let navigationController: UINavigationController
    private let selectedServers: [RPCServer]
    var selectedSubServers = [RPCServer]()

    private lazy var enabledServersViewController: EnabledServersViewController = {
        let controller = EnabledServersViewController()
        let validSelecteds = selectServers(selectedServers)
        controller.configure(viewModel: EnabledServersViewModel(servers: serverChoices, selectedServers: validSelecteds))
        controller.delegate = self
        controller.hidesBottomBarWhenPushed = true
        return controller
    }()

    var coordinators: [Coordinator] = []
    weak var delegate: EnabledServersCoordinatorDelegate?

    init(navigationController: UINavigationController, selectedServers: [RPCServer]) {
        self.navigationController = navigationController
        self.selectedServers = selectedServers
    }

    func start() {
        enabledServersViewController.navigationItem.largeTitleDisplayMode = .never
        navigationController.pushViewController(enabledServersViewController, animated: true)
    }

    func stop() {
        navigationController.popViewController(animated: true)
    }
    
    private func selectServers(_ inputServers:[RPCServer]) -> [RPCServer] {
        guard !selectedSubServers.isEmpty else {
            return inputServers
        }
        var results = [RPCServer]()
        
        var subServerMap = [Int: RPCServer]()
        selectedSubServers.forEach{ subServerMap[$0.chainID] = $0 }
        for server in inputServers {
            if let subServer = subServerMap[server.chainID] {
                results.append(subServer)
            } else {
                results.append(server)
            }
        }
        return results
    }
}

extension EnabledServersCoordinator: EnabledServersViewControllerDelegate {
    func didSelectServers(servers: [RPCServer], in viewController: EnabledServersViewController) {
        delegate?.didSelectServers(servers: servers, in: self)
    }

    func didDismiss(viewController: EnabledServersViewController) {
        delegate?.didSelectDismiss(in: self)
    }
}
