//
//  ChatViewController.swift
//  Chatting
//
//  Created by Reenad gh on 03/06/1443 AH.
//

import UIKit
import MessageKit
import InputBarAccessoryView



struct Message: MessageType {
    
    public var sender: SenderType // sender for each message
    public var messageId: String // id to de duplicate
    public var sentDate: Date // date time
    public var kind: MessageKind // text, photo, video, location, emoji
}

struct Sender: SenderType {
    public var photoURL: String // extend with photo URL
    public var senderId: String
    public var displayName: String
}

class ChatViewController: MessagesViewController {

  
    public var otherUserId :String = ""
    public var conversationId :String = ""

    public var isNewChat = false
    private var messages = [Message]()
   
    
    private var mysender : Sender?{
        
        guard let id = UserDefaults.standard.value(forKey: "id")else {
            return nil
        }
        
      
       return  Sender(photoURL: "",
               senderId: id as! String ,
               displayName: "Reenad")
        
        
    }
    
    
    
    
 
    
    override func viewDidLoad() {
 
        super.viewDidLoad()
        
//
//        if  conversationId != "" {
//            lisenToMessages(ConversationId: conversationId, ScrolltoDown: true)
//
//        }
        
        
    
        

        self.tabBarController?.tabBar.isHidden = true
            messagesCollectionView.messagesDataSource = self
            messagesCollectionView.messagesLayoutDelegate = self
            messagesCollectionView.messagesDisplayDelegate = self
            messageInputBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if  conversationId != "" {
            lisenToMessages(ConversationId: conversationId , ScrolltoDown : true)
            
        }
    }
    
    

}

extension ChatViewController : MessagesDataSource , MessagesLayoutDelegate , MessagesDisplayDelegate {
   
    
    func currentSender() -> SenderType {
        if let sender = mysender {
            return sender

        }
        
        return Sender(photoURL: "", senderId: "0", displayName:"" )
    }
    
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
    
    
}


extension ChatViewController : InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        let  newMessage = Message(sender: mysender!
                                 , messageId: createMessageId() ,
                                 sentDate: Date(),
                                 kind: .text(text))
        
        if isNewChat {
            
        
             
            DatabaseManger.shared.createNewConversation(with: otherUserId,
                                                        name: self.title!,
                                                        firstMessage: newMessage
                                                        , completion:{ [weak self ]sucsess in
                
                if sucsess {
                    print ("message Sent!")
                    self?.isNewChat = false
                }else{
                    print ("failed to  Sent!")

                }
                
            })
        }else{
            
            
            DatabaseManger.shared.sendMessage(to: self.conversationId, otherUserId : self.otherUserId ,name: self.title!,
                                              newMessage: newMessage) {sucsess in
                
                if sucsess {
                    print ("secound message Sent!")
                   
                }else{
                    print ("failed to  Sent secound message !")

                }
            }
            
            
            
            
            
            
            
        }
    }
    
    func createMessageId() -> String {
        
        return "\(UserDefaults.standard.value(forKey: "id") as! String)_with_\(otherUserId)"
    }
    

    
}

extension ChatViewController {
    
    
    private func lisenToMessages(ConversationId : String , ScrolltoDown : Bool ){
        
        DatabaseManger.shared.getAllMessagesForConversation(with: ConversationId , completion: { [weak self ]result in
            
            switch result {
            case . success(let messages ) :
                
                guard !messages.isEmpty else {
                    return
                }
                
                self?.messages = messages
                DispatchQueue.main.async {
                self?.messagesCollectionView.reloadDataAndKeepOffset()
                    
                    if ScrolltoDown {
                        self?.messagesCollectionView.scrollToBottom()

                    }
                }
                
            case .failure(let error ):
                print (error )            }
        
        }
        
        )
        
    }
}
