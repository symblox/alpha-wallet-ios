// Copyright SIX DAY LLC. All rights reserved.

import BigInt
import Foundation
import APIKit
import JSONRPCKit
import PromiseKit
import Result

class SendTransactionCoordinator {
    private let keystore: Keystore
    private let session: WalletSession
    private let formatter = EtherNumberFormatter.full
    private let confirmType: ConfirmType

    init(
        session: WalletSession,
        keystore: Keystore,
        confirmType: ConfirmType
    ) {
        self.session = session
        self.keystore = keystore
        self.confirmType = confirmType
    }

    func send(
        transaction: UnsignedTransaction,
        completion: @escaping (ResultResult<ConfirmResult, AnyError>.t) -> Void
    ) {
        if transaction.nonce >= 0 {
            signAndSend(transaction: transaction, completion: completion)
        } else {
            let request = EtherServiceRequest(server: session.server, batch: BatchFactory().create(GetTransactionCountRequest(
                address: session.account.address,
                state: "pending"
            )))
            //TODO Verify we need a strong reference to self
            Session.send(request) { result in
                //guard let `self` = self else { return }
                switch result {
                case .success(let count):
                    let transaction = self.appendNonce(to: transaction, currentNonce: count)
                    self.signAndSend(transaction: transaction, completion: completion)
                case .failure(let error):
                    completion(.failure(AnyError(error)))
                }
            }
        }
    }

    func send(transaction: UnsignedTransaction) -> Promise<ConfirmResult> {
        Promise { seal in
            send(transaction: transaction) { result in
                switch result {
                case .success(let result):
                    seal.fulfill(result)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }

    private func appendNonce(to: UnsignedTransaction, currentNonce: Int) -> UnsignedTransaction {
        return UnsignedTransaction(
            value: to.value,
            account: to.account,
            to: to.to,
            nonce: currentNonce,
            data: to.data,
            gasPrice: to.gasPrice,
            gasLimit: to.gasLimit,
            server: to.server
        )
    }

    func signAndSend(
        transaction: UnsignedTransaction,
        completion: @escaping (ResultResult<ConfirmResult, AnyError>.t) -> Void
    ) {
        let signedTransaction = keystore.signTransaction(transaction)
        switch signedTransaction {
        case .success(let data):
            switch confirmType {
            case .sign:
                completion(.success(.signedTransaction(data)))
            case .signThenSend:
                let request = EtherServiceRequest(server: session.server, batch: BatchFactory().create(SendRawTransactionRequest(signedTransaction: data.hexEncoded)))
                Session.send(request) { result in
                    switch result {
                    case .success(let transactionID):
                        completion(.success(.sentTransaction(SentTransaction(id: transactionID, original: transaction))))
                    case .failure(let error):
                        completion(.failure(AnyError(error)))
                    }
                }
            }
        case .failure(let error):
            completion(.failure(AnyError(error)))
        }
    }
}
