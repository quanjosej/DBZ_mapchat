import UIKit
import Firebase

class LoginViewController: UIViewController {
  
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismiss(animated: true, completion: nil)
        
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil {
                self.performSegue(withIdentifier: "LoginToMap", sender: nil)
            }
        }
        
    }
  
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
  
    @IBAction func loginDidTouch(_ sender: AnyObject) {
        Auth.auth().signIn(withEmail: textFieldLoginEmail.text!,
                               password: textFieldLoginPassword.text!)
        
    }
    
    @IBAction func signUpDidTouch(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Register",
                                      message: "Register",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) { action in
                                        
            let emailField = alert.textFields![0]
            let passwordField = alert.textFields![1]
            let nameField = alert.textFields![2]

            Auth.auth().createUser(withEmail: emailField.text!,
                                   password: passwordField.text!) { user, error in
                if error == nil {
                Database.database().reference().child("dbz_users").child((user?.uid)!).child("name").setValue(nameField.text!)
                Database.database().reference().child("dbz_users").child((user?.uid)!).child("email").setValue(emailField.text!)
                    
                    Auth.auth().signIn(withEmail: self.textFieldLoginEmail.text!,
                                           password: self.textFieldLoginPassword.text!)
                }
                else {
                    let alert = UIAlertController(title: "Signup Unsuccessful",
                                                  message: "Please try again with a different email or use more elaborate password.",
                                                  preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK",
                                                     style: .default)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
                                        
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField { textEmail in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextField { textPassword in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        alert.addTextField { textName in
            textName.placeholder = "Enter your name"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
  
}

