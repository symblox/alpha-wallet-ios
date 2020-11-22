// Copyright © 2020 Stormbird PTE. LTD.

import Foundation

enum ActivityOrTransaction {
    case activity(Activity)
    case transaction(Transaction)

    var activityName: String? {
        switch self {
        case .activity(let activity):
            return activity.name
        case .transaction:
            return nil
        }
    }

    var date: Date {
        switch self {
        case .activity(let activity):
            return activity.date
        case .transaction(let transaction):
            return transaction.date
        }
    }

    var blockNumber: Int {
        switch self {
        case .activity(let activity):
            return activity.blockNumber
        case .transaction(let transaction):
            return transaction.blockNumber
        }
    }

    var transactionIndex: Int {
        switch self {
        case .activity(let activity):
            return activity.transactionIndex
        case .transaction(let transaction):
            return transaction.transactionIndex
        }
    }
}
