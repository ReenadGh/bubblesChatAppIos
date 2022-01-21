//
//  LogInViewController.swift
//  BoblesChatApp
//
//  Created by Reenad gh on 26/05/1443 AH.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class LogInViewController: UIViewController {
    private let spinner = JGProgressHUD(style: .dark)

    @IBOutlet weak var messagelbl: UILabel!
 
    @IBOutlet weak var passwordTF: DesignableUITextField!
    @IBOutlet weak var mailTF: DesignableUITextField!
    @IBOutlet weak var logInView: UIView!
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        presentSlide(slideview : logInView )
    }
     
    @IBAction func signinButtonTapped(_ sender: UIButton) {
        let signInVC = storyboard?.instantiateViewController(withIdentifier: Constats.signUpViewController)
        view.window?.rootViewController = signInVC
        view.window?.makeKeyAndVisible()
        
    }
    
    @IBAction func logInTapped(_ sender: UIButton) {
        let mail = mailTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let pass = passwordTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if mail == "" ||  pass == ""{
            messagelbl.text =    "Please fill in all Fields"
        
            }
        else{
            
            Auth.auth().signIn(withEmail: mail!, password: pass!) { [weak self] authResult, error in
             
                if error != nil {
                    self!.messagelbl.isHidden = false
                    self!.messagelbl.text = error!.localizedDescription
                
                }else{
                    guard let strongSelf = self else{
                        return
                    }
                    self?.spinner.show(in : self!.view)
                    self?.transmationTohome()
                    
                    
                  
                    DispatchQueue.main.async {
                        strongSelf.spinner.dismiss(animated: true )
                    }
                    
                }
                
    
            }
        }
        
        
        
    }
    func transmationTohome (){
        let homeVC = storyboard?.instantiateViewController(withIdentifier: Constats.homeViewController)
        view.window?.rootViewController = homeVC
        view.window?.makeKeyAndVisible()
        
    }
  
    func presentSlide(slideview : UIView){

        UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseIn],
                               animations: {
                slideview.center.y -= slideview.bounds.height
                slideview.layoutIfNeeded()
                }, completion: nil)

    }

}

extension LogInViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(LogInViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
