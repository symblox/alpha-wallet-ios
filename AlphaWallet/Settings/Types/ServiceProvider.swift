// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

enum URLServiceProvider {
    case telegramPublic
    case telegramCustomer
    case twitter
    case reddit
    case facebook
    case faq
    case website

    var title: String {
        switch self {
        case .telegramPublic:
            return "Telegram (Public Channel)"
        case .telegramCustomer:
            return "Telegram"
        case .twitter:
            return "Twitter"
        case .reddit:
            return "Reddit"
        case .facebook:
            return "Facebook"
        case .faq:
            return "FAQ"
        case .website:
            return "Website"
        }
    }

    //TODO should probably change or remove `localURL` since iOS supports deep links now
    var localURL: URL? {
        switch self {
        case .telegramPublic:
            return URL(string: "https://t.me/AlphaWalletGroup")!
        case .telegramCustomer:
            return URL(string: "https://t.me/symblox")!
        case .twitter:
            //return URL(string: "twitter://user?screen_name=\(Constants.twitterUsername)")!
            return URL(string: "https://twitter.com/symbloxdefi")!
        case .reddit:
            return URL(string: "reddit.com\(Constants.redditGroupName)")
        case .facebook:
            return URL(string: "fb://profile?id=\(Constants.facebookUsername)")
        case .faq:
            return URL(string: "https://symblox.io")!
        case .website:
            return URL(string: "https://symblox.io")!
        }
    }

    var remoteURL: URL {
        switch self {
        case .telegramPublic:
            return URL(string: "https://t.me/AlphaWalletGroup")!
        case .telegramCustomer:
            return URL(string: "https://t.me/symblox")!
        case .twitter:
            //return URL(string: "https://twitter.com/\(Constants.twitterUsername)")!
            return URL(string: "https://twitter.com/symbloxdefi")!
        case .reddit:
            return URL(string: "https://reddit.com/\(Constants.redditGroupName)")!
        case .facebook:
            return URL(string: "https://www.facebook.com/\(Constants.facebookUsername)")!
        case .faq:
            return URL(string: "https://symblox.io")!
        case .website:
            return URL(string: "https://symblox.io")!
        }
    }

    var image: UIImage? {
        switch self {
        case .telegramPublic, .telegramCustomer:
            return R.image.settings_telegram()
        case .twitter:
            return R.image.settings_twitter()
        case .reddit:
            return R.image.settings_reddit()
        case .facebook:
            return R.image.settings_facebook()
        case .faq:
            return R.image.settings_faq()
        case .website:
            return R.image.launch_icon()
        }
    }
}
