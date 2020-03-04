

import UIKit
import Nuke

// NoImage画像のバージョンを定義
enum  ImageVersion {
    case ver1, ver2
}

// UIImageViewを拡張
extension UIImageView{
    // 画像を非同期で読み込む
    func loadImage(url: String?, version: ImageVersion = .ver1) {
        guard let urlString = url, let imageURL = URL(string: urlString) else{
            switch version {
            case .ver1:
                image = #imageLiteral(resourceName: "NoImage2")
            case .ver2:
                image = #imageLiteral(resourceName: "NoImage1")
            }
            return
        }
        
        // オプションの設定
        let options = ImageLoadingOptions(
            // フェードインの設定
            transition: .fadeIn(duration: 0.33),
            // 画像が読み込まれなかった時に表示する画像
            failureImage: #imageLiteral(resourceName: "NoImage2")
        )
        
        Nuke.loadImage(with: imageURL, options: options, into: self)
    }
}

