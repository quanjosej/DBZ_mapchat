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
        
        tableView.allowsMultipleSelectionDuringEditing = false
        
        
        ref?.observe(.value, with: { snapshot in
            
            var newItems: [User] = []
            
            print(snapshot)
            
            let enumerator = snapshot.children
            
            while let rest = enumerator.nextObject() as? DataSnapshot {
                
                let dbzUserData = rest.value as! Dictionary<String, AnyObject>
                let currUser: User = User(userId: rest.key, name: dbzUserData["name"] as! String, latitude: 0, longitude: 0)
                newItems.append(currUser)
                
                
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
