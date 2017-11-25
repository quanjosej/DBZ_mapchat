import UIKit
import Firebase

class UserListViewController: UITableViewController {
    
    // MARK: Properties
    var items: [User] = []
    var ref : DatabaseReference? // = Database.database().reference().child("dbz_users")
    let meRef : DatabaseReference = Database.database().reference().child("dbz_users").child((Auth.auth().currentUser?.uid)!)

    
    // MARK: UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelectionDuringEditing = false
        

        ref?.observe(.value, with: { snapshot in

            var newItems: [User] = []
            
            for item in snapshot.children {
                if(self.meRef.key == (item as AnyObject).key){
                    continue
                }
                let userItem = User(snapshot: item as! DataSnapshot)
                newItems.append(userItem)
            }
            

            self.items = newItems
            self.tableView.reloadData()
        })

    }
    
    // MARK: UITableView Delegate methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let userItem = items[indexPath.row]
        
        cell.textLabel?.text = userItem.title
        
        if(userItem.connected_status)!{
            cell.detailTextLabel?.text = "Online"
        }
        else{
            cell.detailTextLabel?.text = "Disconnected"
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let userItem = items[indexPath.row]

    }
    
//    func toggleCellCheckbox(_ cell: UITableViewCell, isCompleted: Bool) {
//        if !isCompleted {
//            cell.accessoryType = .none
//            cell.textLabel?.textColor = UIColor.black
//            cell.detailTextLabel?.textColor = UIColor.black
//        } else {
//            cell.accessoryType = .checkmark
//            cell.textLabel?.textColor = UIColor.gray
//            cell.detailTextLabel?.textColor = UIColor.gray
//        }
//    }
    
}
