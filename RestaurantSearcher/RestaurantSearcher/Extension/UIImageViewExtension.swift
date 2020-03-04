

import UIKit
import Nuke

// UIImageViewを拡張
extension UIImageView{
    // 画像を非同期で読み込む
    func loadImage(url: String?) {
        guard let urlString = url, let imageURL = URL(string: urlString) else{
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

