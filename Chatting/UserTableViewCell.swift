//
//  UserTableViewCell.swift
//  Chatting
//
//  Created by Reenad gh on 05/06/1443 AH.
//

import UIKit
import SDWebImage

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var userImglbl: UIImageView!
    @IBOutlet weak var userNamelbl: UILabel!

    func fetchUserImgBuId(id : String ){
     
        
        userImglbl.layer.masksToBounds = false
        userImglbl.layer.cornerRadius = userImglbl.frame.height/2
        userImglbl.clipsToBounds = true
        
        
           
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
            self?.userImglbl.sd_setImage(with: url , completed: nil)
        }

    }

}
