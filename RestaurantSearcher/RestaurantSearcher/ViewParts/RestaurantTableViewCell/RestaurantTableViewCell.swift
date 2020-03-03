

import UIKit

class RestaurantTableViewCell: UITableViewCell {

    @IBOutlet private weak var thmbnailView: UIImageView!
    @IBOutlet private weak var storeNameLabel: UILabel!
    @IBOutlet private weak var rootLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
