// Copyright © 2020 Stormbird PTE. LTD.

import Foundation
import UIKit

struct ActivitiesViewModel {
    private var formatter: DateFormatter {
        return Date.formatter(with: "dd MMM yyyy")
    }
    private var items: [(date: String, items: [ActivityOrTransaction])] = []

    init(activities: [ActivityOrTransaction] = []) {
        //Uses NSMutableArray instead of Swift array for performance. Really slow when dealing with 10k events, which is hardly a big wallet
        var newItems: [String: NSMutableArray] = [:]
        for each in activities {
            let date = formatter.string(from: each.date)
            let currentItems = newItems[date] ?? .init()
            currentItems.add(each)
            newItems[date] = currentItems
        }
        let tuple = newItems.map { each in
            (date: each.key, items: (each.value as! [ActivityOrTransaction]).sorted {
                //Show pending transactions at the top
                if $0.blockNumber == 0 && $1.blockNumber != 0 {
                    return true
                } else if $0.blockNumber != 0 && $1.blockNumber == 0 {
                    return false
                } else if $0.blockNumber > $1.blockNumber {
                    return true
                } else if $0.blockNumber < $1.blockNumber {
                    return false
                } else {
                    if $0.transactionIndex > $1.transactionIndex {
                        return true
                    } else if $0.transactionIndex < $1.transactionIndex {
                        return false
                    } else {
                        switch ($0, $1) {
                        case let (.activity(a0), .activity(a1)):
                            return a0.logIndex > a1.logIndex
                        case (.transaction, .activity):
                            return false
                        case (.activity, .transaction):
                            return true
                        case let (.transaction(t0), .transaction(t1)):
                            if let n0 = Int(t0.nonce), let n1 = Int(t1.nonce) {
                                return n0 > n1
                            } else {
                                return false
                            }
                        }
                    }
                }
            })
        }
        items = tuple.sorted { (object1, object2) -> Bool in
            formatter.date(from: object1.date)! > formatter.date(from: object2.date)!
        }
    }

    var backgroundColor: UIColor {
        Colors.appWhite
    }

    var headerBackgroundColor: UIColor {
        GroupedTable.Color.background
    }

    var headerTitleTextColor: UIColor {
        GroupedTable.Color.title
    }

    var headerTitleFont: UIFont {
        Fonts.tableHeader
    }

    var numberOfSections: Int {
        items.count
    }

    func numberOfItems(for section: Int) -> Int {
        items[section].items.count
    }

    func item(for row: Int, section: Int) -> ActivityOrTransaction {
        items[section].items[row]
    }

    func titleForHeader(in section: Int) -> String {
        let value = items[section].date
        let date = formatter.date(from: value)!
        if NSCalendar.current.isDateInToday(date) {
            return R.string.localizable.today().localizedUppercase
        }
        if NSCalendar.current.isDateInYesterday(date) {
            return R.string.localizable.yesterday().localizedUppercase
        }
        return value.localizedUppercase
    }
}
