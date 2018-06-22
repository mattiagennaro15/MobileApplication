//
//  HomePageViewController.swift
//  jackal2
//
//  Created by Mattia Gennaro [sc15mg] on 24/03/2018.
//  Copyright © 2018 University of Leeds COMP3222. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class HomePageViewController: UIViewController {
    
    var ref:DatabaseReference?
    var contentView: UIView?
    
    var x = 187
    var y = 285
    
    
    @IBOutlet weak var searchText: UITextField!

    @IBAction func searchButton(_ sender: UIButton) {
    
        ref = Database.database().reference()
        
        if self.searchText.text == "" {
            let alertController = UIAlertController(title: "Error", message: "You can't search for an empty name.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            
            let username = self.searchText.text!
            
            let query = ref?.queryOrdered(byChild: "name").queryEqual(toValue: username)
            query?.observeSingleEvent(of: .value, with: { snapshot in
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    let dict = snap.value as! [String: Any]
                    let displayName = dict["name"] as! String!
                    print(displayName)
                    
                    for names in dict.keys {
                        print(names)
                        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
                        label.center = CGPoint(x: self.x, y: self.y)
                        label.textAlignment = .center
                        label.text = names
                        label.isUserInteractionEnabled = true
                        self.view.addSubview(label)
                        self.x += 10
                    }

                }
            })
        }
                
        
        
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
