import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    private lazy var signinUsersRef: DatabaseReference = Database.database().reference().child("dbz_users").child((Auth.auth().currentUser?.uid)!)
    
    var profileUsersRef: DatabaseReference? = nil

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
        
    }
    
    @IBAction func logout(_ sender: Any) {
        signinUsersRef.child("connected_status").setValue(false)
        try! Auth.auth().signOut()
        dismiss(animated: true, completion: nil)
    }
}


