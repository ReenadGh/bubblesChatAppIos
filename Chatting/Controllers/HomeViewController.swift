//
//  HomeViewController.swift
//  Chatting
//
//  Created by Reenad gh on 29/05/1443 AH.
//

import UIKit
import FirebaseAuth
import RealmSwift

struct Conversation {
    
    let id : String
   let name : String
   let otherUserId : String
  let latestMessage : LatestMeassage
}

struct LatestMeassage {
    
    let date : String
    let text : String
    let isRead : Bool
}

class HomeViewController: UIViewController {
    @IBOutlet weak var chatsTableView: UITableView!
    private var conversations = [Conversation]()
    
    @IBAction func newChatButtonTapped(_ sender: UIButton) {
       
        let newChatVC = storyboard?.instantiateViewController(withIdentifier: Constats.newChatViewController) as! NewChatViewController
        newChatVC.completion = {[weak self ]
            result in
            self?.createNewChat(result: result)
        }
        present(newChatVC, animated: true)


    }
    
    
    override func viewDidLoad() {
        
  
        super.viewDidLoad()
        validateAuth()
        chatsTableView.dataSource = self
        chatsTableView.delegate = self
        startLisinningToNewConversation()

    }
    override func viewDidAppear(_ animated: Bool) {
        validateAuth()
        
        

    }
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        startLisinningToNewConversation()

    }
    
    
    

    
    @IBAction func logOutTapped(_ sender: Any) {
        
        do {
            try Auth.auth().signOut()
            let homeVC = storyboard?.instantiateViewController(withIdentifier: Constats.loginViewController)
            view.window?.rootViewController = homeVC
            view.window?.makeKeyAndVisible()
            
        }
          catch { print("already logged out")
          }    
        
    }
    
    
    
    func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            
            let logInVC = storyboard?.instantiateViewController(withIdentifier: Constats.loginViewController)
            view.window?.rootViewController = logInVC
            view.window?.makeKeyAndVisible()
        }else {
            UserDefaults.standard.set(FirebaseAuth.Auth.auth().currentUser?.uid, forKey: "id")
            
            
            let ref = DatabaseManger.shared.db.child("users").child(FirebaseAuth.Auth.auth().currentUser!.uid)
         ref.observeSingleEvent(of: .value, with: { snapshot in

             let value = snapshot.value as! NSDictionary
          
             let fname = value["first_name"] as? String
             let lname = value["last_name"] as? String
             UserDefaults.standard.set("\(fname!) \(lname!)", forKey: "name")

             
           }) { error in
             print(error.localizedDescription)
           }
            
            

        }
    }
}


extension HomeViewController : UITableViewDataSource , UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]

        let cell = chatsTableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatTableViewCell
        cell.setChatCell(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = conversations[indexPath.row]
        chatsTableView.deselectRow(at: indexPath, animated: true)
        let ChatViewController = storyboard?.instantiateViewController(withIdentifier: Constats.chatViewController) as! ChatViewController
        ChatViewController.title = model.name
        ChatViewController.conversationId = model.id
        ChatViewController.otherUserId = model.otherUserId
        
        navigationController?.pushViewController(ChatViewController , animated: true)
        
        
    }



}



extension HomeViewController{
    
    private func createNewChat(result : [String : String ]){
        guard let name = result["name"] , let id = result["id"] else {
            return
        }
        
        
        let ChatViewController = storyboard?.instantiateViewController(withIdentifier: Constats.chatViewController) as! ChatViewController
        ChatViewController.otherUserId = id
        ChatViewController.conversationId = ""
        ChatViewController.isNewChat = true

        ChatViewController.title = name
        navigationController?.pushViewController(ChatViewController , animated: true)
        
    }
    
    
    func startLisinningToNewConversation() {
        
        guard let id = UserDefaults.standard.value(forKey: "id") else {
            return
        }
        
        DatabaseManger.shared.getAllConversations(for: id as! String, completion: { [weak self ]result in
            
            switch result{
                
            case . success(let conversations ) :
                guard !conversations.isEmpty else {
                    return
                }
                
                self?.conversations = conversations
                
                DispatchQueue.main.async {
                    self?.chatsTableView.reloadData()
                }
            case .failure(let error ):
                print(error)
            }
        }
        
        )
                
    }
    
}
