import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    private lazy var signinUsersRef: DatabaseReference = Database.database().reference().child("dbz_users").child((Auth.auth().currentUser?.uid)!)
    
    var profileUsersRef: DatabaseReference? = nil
    private lazy var channelRef: DatabaseReference = Database.database().reference().child("channels")
    private var channelRefHandle: DatabaseHandle?
    private var isFriend: Bool = false

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var friendListButton: UIButton!
    @IBOutlet weak var addRemoveFriendButton: UIButton!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if(profileUsersRef == nil || profileUsersRef?.key == signinUsersRef.key){
            addRemoveFriendButton.isHidden = true
            chatButton.isHidden = true
            profileUsersRef = signinUsersRef
        }
        else{
            self.navigationItem.rightBarButtonItem = nil
        }
        profileUsersRef?.child("connected_status").observe(.value, with: { snapshot in
            if(snapshot.value as! Bool){
                self.statusLabel.text = "Online"
            }
            else{
                self.statusLabel.text = "Disconnected"
            }
        })
        profileUsersRef?.child("name").observe(.value, with: { snapshot in
            self.userNameLabel.text = snapshot.value as? String
        })
        profileUsersRef?.child("email").observe(.value, with: { snapshot in
            self.emailLabel.text = snapshot.value as? String
        })
        
        Database.database().reference().child("dbz_users").child((Auth.auth().currentUser?.uid)!).child("friends").child((profileUsersRef?.key)!).observe(.value, with: { snapshot in
            print(snapshot.exists())
            if(snapshot.exists()){
                self.isFriend = true
                self.addRemoveFriendButton.setTitle("Remove as Friends", for: .normal)
            }
            else{
                self.isFriend = false
                self.addRemoveFriendButton.setTitle("Add as Friends", for: .normal)
            }
        })
        
    }
    
    @IBAction func logout(_ sender: Any) {
        signinUsersRef.child("connected_status").setValue(false)
        try! Auth.auth().signOut()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showUserList(_ sender: Any) {
       self.performSegue(withIdentifier: "showUserList", sender: profileUsersRef?.child("friends"))
    }
    
    @IBAction func addFriend(_ sender: Any) {
        if(self.isFriend){
            Database.database().reference().child("dbz_users").child((Auth.auth().currentUser?.uid)!).child("friends").child((self.profileUsersRef?.key)!).removeValue()
        }
        else{
             Database.database().reference().child("dbz_users").child((Auth.auth().currentUser?.uid)!).child("friends").child((self.profileUsersRef?.key)!).child("name").setValue(self.userNameLabel.text)
        }
    }
    
    
    @IBAction func showChat(_ sender: Any) {
        let curr_user = profileUsersRef?.key
        
        let users_in_channel:Array<String> = [(Auth.auth().currentUser?.uid)!, curr_user!]
        let users_in_channel_set = Set(users_in_channel.map { $0 })
        
        
            
            channelRef.observeSingleEvent(of: .value, with: {(snapshot) in
                let enumerator = snapshot.children
                while let rest = enumerator.nextObject() as? DataSnapshot {
                    let channelData = rest.value as! Dictionary<String, AnyObject>
                    
                    //Check if users are in the channels
                    let curr_users_in_channel_set = Set((channelData["users"] as! Array<String>).map { $0 })
                    if( users_in_channel_set.isSubset(of: curr_users_in_channel_set)){
                        self.performSegue(withIdentifier: "ShowChannelChat", sender: Channel(id: rest.key, name:channelData["name"] as! String))
                        
                        return
                    }
                    
                }
                let newChannelRef = self.channelRef.childByAutoId()
                let channelItem = [
                    "name": self.userNameLabel.text! + " Chat",
                    "users": users_in_channel
                    ] as [String : Any]
                newChannelRef.setValue(channelItem)
                self.performSegue(withIdentifier: "ShowChannelChat", sender: Channel(id:newChannelRef.key, name: channelItem["name"] as! String))
                return
            })
        
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let channel = sender as? Channel {
            let chatVc = segue.destination as! ChatViewController
            
            chatVc.senderDisplayName = self.userNameLabel.text! + " Chat"
            chatVc.channel = channel
            chatVc.channelRef = channelRef.child(channel.id)
        }
        
        if let databaseUserList = sender as? DatabaseReference {
            let userListVc = segue.destination as! FriendListViewController
            
            userListVc.ref = databaseUserList
        }
    }
}


