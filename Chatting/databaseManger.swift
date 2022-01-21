//
//  databaseManger.swift
//  Chatting
//
//  Created by Reenad gh on 02/06/1443 AH.
//

import Foundation
import FirebaseDatabase


final class DatabaseManger {
    
    
    static let shared = DatabaseManger()
    let db = Database.database().reference()
    var user : ChatAppUser?

      
}

extension DatabaseManger {
    
    public func insertUser( user: ChatAppUser , completion: @escaping (Bool) -> Void){
        
        db.child("users").child(user.UserId).setValue(
            ["first_name":user.firstName,
             "last_name":user.lastName,
             "mail" : user.emailAddress,
             "imgURL" : user.imgDataURL
            ]
        )
        
       db.child("usersIfo").observeSingleEvent(of: .value) { snapshot in
                        // snapshot is not the value itself
                        if var usersCollection = snapshot.value as? [[String: String]] {
                            // if var so we can make it mutable so we can append more contents into the array, and update it
                            // append to user dictionary
                            let newElement = [
                                "name": user.firstName + " " + user.lastName,
                                "id": user.UserId
                            ]
                            usersCollection.append(newElement)
                            
                            self.db.child("usersIfo").setValue(usersCollection) { error, _ in
                                guard error == nil else {
                                    completion(false)
                                    return
                                }
                                completion(true)
                            }
                            
                        }else{
                            // create that array
                            let newCollection: [[String: String]] = [
                                [
                                    "name": user.firstName + " " + user.lastName,
                                    "id": user.UserId
                                ]
                            ]
                            self.db.child("usersIfo").setValue(newCollection) { error, _ in
                                guard error == nil else {
                                    completion(false)
                                    return
                                }
                                completion(true)
                            }}}
    }
    
    
    
  
    
    
    
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void){
        db.child("usersIfo").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
            
        }
    }

    public enum DatabaseError: Error {
        case failedToFetch
    }
}


// MARK: - Sending Messages / conversations
extension DatabaseManger {
    
    /*  "conversation_id" {
     "messages": [
     {
     "id": String,
     "type": text, photo, video
     "content": String,
     "date": Date(),
     "sender_email": String,
     "isRead": true/false,
     }
     ]
     }
     
     
     conversation => [
     [
     "conversation_id":
     "other_user_email":
     "latest_message": => {
     "date": Date()
     "latest_message": "message"
     "is_read": true/false
     }
     
     ],
     
     ]
     
     */
    
    /// creates a new conversation with target user email and first message sent
    public func createNewConversation(with otherUserId: String,name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {

        guard let currentid = UserDefaults.standard.value(forKey: "id") as? String
             , let currentName = UserDefaults.standard.value(forKey: "name") as? String

                     else {
                   return
               }
               
               // find the conversation collection for the given user (might not exist if user doesn't have any convos yet)
               
        let ref = db.child("users").child("\(currentid)")
               // use a ref so we can write to this as well
               
               ref.observeSingleEvent(of: .value) { [weak self] snapshot in
                   // what we care about is the conversation for this user
                   guard var userNode = snapshot.value as? [String: Any] else {
                       completion(false)
                       print("user not found")
                       return
                   }

                   var message = ""
                            
                            switch firstMessage.kind {
                            case .text(let messageText):
                                message = messageText
                            case .attributedText(_):
                                break
                            case .photo(_):
                                break
                            case .video(_):
                                break
                            case .location(_):
                                break
                            case .emoji(_):
                                break
                            case .audio(_):
                                break
                            case .contact(_):
                                break
                            case .custom(_):
                                break
                            }
                   
                   
                   let messageDate = firstMessage.sentDate
                   let dateString = self?.convertDateToString(date : messageDate )
                   let conversationId = "conversation_\(firstMessage.messageId)"
                //   var message = ""

                           let newConversationData: [String:Any] = [
                               "id": conversationId,
                               "other_user_id": otherUserId,
                               "name": name,
                               "latest_message": [
                                   "date": dateString,
                                   "message": message,
                                   "is_read": false,
                                   
                               ],
                               
                           ]
                   
                   //
                          let recipient_newConversationData: [String:Any] = [
                              "id": conversationId,
                              "other_user_id": otherUserId, // us, the sender email
                              "name": currentName,  // self for now, will cache later
                              "latest_message": [
                                  "date": dateString,
                                  "message": message,
                                  "is_read": false,
                                  
                              ],
                              
                          ]
                   
                   
                   // update recipient conversation entry
                    
                    self?.db.child("users").child("\(otherUserId)/conversations").observeSingleEvent(of: .value) { [weak self] snapshot in
                        if var conversations = snapshot.value as? [[String: Any]] {
                            // append
                            conversations.append(recipient_newConversationData)
                            self?.db.child("users").child("\(otherUserId)/conversations").setValue(conversationId)
                        }else {
                            // reciepient user doesn't have any conversations, we create them
                            // create
                            self?.db.child("users").child("\(otherUserId)/conversations").setValue([recipient_newConversationData])
                        }
                    }
                    
                   
                   // update current user conversation entry
                             
                             if var conversations = userNode["conversations"] as? [[String: Any]] {
                                 // conversation array exits for current user, you should append
                                 
                                 // points to an array of a dictionary with quite a few keys and values
                                 // if we have this conversations pointer, we would like to append to it
                                 
                                 conversations.append(newConversationData)
                                 
                                 userNode["conversations"] = conversations // we appended a new one
                                 
                                 ref.setValue(userNode) { [weak self] error, _ in
                                     guard error == nil else {
                                         completion(false)
                                         return
                                     }
                                     self?.finishCreatingConversation(name: name, conversationID: conversationId, firstMessage: firstMessage, completion: completion)
                                 }
                             }else {
                                 // create this conversation
                                 // conversation array doesn't exist
                                 
                                 userNode["conversations"] = [
                                     newConversationData
                                 ]
                                 
                                 ref.setValue(userNode) { [weak self] error, _ in
                                     guard error == nil else {
                                         completion(false)
                                         return
                                     }
                                     self?.finishCreatingConversation(name: name, conversationID: conversationId, firstMessage: firstMessage, completion: completion)
                                 }
                                 
                             }
                             
                         }
                         
                     }
                     

    
    private func finishCreatingConversation(name: String, conversationID:String, firstMessage: Message, completion: @escaping (Bool) -> Void){
                         //        {
                         //            "id": String,
                         //            "type": text, photo, video
                         //            "content": String,
                         //            "date": Date(),
                         //            "sender_email": String,
                         //            "isRead": true/false,
                         //        }
                         
                         
                         let messageDate = firstMessage.sentDate
                     let dateString = self.convertDateToString(date: messageDate)
                         var message = ""
                         
                         switch firstMessage.kind {
                         case .text(let messageText):
                             message = messageText
                         case .attributedText(_):
                             break
                         case .photo(_):
                             break
                         case .video(_):
                             break
                         case .location(_):
                             break
                         case .emoji(_):
                             break
                         case .audio(_):
                             break
                         case .custom(_):
                             break
                         case .contact(_):
                             break
                         }
                         
            
                         
        guard let currentid = UserDefaults.standard.value(forKey: "id") as? String else{
            return
        }
                         
                         let collectionMessage: [String: Any] = [
                             "id": firstMessage.messageId,
                             "type": "text",
                             "content": message,
                             "date": dateString,
                             "sender_id": currentid,
                             "is_read": false,
                             "name": name,
                         ]
                         
                         let value: [String:Any] = [
                             "messages": [
                                 collectionMessage
                             ]
                         ]
                         
                         print("adding convo: \(conversationID)")
                         
                         db.child("\(conversationID)").setValue(value) { error, _ in
                             guard error == nil else {
                                 completion(false)
                                 return
                             }
                             completion(true)
                         }
                   
                   
                   
}


    
    
    public func getAllConversations(for id: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        
        self.db.child("users").child("\(id)/conversations").observe(.value) { snapshot in
            // new conversation created? we get a completion handler called
            guard let value = snapshot.value as? [[String:Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            let conversations: [Conversation] = value.compactMap { dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_id"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {
                    return nil
                }
                

                let latestMessageObject = LatestMeassage(date: date, text: message, isRead: isRead)

                return Conversation(id: conversationId, name: name, otherUserId: otherUserEmail, latestMessage: latestMessageObject)
            }

            completion(.success(conversations))

        }
    
        
    }
    
    
  
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        self.db.child("\(id)/messages").observe(.value) { snapshot in
              // new conversation created? we get a completion handler called
              guard let value = snapshot.value as? [[String:Any]] else {
                  completion(.failure(DatabaseError.failedToFetch))
                  return
              }
              let messages: [Message] = value.compactMap { dictionary in
                  guard let name = dictionary["name"] as? String,
              //    let isRead = dictionary["is_read"] as? Bool,
                  let messageID = dictionary["id"] as? String,
                  let content = dictionary["content"] as? String,
                  let senderEmail = dictionary["sender_id"] as? String
               //   let type = dictionary["type"] as? String,
                //  let dateString = dictionary["date"] as? String
               //  let date = ChatViewController.dateFormatter.date(from: dateString)
                            
                  else {
                      return nil
                  }
                  
                  let sender = Sender(photoURL: "", senderId: senderEmail, displayName: name)
                  
                  return Message(sender: sender, messageId: messageID, sentDate: Date() , kind: .text(content))
                  
              }
              
              completion(.success(messages))
              
          }
        
        
        
        
      }
    
    ///// Sends a message with target conversation and message
    public func sendMessage(to conversation: String, otherUserId : String , name: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
        // return bool if successful
        
        // add new message to messages
        // update sender latest message
        // update recipient latest message
        
        self.db.child("\(conversation)/messages").observeSingleEvent(of: .value) { [weak self] snapshot in
            
            guard let strongSelf = self else {
                return
            }
            
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            
            let messageDate = newMessage.sentDate
            let dateString = self?.convertDateToString(date: messageDate)
            
            var message = ""
            
            switch newMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
         //   case .linkPreview(_):
      //          break
            case .custom(_):
                break
            }
            
            guard let currentid = UserDefaults.standard.value(forKey: "id") as? String else{
                return
            }

            
            
            let newMessageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "type": "text",
                "content": message,
                "date": dateString,
                "sender_id": currentid,
                "is_read": false,
                "name": name,
            ]
            
            currentMessages.append(newMessageEntry)
            
            strongSelf.db.child("\(conversation)/messages").setValue(currentMessages) { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                
                
                
                strongSelf.db.child("users").child("\(currentid)/conversations").observeSingleEvent(of: .value) { snapshot  in
                    
                    guard var currentUserConversations = snapshot.value as? [[String: Any]] else {
                        completion(false)
                        return
                    }
                    
                    let UpdatedValue : [String:Any] = [
                        "date" : dateString ,
                        "is_read" : false ,
                        "message" : message
                        
                        
                    ]
                    var targetConversatin : [String : Any ]?
                    var position = 0
                    for conversationD in currentUserConversations {
                        if let currentId = conversationD["id"] as? String , currentid == conversation {
                            targetConversatin = conversationD
                            break
                        }
                        position += 1
                    }
                    
                    targetConversatin?["latest_message"] = UpdatedValue
                    
                    guard let finalConversation = targetConversatin else{
                        completion(false)

                        return
                    }
                    
                    currentUserConversations[position] = finalConversation
                    
                    strongSelf.db.child("users").child("\(currentid)/conversations").setValue(currentUserConversations, withCompletionBlock:{ error, _ in
                        
                        guard  error == nil else{
                            completion(false)

                            return
                        }
                        completion(true)

                        
                    })
                }
                
                
                
                
            }
        
        }
    
    }
    
    
    
    
    
    
    

    
    func convertDateToString(date : Date)->String {
        
        let dateFormatter = DateFormatter()
        /*
         "y, M d"                 // 2020, 10 29
         "YY, MMM d"              // 20, Oct 29
         "YY, MMM d, hh:mm"       // 20, Oct 29, 02:18
         "YY, MMM d, HH:mm:ss"    // 20, Oct 29, 14:18:31
         */
        dateFormatter.dateFormat =  "YY, MMM d, hh:mm"
        
        return  dateFormatter.string(from: date)
    }

  
    
    
    
    
    
    
    
    
    
    

}

struct ChatAppUser {
    var UserId : String
    var firstName: String
    var lastName: String
    var emailAddress: String
    var imgDataURL : String
}
    
