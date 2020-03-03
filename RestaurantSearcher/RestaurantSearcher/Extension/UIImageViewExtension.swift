

import UIKit
import Nuke

// UIImageViewを拡張
extension UIImageView{
    // 画像を非同期で読み込む
    func loadImage(url: String?) {
        guard let urlString = url, let imageURL = URL(string: urlString) else{
            return
        }
        Nuke.loadImage(with: imageURL, into: self)
    }
}

