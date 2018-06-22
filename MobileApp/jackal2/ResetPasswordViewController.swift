//
//  ThirdViewController.swift
//  jackal2
//
//  Created by Ivo Ganchev [sc15ig] on 10/04/2018.
//  Copyright © 2018 University of Leeds COMP3222. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ThirdViewController: UIViewController {
    
    var ref:DatabaseReference?
    
    @IBOutlet weak var emailTextField: UITextField!
    
    // Reset password and receive email
    @IBAction func resetPasswordBtn(_ sender: UIButton) {
        
        ref = Database.database().reference()
        
        // Check if email is empty and alert message
        if emailTextField.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter your email!", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
            Auth.auth().sendPasswordReset(withEmail: emailTextField.text!, completion: { (error) in
                
                var title = ""
                var message = ""
                
                if error != nil {
                    title = "Error!"
                    message = (error?.localizedDescription)!
                } else {
                    title = "Success!"
                    message = "Password reset email sent."
                }
                
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel){ (UIAlertAction) -> Void in
                    
                    // After clicking 'OK' redirect to Login page
                    let storyboard = UIStoryboard(name: "Login", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "Login")
                    self.present(vc, animated: true, completion: nil)
                }
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
            })
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
