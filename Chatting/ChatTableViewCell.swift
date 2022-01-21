//
//  ChatTableViewCell.swift
//  Chatting
//
//  Created by Reenad gh on 03/06/1443 AH.
//

import UIKit
import SDWebImage
class ChatTableViewCell: UITableViewCell {
    @IBOutlet weak var UserChatImg: UIImageView!
    @IBOutlet weak var personChatName: UILabel!
    @IBOutlet weak var datelbl: UILabel!
    @IBOutlet weak var messagelbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setChatCell( with model : Conversation  ){
        
        
        UserChatImg.layer.masksToBounds = false
        UserChatImg.layer.cornerRadius = UserChatImg.frame.height/2
        UserChatImg.clipsToBounds = true
        
        getotherUserImgURL(id : model.otherUserId )
        personChatName.text = model.name
        messagelbl.text = model.latestMessage.text
        datelbl.text = model.latestMessage.date
    }
    
    
    func getotherUserImgURL(id : String ){
       
           
           let ref = DatabaseManger.shared.db.child("users").child(id)
        ref.observeSingleEvent(of: .value, with: { [self] snapshot in

            let value = snapshot.value as! NSDictionary
            let imgStringUrl = value["imgURL"] as? String
            if imgStringUrl != "" {
                let url = URL(string: imgStringUrl!)!
                downloadImage(from: url)
                
            }
          }) { error in
            print(error.localizedDescription)
          }
       

        
        
        
    }

    
    
    
    func downloadImage(from url: URL) {
        DispatchQueue.main.async() { [weak self] in
            self?.UserChatImg.sd_setImage(with: url , completed: nil)
        }

    }

    
    
    
    
    
    
    
    
    

}
