//
//  ViewController.swift
//  SwiftSearch


import UIKit
import Firebase
import FirebaseAuth

struct User {
    var id: String
    var name: String
    var email: String
    
    init(id: String, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
}

class SearchUserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var ref:DatabaseReference!
    
    var data = [User]()
    var searchActive : Bool = false
    var filtered:[User] = []
    
    var selection: String?
    
    let userIdentifier = "ShowUserSegue"
    
    // Stores a list of all posts the user is following.
    var listOfPosts = [String]()
    
    //function that queries all the users from the database
    func queryData() {
        ref = Database.database().reference()
        let curUserId = Auth.auth().currentUser!.uid
        //getting all the data
        ref.observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let dict = snap.value as! [String: Any]
                let displayName = dict["name"] as! String!
                let email = dict["email"] as! String!
                let id = snap.key
                //adding the id, name and email to the array
                let user = User(id: id, name: displayName!, email: email!)
                //don't display the current user as a result of the search
                if user.id != curUserId {
                    self.data.append(user)
                }
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        queryData()
        getPostsOfFollowers()
        
        /* Setup delegates */
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }
    
    // Returns the text in the search bar.
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) -> String {
        print("searchText: \(searchText)")
        return searchText
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filtered = self.data.filter({ (user) -> Bool in
            let tmp: NSString = user.name as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        
        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // Returns number of rows in the table.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let searchBarText = self.searchBar.text!
        
        // Checks if search bar contains text, and if it does then checks if
        // there is a match. Will return number of matches or 1 if there ar no
        // macthes. If no content in search, return number of posts.
        if(searchBarText != "") {
            if (self.filtered.count == 0) {
                return 1
            }
            else {
                return filtered.count
            }
        }
        return self.listOfPosts.count;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == userIdentifier,
            let destination = segue.destination as? UserViewController,
            let userIndex = tableView.indexPathForSelectedRow?.row
        {
            let user = filtered[userIndex]
            destination.userId = user.id
        }
    }
    
    
    
    // Populates the table view.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchBarText = self.searchBar.text!
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")! as UITableViewCell;
        
        // Checks content of search bar. Displays results of search if there is
        // a search query. If no macthes, displays no macthes found. If there is
        // no text in the search bar, display posts of users the current user
        // is following.
        if(searchBarText != ""){
            if (self.filtered.count == 0) {
                cell.accessoryType = .none
                cell.textLabel?.text = "No matches found"
            }
            else {
                cell.textLabel?.text = filtered[indexPath.row].name
                cell.accessoryType = .disclosureIndicator
            }
        }
        else {
            cell.accessoryType = .none
            cell.textLabel?.text = self.listOfPosts[indexPath.row];
        }
        
        return cell;
    }
    
    // Gets the all the posts of the users the current user follwos and add
    // them to the 'listOfPosts'.
    func getPostsOfFollowers() {
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
            let numberFollowing = databaseValues?["actualnumberFollowing"] as! Int
            
            if (numberFollowing > 0) {
                // Get dictionary of users following and array of all keys to
                // access the id of each person following.
                let usersFollowing = databaseValues?["following"] as? NSDictionary
                let arrayOfKeys = usersFollowing?.allKeys
                
                // Loops through each user the current user is following.
                for key in arrayOfKeys! {
                    let userFollowingId = (usersFollowing?[key])! as! String
                    
                    // Query the database again, but this time for the user
                    // the current user is following. The get all their posts
                    // if they have any, and add them to 'listOfPosts'.
                    ref?.child("\(userFollowingId)").observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        // Get the values of the database, which is all children of the
                        // userId.
                        let databaseValues = snapshot.value as? NSDictionary
                        
                        let numberOfPosts = databaseValues?["numberOfPosts"] as! Int
                        
                        // If number of posts is greater than 0, then get all individual
                        // posts and append to list of posts.
                        if numberOfPosts > 0 {
                            // Get the username of the user.
                            let name = databaseValues?["name"] as! String
                            
                            // Get posts and array of all posts' keys.
                            let posts = databaseValues?["posts"] as? NSDictionary
                            let arrayOfKeys = posts?.allKeys
                            
                            // Loops through each post, gets contents and appends to list
                            // of posts.
                            for key in arrayOfKeys! {
                                var post = (posts?[key])! as! String
                                
                                // Append the username to the content of the
                                // post.
                                post = post + " - " + name
                                
                                self.listOfPosts.append(post)
                            }
                        }
                        
                        // Reload table view content.
                        self.tableView.reloadData()
                        
                    }) { (error) in
                        print(error.localizedDescription)
                    }
                }
            }
            
            // Reload table view content.
            self.tableView.reloadData()
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }

}
