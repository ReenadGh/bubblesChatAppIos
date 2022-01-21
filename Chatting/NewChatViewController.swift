//
//  NewChatViewController.swift
//  Chatting
//
//  Created by Reenad gh on 04/06/1443 AH.
//

import UIKit
import JGProgressHUD


struct UserInfo {
   var fullName : String
    var  UrlImg : String
}

class NewChatViewController: UIViewController {
    
    public  var completion : (([String : String ]) -> (Void))?
    private var users = [[String : String ]]()
    private var FilltredUsers = [[String : String]]()

    private var hasFetched = false
    @IBOutlet weak var usersTableView: UITableView!
    private let spinner = JGProgressHUD(style: .light)
    @IBOutlet weak var personSearchbar: UISearchBar!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usersTableView.dataSource = self
        usersTableView.delegate = self
        personSearchbar.delegate = self

        
        DatabaseManger.shared.getAllUsers(completion: { result in
            switch result {
            case .success( let usersCollection ):
                self.users = usersCollection
                case .failure(let error ):
                print ("failed to get users\(error)")
            }
        })
        
     
        
        personSearchbar.becomeFirstResponder()
        personSearchbar.placeholder = "search for users to chat with .. "
    }
    
    
  
    
    
    
    
    


}

extension NewChatViewController : UISearchBarDelegate {
    
    

    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        searchBar.resignFirstResponder()
        FilltredUsers.removeAll()
        spinner.show(in: view)
        self.searchUsers(query: text)
        
     
    }
    
    
    func searchUsers(query: String) {
        spinner.dismiss(animated: true)
        if hasFetched {
            filterUsers(with: query)
        } else {
            DatabaseManger.shared.getAllUsers{ [weak self] result in
                switch result {
                case .success(let usersCollection):
                    self?.hasFetched = true
                    self?.users = usersCollection
                case .failure(let error):
                    print("Failed to get users: \(error)")
                }
            }
        }
    }
    
    func filterUsers(with term: String) {
        guard hasFetched else {
            return
        }
        
        
        let results: [[String:String]] = self.users.filter {
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            return name.hasPrefix(term.lowercased())
        }
        self.FilltredUsers = results
        usersTableView.reloadData()
        self.spinner.dismiss()

    }
    
    
}

//
extension NewChatViewController : UITableViewDataSource , UITableViewDelegate{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FilltredUsers.count

        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = usersTableView.dequeueReusableCell(withIdentifier: "userCell", for:indexPath) as! UserTableViewCell
        cell.userNamelbl.text = FilltredUsers[indexPath.row]["name"]
       let userId = FilltredUsers[indexPath.row]["id"]
        cell.fetchUserImgBuId(id: userId! )
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         tableView.deselectRow(at: indexPath, animated: true)
        let targetUserData = FilltredUsers[indexPath.row]
        dismiss(animated: true, completion:{
            [weak self] in
            print("dissmised")
            self?.completion?(targetUserData)
            
        }
        
        )
     }




}
