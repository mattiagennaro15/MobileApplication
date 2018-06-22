//
//  SettingsViewController.swift
//  
//
//  Created by Ivo Ganchev [sc15ig] on 10/04/2018.
//
//

import UIKit
import Firebase
import FirebaseAuth

class SettingsViewController: UIViewController {
    
    
    
    var ref:DatabaseReference?
    
    @IBOutlet weak var changeNameField: UITextField!
    
    @IBOutlet weak var changePasswordField: UITextField!
    
    @IBOutlet weak var changeEmailField: UITextField!
    
    
    @IBAction func saveNameBtn(_ sender: UIButton) {
        ref = Database.database().reference()
        
        // Get the current user id
        let userId = Auth.auth().currentUser!.uid
        
        // Get the current name of the user
        // Update the name with the one from the name field
        ref?.child("\(userId)").child("name").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let newName = self.changeNameField.text!
            
            // Update name
            let nameUpdate = ["\(userId)/name": newName]
            self.ref?.updateChildValues(nameUpdate)
            
            // Return message after successful change
            let alertController = UIAlertController(title: "Success", message: "Successfuly changed name!", preferredStyle: .alert)
                
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
                
            self.present(alertController, animated: true, completion: nil)
            
            self.changeNameField.text! = ""
        })
    }
    
    // Change user's password
    @IBAction func savePasswordBtn(_ sender: UIButton) {
        ref = Database.database().reference()
        
        Auth.auth().currentUser?.updatePassword(to: changePasswordField.text!) { (error) in
            
            if error == nil {
                let alertController = UIAlertController(title: "Success", message: "Successfuly changed password!", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
            } else {
                //Firebase handeles errors
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    // Change user's email
    @IBAction func saveEmailBtn(_ sender: UIButton) {
        ref = Database.database().reference()
        
        Auth.auth().currentUser?.updateEmail(to: changeEmailField.text!) { (error) in
            
            if error == nil {
                let alertController = UIAlertController(title: "Success", message: "Successfuly changed email!", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
            } else {
                //Firebase handeles errors
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    // Sign Out user
    
    @IBAction func SignOutButton(_ sender: UIButton) {
        ref = Database.database().reference()
        let curUser = Auth.auth().currentUser?.uid
        
        if curUser != nil {
            do {
                try Auth.auth().signOut()
                
                let storyboard = UIStoryboard(name: "Login", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "Login")
                self.present(vc, animated: true, completion: nil)
                
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        } else {
            print ("No User!")
        }
    }
    
        

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
