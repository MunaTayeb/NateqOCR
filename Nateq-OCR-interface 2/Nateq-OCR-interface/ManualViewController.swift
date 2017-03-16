import Foundation
import UIKit

class UserManualViewController: UIViewController , UITableViewDataSource , UITableViewDelegate{
    
    
    
    
    @IBOutlet weak var TableView: UITableView!
    
    
    
    
    // 2 array , one for questions and the second for answers
    
    var questions = [
        
        "السؤال الأول "
        
        ,"السؤال الثاني"
        
        ,"السؤال الثالث"
        
        ,"السؤال الرابع"
        
        ,"السؤال الخامس"
        
        ,"السؤال السادس"
        
    ]
    
    
    var AnswersQ = [
        
        "الجواب الأول "
        
        ,"الجواب الثاني"
        
        ,"الجواب الثالث"
        
        ,"الجواب الرابع"
        
        ,"ما هي خاصية اكتشاف الحدود"
        
        ,"الجواب السادس"
        
    ]
    
    var test = ""
    
    
    override func viewDidLoad() {
        
        self.TableView.dataSource = self
        self.TableView.delegate = self
        self.TableView.estimatedRowHeight = 300
        self.TableView.rowHeight = UITableViewAutomaticDimension
        //  self.TableView.tableFooterView = UIView()
        //self.TableView.cellLayoutMarginsFollowReadableWidth = true
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.questions.count;
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel!.text = self.questions[indexPath.row]
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.textLabel?.textAlignment = NSTextAlignment.right
        cell.textLabel!.font =  cell.textLabel!.font.withSize(14)
        
        // cell.textLabel?.adjustsFontSizeToFitWidth = true
        //cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.test = self.AnswersQ[indexPath.row]
        self.performSegue(withIdentifier: "tableToAns", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detail = segue.destination as!AnswerViewController
        detail.ansIS = self.test;
    }
    
}
