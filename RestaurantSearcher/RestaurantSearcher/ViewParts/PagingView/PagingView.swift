
import UIKit

class PagingView: UIView {

    @IBOutlet private weak var backPageButton: UIButton!
    @IBOutlet private weak var nextPageButton: UIButton!
    @IBOutlet private weak var pageLabel: UILabel!
    
   
    @IBAction private func backPageButtonTapped(_ sender: Any) {
    }
    
    @IBAction private func nextPageButtonTapped(_ sender: Any) {
    }
    
    
    
    // MARK: -Setter
    
    // Buttonの有効状態のセッター
    // backPageButton
    func setBackPageButtonEnabled(isEnabled: Bool){
        backPageButton.isEnabled = isEnabled
    }
    // nextPageButton
    func setNextPageButtonEnabled(isEnabled: Bool){
        nextPageButton.isEnabled = isEnabled
    }
    
    // pageLabelのテキストをセット
    func setPageLabel(text: String){
        pageLabel.text = text
    }
    
    
}
