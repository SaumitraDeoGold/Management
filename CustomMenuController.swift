
import UIKit

class CustomMenuController: UITableViewCell {
    
    @IBOutlet weak var imvMenu: UIImageView!
       
    @IBOutlet weak var lblMenu: UILabel!
   
        override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
