//
//  FirstViewController.swift
//  jackal2
//
//  Created by Daniel Griffin on 24/03/2018.
//  Copyright © 2018 University of Leeds COMP3222. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class FirstViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    var ref:DatabaseReference?
    
    @IBAction func LoginBtn(_ sender: UIButton) {
        ref = Database.database().reference()
        
        if self.emailTextField.text == "" {
            
            // Aler user with message if email field was left empty
            
            let alertController = UIAlertController(title: "Error", message: "Please enter an email.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else if self.passwordTextField.text == "" {
            
            // Aler user with message if password field was left empty
            
            let alertController = UIAlertController(title: "Error", message: "Please enter a password.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            
            Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
                
                if error == nil {
                    
                    //If successfully logged in print in console
                    print("You have successfully logged in")
                    
                    //Go to the HomeTabBarController if the login is sucessful
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "Home")
                    self.present(vc, animated: true, completion: nil)
                    
                } else {
                    
                    //Firebase handeles errors
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

