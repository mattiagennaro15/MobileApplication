//
//  ProfilePageViewController.swift
//  
//
//  Created by Daniel Griffin on 17/04/2018.
//
//

import UIKit
import Firebase
import FirebaseAuth

class ProfilePageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var numberOfFollowersLabel: UILabel!
    @IBOutlet weak var numberOfFollowingLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var newPostText: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var listOfPosts:[String] = []
    
    // Add a new post to the database based on the contents of the UITextField
    // 'newPostText'.
    @IBAction func newPostButton(_ sender: UIButton) {
        // Create database reference.
        var ref:DatabaseReference?
        ref = Database.database().reference()
        
        // Check new post text box is not empty. If it is display alert to user.
        // Otherwise add post to database and let user know their post has been
        // added.
        if self.newPostText.text == "" {
            let alertController = UIAlertController(title: "Error", message: "New post message box is empty.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            // Get current user id.
            let userId = Auth.auth().currentUser!.uid
            
            // Read current number of posts from database and then add the new
            // post with the appropriate id number. Then update the number of
            // posts field.
            ref?.child("\(userId)").child("numberOfPosts").observeSingleEvent(of: .value, with: { (snapshot) in
                
                let numberOfPosts = snapshot.value! as! Int
                let newPostContent = self.newPostText.text!
                let postId = numberOfPosts + 1
                
                // Update number of posts.
                let numberOfPostsUpdate = ["\(userId)/numberOfPosts": postId]
                ref?.updateChildValues(numberOfPostsUpdate)
                
                // Add post to database.
                let newPostUpdate = ["\(userId)/posts/post\(postId)": newPostContent]
                ref?.updateChildValues(newPostUpdate)
                
                // Clear new post text field.
                self.newPostText.text! = ""
                
                // Retrieve the new set of user posts, and call function to
                // update the table view.
                self.getUsersPosts()
                
            }) { (error) in
                print(error.localizedDescription)
            }
            
            // Let user know post has been added.
            let alertController = UIAlertController(title: "Post Created", message: "", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }

    }
    
    // Returns number of elements in the listOfPosts array - required for table
    // view.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listOfPosts.count
    }
    
    // Populates the table view with the data in 'listOfPosts'.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath)
        cell.textLabel?.text = self.listOfPosts[indexPath.row];
        return cell
    }
    
    // Gets the user's posts and append them to 'listOfPosts'.
    func getUsersPosts() {
        // Clear list of posts.
        self.listOfPosts.removeAll()
        
        // Get current user id.
        let userId = Auth.auth().currentUser!.uid
        
        // Create database reference.
        var ref:DatabaseReference?
        ref = Database.database().reference()
        
        // Read the posts of the current user in the database if there are any.
        ref?.child("\(userId)").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get the values of the database, which is all children of the
            // userId.
            let databaseValues = snapshot.value as? NSDictionary
            
            let numberOfPosts = databaseValues?["numberOfPosts"] as! Int
            
            // If number of posts is greater than 0, then get all individual
            // posts and append to list of posts.
            if numberOfPosts > 0 {
                // Get posts and array of all posts' keys.
                let posts = databaseValues?["posts"] as? NSDictionary
                let arrayOfKeys = posts?.allKeys
                let castedArrya = arrayOfKeys as! [String]
                let sortedArray = castedArrya.sorted { $0.compare($1, options: .numeric) == .orderedDescending }
                // Loops through each post, gets contents and appends to list
                // of posts.
                for key in sortedArray {
                    let post = (posts?[key])! as! String
                    print(post)
                    self.listOfPosts.append(post)
                }
                print(self.listOfPosts)
            }
            
            // Reload table view content.
            self.tableView.reloadData()
            
        }) { (error) in
           print(error.localizedDescription)
        }
    }
    
    // Function which sets the username, followers and following label to the
    // correct values.
    func setUsernameAndFollowLabels() {
        // Get current user id.
        let userId = Auth.auth().currentUser!.uid
        
        // Create database reference.
        var ref:DatabaseReference?
        ref = Database.database().reference()
        
        // Read the posts of the current user in the database if there are any.
        ref?.child("\(userId)").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get the values of the database, which is all children of the
            // userId.
            let databaseValues = snapshot.value as? NSDictionary
            
            // Get the username and number of followers and following.
            let name = databaseValues?["name"] as! String
            let numberFollowers = databaseValues?["actualNumberOfFollowers"] as! Int
            let numberFollowing = databaseValues?["actualnumberFollowing"] as! Int
            
            // Display user name, number of followers and following.
            self.usernameLabel.text = name
            self.numberOfFollowersLabel.text = String(numberFollowers)
            self.numberOfFollowingLabel.text = String(numberFollowing)
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        // Align username within the label.
        usernameLabel.textAlignment = NSTextAlignment.center;

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        // Additional setup after loading the view.
        //
        
        self.setUsernameAndFollowLabels()
        
        self.getUsersPosts()
        
        /* Setup delegates */
        tableView.delegate = self
        tableView.dataSource = self
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
