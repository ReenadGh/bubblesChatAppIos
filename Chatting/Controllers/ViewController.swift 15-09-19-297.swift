//
//  ViewController.swift
//  Chatting
//
//  Created by Reenad gh on 28/05/1443 AH.
//

import UIKit
import Lottie

class ViewController: UIViewController {

    
    @IBOutlet weak var myAnimation: AnimationView!
    
    @IBOutlet weak var welcomeSideView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLayoutSubviews()
        presentSlide(slideview : welcomeSideView)
//        letsStartButton.layer.cornerRadius = 5
//        letsStartButton.clipsToBounds = true
//
       myAnimation?.loopMode = .loop
       myAnimation?.play()
       myAnimation?.backgroundColor = .clear
       }
    
    
    func presentSlide(slideview : UIView){

        UIView.animate(withDuration: 2, delay: 0, options: [.curveEaseIn],
                               animations: {
                slideview.center.y -= slideview.bounds.height
                slideview.layoutIfNeeded()
                }, completion: nil)
        
    
    }
    
        


}
