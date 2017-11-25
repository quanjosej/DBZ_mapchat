import UIKit
import Firebase

class FriendListViewController: UITableViewController {
    
    // MARK: Properties
    var items: [User] = []
    var ref : DatabaseReference? // = Database.database().reference().child("dbz_users")
    let meRef : DatabaseReference = Database.database().reference().child("dbz_users").child((Auth.auth().currentUser?.uid)!)
    
    
    // MARK: UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    Database.database().reference().child("dbz_users").child((Auth.auth().currentUser?.uid)!).child("friends").child("bJGFsxXYjeWv2VqqlO5OjaIdMPj1").child("since").setValue(NSDate().timeIntervalSince1970)
        
        Database.database().reference().child("dbz_users").child((Auth.auth().currentUser?.uid)!).child("friends").child("bJGFsxXYjeWv2VqqlO5OjaIdMPj1").child("name").setValue("sss")
        
        tableView.allowsMultipleSelectionDuringEditing = false
        
        
        ref?.observe(.value, with: { snapshot in
            
            var newItems: [User] = []
            
            print(snapshot)
            
            let enumerator = snapshot.children
            
            while let rest = enumerator.nextObject() as? DataSnapshot {
                if(self.meRef.key == rest.key){
                    continue
                }
                
                let dbzUserData = rest.value as! Dictionary<String, AnyObject>
                let currUser: User = User(userId: rest.key, name: dbzUserData["name"] as! String, latitude: 0, longitude: 0)
                newItems.append(currUser)
                print(rest)
                
                
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
        cell.detailTextLabel?.text = ""
        
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
