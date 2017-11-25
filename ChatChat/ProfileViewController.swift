import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    private lazy var DBZUsersRef: DatabaseReference = Database.database().reference().child("dbz_users").child((Auth.auth().currentUser?.uid)!)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func logout(_ sender: Any) {
        DBZUsersRef.child("connected_status").setValue(false)
        try! Auth.auth().signOut()
        dismiss(animated: true, completion: nil)
    }
}


