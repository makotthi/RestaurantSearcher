

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // 現在地から検索する画面に遷移
    @IBAction func locationSearchButton(_ sender: Any) {
        performSegue(withIdentifier: "locationSearch", sender: nil)
    }
    
    // キーワードで検索する画面に遷移
    @IBAction func keywordSearchButton(_ sender: Any) {
        performSegue(withIdentifier: "keywordSearch", sender: nil)
    }
    
}

