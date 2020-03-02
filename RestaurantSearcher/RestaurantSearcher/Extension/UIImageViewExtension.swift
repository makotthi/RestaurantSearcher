

import UIKit
import Nuke

// UIImageViewを拡張
extension UIImageView{
    // 画像を非同期で読み込む
    func loadImage(url: String?) {
        if let urlStr = url{
            if let imageURL = URL(string: urlStr){
                Nuke.loadImage(with: imageURL, into: self)
            }
        }
    }
}

