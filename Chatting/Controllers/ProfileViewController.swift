//
//  ProfileViewController.swift
//  Chatting
//
//  Created by Reenad gh on 29/05/1443 AH.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate  {
    @IBOutlet weak var userImg: UIImageView!
    
    @IBAction func newChatButtonTapped(_ sender: UIButton) {
        let newChatVC = storyboard?.instantiateViewController(withIdentifier: Constats.newChatViewController)
        navigationController?.pushViewController(newChatVC! , animated: true)
        
    }
    @IBOutlet weak var mailTF: UITextField!
    @IBOutlet weak var lnameTF: UITextField!
    @IBOutlet weak var fnameTF: UITextField!
    @IBOutlet weak var editButton: UIButton!
   
    
    @IBAction func ableEditButton(_ sender: UIButton) {
        
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userImg.layer.borderWidth = 2
        userImg.layer.masksToBounds = false
        userImg.layer.borderColor = UIColor.black.cgColor
        userImg.layer.cornerRadius = userImg.frame.height/2
        userImg.clipsToBounds = true
        
        
        UserinformationUpdate()
        
    
        
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        userImg.isUserInteractionEnabled = true
        userImg.addGestureRecognizer(tapGestureRecognizer)
        
        
        
        
        
        
    }
    
       func UserinformationUpdate(){
       
           
           let ref = DatabaseManger.shared.db.child("users").child(FirebaseAuth.Auth.auth().currentUser!.uid)
        ref.observeSingleEvent(of: .value, with: { [self] snapshot in

            let value = snapshot.value as! NSDictionary
         
            self.fnameTF.text = value["first_name"] as? String
            self.lnameTF.text = value["last_name"] as? String
            self.mailTF.text = value["mail"] as? String
            let imgStringUrl = value["imgURL"] as? String
            if imgStringUrl != "" {
                let url = URL(string: imgStringUrl!)!
                downloadImage(from: url)
                
            }
          }) { error in
            print(error.localizedDescription)
          }
       

        
        
        
    }


}


extension ProfileViewController {
    
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        showPhotoAlert()

   
    }
    
    
    func showPhotoAlert(){
        
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default , handler : {
            action in
            
            self.openPhoto(type: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default , handler : {
            action in
            
            self.openPhoto(type: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler : nil))
        
        present(alert, animated: true, completion: nil )
        
    }
    
    
    func openPhoto(type : UIImagePickerController.SourceType){
        
            let picker =  UIImagePickerController()
            picker.sourceType = type
            picker.allowsEditing = true
            picker.delegate = self
            present(picker, animated: true, completion: nil)
        
    }
    

    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true , completion: nil )
        guard let image = info[ UIImagePickerController.InfoKey.editedImage ] as? UIImage else {
            print("image not found ")
            return
        }
        self.userImg.image = image
        
        guard let imgdata = userImg.image?.pngData() else {
            return
           
        }
        
        let imgFileName = "\(FirebaseAuth.Auth.auth().currentUser!.uid)_profile_picture.png"
        StorageManager.shared.uploadProfilePicture(with: imgdata,
                                                   fileName: imgFileName) { result in
            switch result {
                
            case .success(let DaownloadUrl):
                UserDefaults.standard.set(DaownloadUrl , forKey: "porfile_picture_url")
                DatabaseManger.shared.db.child("users").child(FirebaseAuth.Auth.auth().currentUser!.uid).updateChildValues(["imgURL": DaownloadUrl])
                print(DaownloadUrl)
                self.UserinformationUpdate()
            case .failure(let error ) :
                print(error)
            }
        }
        
        
        
        
    }
    
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        
        dismiss(animated: true , completion: nil )
    }
    
    

    
    
}


extension ProfileViewController {
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { [weak self] in
                self?.userImg.image = UIImage(data: data)
            }
        }
    }
    
    
}




