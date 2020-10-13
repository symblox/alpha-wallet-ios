//
//  SupportViewModel.swift
//  AlphaWallet
//
//  Created by Vladyslav Shepitko on 04.06.2020.
//

import UIKit

class SupportViewModel: NSObject {

    var title: String {
        R.string.localizable.settingsSupportTitle()
    }
    
    var rows: [SupportRow] = [.telegramCustomer, .twitter, .faq, .website]
    
    func cellViewModel(indexPath: IndexPath) -> SettingTableViewCellViewModel {
        let row = rows[indexPath.row]
        return .init(titleText: row.title, subTitleText: nil, icon: row.image)
    }
}

enum SupportRow {
    case telegramPublic
    case telegramCustomer
    case twitter
    case reddit
    case facebook
    case blog
    case faq
    case website
    
    var urlProvider: URLServiceProvider? {
        switch self {
        case .telegramPublic:
            return URLServiceProvider.telegramPublic
        case .telegramCustomer:
            return URLServiceProvider.telegramCustomer
        case .twitter:
            return URLServiceProvider.twitter
        case .reddit:
            return URLServiceProvider.reddit
        case .facebook:
            return URLServiceProvider.facebook
        case .blog:
            return nil
        case .faq:
            return URLServiceProvider.faq
        case .website:
            return URLServiceProvider.website
        }
    }
    
    var title: String {
        switch self {
        case .telegramPublic:
            return URLServiceProvider.telegramPublic.title
        case .telegramCustomer:
            return URLServiceProvider.telegramCustomer.title
        case .twitter:
            return URLServiceProvider.twitter.title
        case .reddit:
            return URLServiceProvider.reddit.title
        case .facebook:
            return URLServiceProvider.facebook.title
        case .faq:
            return "faq".uppercased()
        case .blog:
            return "Blog"
        case .website:
            return "Website"
        }
    }
    
    var image: UIImage {
        switch self {
        case .telegramPublic, .telegramCustomer:
            return URLServiceProvider.telegramPublic.image!
        case .twitter:
            return URLServiceProvider.twitter.image!
        case .reddit:
            return URLServiceProvider.reddit.image!
        case .facebook:
            return URLServiceProvider.facebook.image!
        case .faq:
            return R.image.settings_faq()!
        case .blog:
            return R.image.settings_faq()!
        case .website:
            return R.image.launch_icon()!
        }
    }
} 
