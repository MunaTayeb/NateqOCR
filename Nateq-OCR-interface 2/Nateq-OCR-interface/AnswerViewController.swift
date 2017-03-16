import Foundation
import UIKit

class AnswerViewController : UIViewController {
    
    
    @IBOutlet weak var AnsLabel: UILabel!
    var ansIS = "";
    
    override func viewDidLoad() {
        
        self.AnsLabel.text = self.ansIS
        self.AnsLabel.numberOfLines =  0 ;
        //self.AnsLabel.textAlignment = NSTextAlignment.justified
        self.AnsLabel.textAlignment = NSTextAlignment.right
        self.AnsLabel.font = self.AnsLabel.font.withSize(18)
        
    }
    
    
    
}
