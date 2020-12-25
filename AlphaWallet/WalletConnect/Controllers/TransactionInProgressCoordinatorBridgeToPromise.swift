//
//  TransactionInProgressCoordinatorBridgeToPromise.swift
//  AlphaWallet
//
//  Created by Vladyslav Shepitko on 16.11.2020.
//

import UIKit
import PromiseKit

private class TransactionInProgressCoordinatorBridgeToPromise {

    private let (promiseToReturn, seal) = Promise<Void>.pending()
    private var retainCycle: TransactionInProgressCoordinatorBridgeToPromise?

    init(navigationController: UINavigationController, coordinator: Coordinator) {
        retainCycle = self

        let newCoordinator = TransactionInProgressCoordinator(navigationController: navigationController)
        newCoordinator.delegate = self
        coordinator.addCoordinator(newCoordinator)

        _ = promiseToReturn.ensure {
            // ensure we break the retain cycle
            self.retainCycle = nil
            coordinator.removeCoordinator(newCoordinator)
        }

        newCoordinator.start()
    }

    var promise: Promise<Void> {
        return promiseToReturn
    }
}

extension TransactionInProgressCoordinatorBridgeToPromise: TransactionInProgressCoordinatorDelegate {

    func transactionInProgressDidDismiss(in coordinator: TransactionInProgressCoordinator) {
        seal.fulfill(())
    }
}

extension TransactionInProgressCoordinator {

    static func promise(navigationController: UINavigationController, coordinator: Coordinator) -> Promise<Void> {
        return TransactionInProgressCoordinatorBridgeToPromise(navigationController: navigationController, coordinator: coordinator).promise
    }
}
