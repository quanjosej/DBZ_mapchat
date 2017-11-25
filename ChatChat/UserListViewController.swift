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
        
        Database.database().reference().child("dbz_users").child((Auth.auth().currentUser?.uid)!).child("friends").child("JDlZcE6OKcOShAlDKGXCVXgz0s23").child("since").setValue(NSDate().timeIntervalSince1970)
        
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
            
            print(newItems)
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
        self.performSegue(withIdentifier: "showUserProfile", sender: Database.database().reference().child("dbz_users").child(userItem.userId))
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let databaseUserProfile = sender as? DatabaseReference {
            let userProfileVc = segue.destination as! ProfileViewController
            
            userProfileVc.profileUsersRef = databaseUserProfile
        }
    }
    
}
