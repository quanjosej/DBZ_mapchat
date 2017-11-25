import UIKit
import MapKit
import CoreLocation
import Firebase

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    @IBAction func logout(_ sender: Any) {
        DBZUsersRef.child("connected_status").setValue(false)
        try! Auth.auth().signOut()
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var statusLabel: UINavigationItem!
    
    private lazy var DBZUsersRef: DatabaseReference = Database.database().reference().child("dbz_users").child((Auth.auth().currentUser?.uid)!)
    private var dbzUsersRefHandle: DatabaseHandle?
    private var connectedUsers: [User] = []
    
    var senderDisplayName: String?
    private lazy var channelRef: DatabaseReference = Database.database().reference().child("channels")
    private var channelRefHandle: DatabaseHandle?

    
    @IBOutlet weak var mapView: MKMapView!
    let regionRadius: CLLocationDistance = 1000
    
    // Used to start getting the users location
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // For use when the app is open & in the background
        locationManager.requestAlwaysAuthorization()
        
        
        // If location services is enabled get the users location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation // You can change the locaiton accuary here.
            locationManager.startUpdatingLocation()
            
            mapView.delegate = self
            
            mapView.register(UserMarkerView.self,
                             forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
            
            //Set curr user connection statues
            DBZUsersRef.child("connected_status").onDisconnectSetValue(false)
            DBZUsersRef.child("connected_status").setValue(true)

            
            loadOnlineDbzUsers()
            observeDbzUsers()
            
        }
        
    }
    
    //Initial user load
    private func loadOnlineDbzUsers() {
        Database.database().reference().child("dbz_users").observeSingleEvent(of: .value, with: {(snapshot) in

            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                let dbzUserData = rest.value as! Dictionary<String, AnyObject>

                if (rest.key != (Auth.auth().currentUser?.uid)! && dbzUserData["connected_status"] as! Bool ){
                    let currUser: User = User(userId: rest.key, name: dbzUserData["name"] as! String, latitude: Double(dbzUserData["latitude"] as! String)!, longitude: Double(dbzUserData["longitude"] as! String)!)
                    self.connectedUsers.append(currUser)
                    self.mapView.addAnnotation(currUser)
                }

            }
            
        })
    }
    
    //Persistant user check
    private func observeDbzUsers() {
        dbzUsersRefHandle = Database.database().reference().child("dbz_users").observe(.childChanged, with: { (snapshot) -> Void in
            let dbzUserData = snapshot.value as! Dictionary<String, AnyObject>
            
            if let firstNegative = self.connectedUsers.index(where: { $0.userId == snapshot.key }) {
                self.mapView.removeAnnotation(self.connectedUsers[firstNegative])
                self.connectedUsers.remove(at: firstNegative)
            }
            
            if (dbzUserData["connected_status"] as! Bool && snapshot.key != (Auth.auth().currentUser?.uid)!) {
                let curr_user : User = User(userId: snapshot.key , name: dbzUserData["name"] as! String, latitude: Double(dbzUserData["latitude"] as! String)!, longitude: Double(dbzUserData["longitude"] as! String)! )
                self.connectedUsers.append(curr_user)
                self.mapView.addAnnotation(curr_user)
            }
            
        })
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.showsUserLocation = true
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            //Set curr user gps location
            DBZUsersRef.child("latitude").setValue(String(describing: location.coordinate.latitude))
            DBZUsersRef.child("longitude").setValue(String(describing: location.coordinate.longitude))
            centerMapOnLocation(location: location)
        }
    }
    
    // If we have been deined access give the user the option to change it
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
            showLocationDisabledPopUp()
        }
    }
    
    // Show the popup to the user if we have been deined access
    func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "Background Location Access Disabled",
                                                message: "In order to track the Dragon Balls we need your location",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                }
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let curr_user = view.annotation as! User
        let launchOptions = [MKLaunchOptionsDirectionsModeKey:
            MKLaunchOptionsDirectionsModeDriving]
        
        let users_in_channel:Array<String> = [(Auth.auth().currentUser?.uid)!, curr_user.userId ]
        let users_in_channel_set = Set(users_in_channel.map { $0 })

        
        if (control as? UIButton)?.buttonType == UIButtonType.detailDisclosure {
            mapView.deselectAnnotation(view.annotation, animated: true)
            
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
                    "name": self.senderDisplayName! + " Chat",
                    "users": users_in_channel
                    ] as [String : Any]
                newChannelRef.setValue(channelItem)
                self.performSegue(withIdentifier: "ShowChannelChat", sender: Channel(id:newChannelRef.key, name: channelItem["name"] as! String))
                return
            })
            
        }
    }
    
    @IBAction func showUserList(_ sender: Any) {
        self.performSegue(withIdentifier: "showUserListSegue", sender: Database.database().reference().child("dbz_users"))
    }
    
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let channel = sender as? Channel {
            let chatVc = segue.destination as! ChatViewController
            
            chatVc.senderDisplayName = senderDisplayName
            chatVc.channel = channel
            chatVc.channelRef = channelRef.child(channel.id)
        }
        
        if let databaseUserList = sender as? DatabaseReference {
            let userListVc = segue.destination as! UserListViewController
            
            userListVc.ref = databaseUserList
        }
    }

}
