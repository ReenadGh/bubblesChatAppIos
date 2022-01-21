//
//  SignUpViewController.swift
//  BoblesChatApp
//
//  Created by Reenad gh on 26/05/1443 AH.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Firebase

class SignUpViewController: UIViewController {
    @IBOutlet weak var messagelbl: UILabel!
    @IBOutlet weak var firstNameTF: DesignableUITextField!
    @IBOutlet weak var lastNameTF: DesignableUITextField!
    @IBOutlet weak var passwordTF: DesignableUITextField!
    @IBOutlet weak var confirmPasswodTF: DesignableUITextField!
    @IBOutlet weak var mailTF: DesignableUITextField!
    @IBOutlet weak var SignUpSlideView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
      //  SignUpSlideView.igno
   presentSlide(slideview : SignUpSlideView)
        self.hideKeyboardWhenTappedAround()

    }
    
    @IBAction func logInButtonTapped(_ sender: UIButton) {
        let logInVC = storyboard?.instantiateViewController(withIdentifier: Constats.loginViewController)
        view.window?.rootViewController = logInVC
        view.window?.makeKeyAndVisible()
    }
    
    
    func falidateFields ()-> String {

     
        if firstNameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            mailTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            confirmPasswodTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            
            return "Please fill in all Fields"
        }
        
        if (passwordTF.text! != confirmPasswodTF.text!){
            return "Your password and confirmation password do not match"
        }
        
        return ""
    }
    
    func showErrorMessage(error : String! ){
        messagelbl.isHidden = false
        messagelbl.text = error
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        
        let error = falidateFields ()
        
        if (error != ""){
            showErrorMessage(error: error)
            
        }else {
            // crate new user in database
            
            Auth.auth().createUser(withEmail:  mailTF.text!, password:  passwordTF.text!) {  result, err in
                if err != nil {
                     //error in crate the user
                    self.showErrorMessage(error: err?.localizedDescription)
                }else {
                    // add more info to db depend on user id
                    
                    let fname = self.firstNameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                    let lname = self.lastNameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)

               
                    
                    do {
                        DatabaseManger.shared.insertUser( user: ChatAppUser.init(UserId: result!.user.uid
                                                       , firstName: fname!,
                                                       lastName: lname!,
                                                       emailAddress: result!.user.email!,
                                                      imgDataURL: "" 
                                                                                ), completion:{result  in
                            
                            
                        })
                                                       self.transmationTohome ()
                    }catch{
                        
                    }

                    
                    
                }
                
            }
            
            
        }
        
        
    }
    
    
    
    func presentSlide(slideview : UIView){
        
        

    
        
        UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseIn],
                               animations: {
                slideview.center.y -= slideview.bounds.height
                slideview.layoutIfNeeded()
                }, completion: nil)
        
    
    }
    
    func transmationTohome (){
        let homeVC = storyboard?.instantiateViewController(withIdentifier: Constats.homeViewController)
        view.window?.rootViewController = homeVC
        view.window?.makeKeyAndVisible()
        
    }

}

// Put this piece of code anywhere you like
extension SignUpViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
