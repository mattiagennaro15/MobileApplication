//
//  UserViewController.swift
//  jackal2
//
//  Created by Ivo Ganchev [sc15ig] on 24/04/2018.
//  Copyright © 2018 University of Leeds COMP3222. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class UserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var followButton: UIButton!
   
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var NavigationBar: UINavigationItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    var listOfPosts = [String]()
    
    var ref:DatabaseReference?
    var userId = String()
    var followingUserID = [String]()
    var followersUserID = [String]()
    
    
    @IBAction func followButton(_ sender: UIButton) {
        
        let curUserId = Auth.auth().currentUser!.uid
        ref = Database.database().reference()
        let button = (sender as UIButton)
        
        
            if button.titleLabel!.text == "Follow" {
                
                self.ref?.child("\(curUserId)").child("numberFollowing").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let numberOfFollwingUsers = snapshot.value! as! Int
                    let followingUsers = numberOfFollwingUsers + 1
                    
                    // Update number of following users for current user.
                    let numberOfFollowingUpdate = ["\(curUserId)/numberFollowing": followingUsers]
                    self.ref?.updateChildValues(numberOfFollowingUpdate)
                    
                    // Add user to following by the current user.
                    let newFollowedUser = ["\(curUserId)/following/following\(followingUsers)": self.userId]
                    self.ref?.updateChildValues(newFollowedUser)
                    
                    
                    button.setTitle("Unfollow", for: .normal)
                })
                self.ref?.child("\(userId)").child("numberOfFollowers").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let numberOfFollowers = snapshot.value! as! Int
                    let followingUsers = numberOfFollowers + 1
                    
                    // Update number of following users for current user.
                    let numberOfFollowingUpdate = ["\(self.userId)/numberOfFollowers": followingUsers]
                    self.ref?.updateChildValues(numberOfFollowingUpdate)
                    
                    // Add user to following by the current user.
                    let newFollowedUser = ["\(self.userId)/followers/followers\(followingUsers)": curUserId]
                    self.ref?.updateChildValues(newFollowedUser)
                    
                    
                    button.setTitle("Unfollow", for: .normal)
                })

                
                ref!.child("\(userId)").child("actualNumberOfFollowers").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let numberOfFollowers = snapshot.value! as! Int
                    let followers = numberOfFollowers + 1
                    
                    // Update number of followers in the user's profile.
                    let numberOfFollowersUpdate = ["\(self.userId)/actualNumberOfFollowers": followers]
                    self.ref?.updateChildValues(numberOfFollowersUpdate)
                    
                })
                
                self.ref!.child("\(curUserId)").child("actualnumberFollowing").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let numberOfFollwingUsers = snapshot.value! as! Int
                    let followingUsers = numberOfFollwingUsers + 1
                    
                    // Update number of following users for current user.
                    let numberOfFollowingUpdate = ["\(curUserId)/actualnumberFollowing": followingUsers]
                    self.ref?.updateChildValues(numberOfFollowingUpdate)
                    
                })
                
            } else if button .titleLabel!.text == "Unfollow" {
                
                //
                // Remove user been unfollowed from the current users following 
                // list.
                //
                ref!.child("\(curUserId)").child("following").observeSingleEvent(of: .value, with: { (snapshot) in
                    let listOfUsersFollowing = snapshot.value! as! NSDictionary
                    
                    print(listOfUsersFollowing)
                    
                    let arrayOfKeys = listOfUsersFollowing.allKeys
                    
                    // Loops through each user the current user is following.
                    for key in arrayOfKeys {
                        let userFollowingId = (listOfUsersFollowing[key])! as! String
                        
                        if (userFollowingId == self.userId) {
                            self.ref?.child(curUserId).child("following").child("\(key)").removeValue()
                        }
                    }

                })
                
                //
                // Remove current user from the followers of the user been 
                // unfollowed.
                //
                ref!.child("\(self.userId)").child("followers").observeSingleEvent(of: .value, with: { (snapshot) in
                    let listOfFollowers = snapshot.value! as! NSDictionary
                    
                    print(listOfFollowers)
                    
                    let arrayOfKeys = listOfFollowers.allKeys
                    
                    // Loops through each follower of the user been unfollowed.
                    for key in arrayOfKeys {
                        let userFollowerId = (listOfFollowers[key])! as! String
                        
                        if (userFollowerId == curUserId) {
                            self.ref?.child(self.userId).child("followers").child("\(key)").removeValue()
                        }
                    }
                    
                })
                    
                button.setTitle("Follow", for: .normal)
                
                ref!.child("\(self.userId)").child("actualNumberOfFollowers").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let numberFollowing = snapshot.value! as! Int
                    let followers = numberFollowing - 1
                    
                    // Update number of following users for current user.
                    let numberOfFollowingUpdate = ["\(self.userId)/actualNumberOfFollowers": followers]
                    self.ref?.updateChildValues(numberOfFollowingUpdate)
                })
                
                ref!.child("\(curUserId)").child("actualnumberFollowing").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let numberFollowing = snapshot.value! as! Int
                    let followers = numberFollowing - 1
                    
                    // Update number of following users for current user.
                    let numberOfFollowingUpdate = ["\(curUserId)/actualnumberFollowing": followers]
                    self.ref?.updateChildValues(numberOfFollowingUpdate)
                })
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
                
                // Loops through each post, gets contents and appends to list
                // of posts.
                for key in arrayOfKeys! {
                    let post = (posts?[key])! as! String
                    self.listOfPosts.append(post)
                }
            }
            
            // Reload table view content.
            self.tableView.reloadData()
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // Function to set the labesl at the top of the page. That is username,
    // following, followers and number of posts.
    func setLabelsAtTopOfPage() {
        // Read values from database, and display the values in the labels.
        ref?.child(self.userId).observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Get values from database.
            let databaseValues = snapshot.value as? NSDictionary
            let name = databaseValues?["name"] as! String
            let numberOfPosts = databaseValues?["numberOfPosts"] as! Int
            let numberOfFollowers = databaseValues?["actualNumberOfFollowers"] as! Int
            let numberOfFollowing = databaseValues?["actualnumberFollowing"] as! Int
            
            // Set values in the labels.
            self.NavigationBar.title = name
            self.postsLabel.text = String(numberOfPosts)
            self.followersLabel.text = String(numberOfFollowers)
            self.followingLabel.text = String(numberOfFollowing)
            
        })
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.checkIfUserIsFollowing()
        self.getUsersPosts()
        self.setLabelsAtTopOfPage()


        /* Setup delegates */
        tableView.delegate = self
        tableView.dataSource = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkIfUserIsFollowing() {
        
        ref = Database.database().reference()
        let curUserId = Auth.auth().currentUser!.uid
        ref?.child("\(curUserId)").child("following").observeSingleEvent(of: .value, with: { (snapshot) in
            for snap in snapshot.children {
                let userSnap = snap as! DataSnapshot
                self.followingUserID.append(userSnap.value as! String)
            }
            for id in self.followingUserID {
                if self.userId == id {
                    self.followButton.titleLabel!.text = "Unfollow"
                    break
                }
            }
        })
        
        ref?.child("\(self.userId)").child("followers").observeSingleEvent(of: .value, with: { (snapshot) in
            for snap in snapshot.children {
                let userSnap = snap as! DataSnapshot
                self.followersUserID.append(userSnap.value as! String)
            }
        })
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
