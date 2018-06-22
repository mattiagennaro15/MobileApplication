//
//  SecondViewController.swift
//  jackal2
//
//  Created by Daniel Griffin on 24/03/2018.
//  Copyright © 2018 University of Leeds COMP3222. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class SecondViewController: UIViewController {
    
    
    var ref:DatabaseReference?
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var confirmPassword: UITextField!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var dobDatePicker: UIDatePicker!
    
    @IBOutlet weak var genderSegmentControl: UISegmentedControl!
    
    @IBAction func signUpBtn(_ sender: UIButton) {
        
        ref = Database.database().reference()
        
        // Check if email field is empty and show alert message
       if emailTextField.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter your email!", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else if passwordField.text != confirmPassword.text {
        // Check is password and confirm password are identical and show alert message
        // if they are not
            
            let alertController = UIAlertController(title: "Error", message: "Make sure your passwords match!", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
        
            present(alertController, animated: true, completion: nil)
        } else {
            // Call Firebase authentication function to create user by email and password
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordField.text!) { (user, error) in
                
                if error == nil {
                    self.emailTextField.text = ""
                    self.passwordField.text = ""
                    self.confirmPassword.text = ""
                    
                    let user = Auth.auth().currentUser
                    if let user = user {
                        // The user's ID, unique to the Firebase project.
                        // Do NOT use this value to authenticate with your backend server,
                        // if you have one. Use getTokenWithCompletion:completion: instead.
                        let uid = user.uid
                        let email = user.email
                        
                        self.dobDatePicker.datePickerMode = .date
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MMM dd, yyyy"
                        let selectedDate = dateFormatter.string(from: self.dobDatePicker.date)
                        
                        let genderTitle = self.genderSegmentControl.titleForSegment(at: self.genderSegmentControl.selectedSegmentIndex)
                        
                        // Add user to database
                        
                        self.ref?.child(uid).child("name").setValue(self.nameTextField.text!);
                        self.ref?.child(uid).child("email").setValue(email);
                        self.ref?.child(uid).child("dob").setValue(selectedDate);
                        self.ref?.child(uid).child("gender").setValue(genderTitle);
                        self.ref?.child(uid).child("numberOfPosts").setValue(0);
                        self.ref?.child(uid).child("numberOfFollowers").setValue(0);
                        self.ref?.child(uid).child("numberFollowing").setValue(0);
                        self.ref?.child(uid).child("actualNumberOfFollowers").setValue(0);
                        self.ref?.child(uid).child("actualnumberFollowing").setValue(0);



                        // ...
                    }
                    
    
                    let storyboard = UIStoryboard(name: "Login", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "Login")
                    self.present(vc, animated: true, completion: nil)

                    
                } else {
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

