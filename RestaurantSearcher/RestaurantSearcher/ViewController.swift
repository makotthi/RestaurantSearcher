

import UIKit

class ViewController: UIViewController {

    // タイトルを表示するラベル
    @IBOutlet private weak var titleLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        titleLabel.text = "Restaurant\nSearcher"
        titleLabel.sizeToFit()
    }
    
    // 現在地から検索する画面に遷移
    @IBAction private func locationSearchButton(_ sender: Any) {
        performSegue(withIdentifier: "locationSearch", sender: nil)
    }
    
    // キーワードで検索する画面に遷移
    @IBAction private func keywordSearchButton(_ sender: Any) {
        performSegue(withIdentifier: "keywordSearch", sender: nil)
    }
    
}

