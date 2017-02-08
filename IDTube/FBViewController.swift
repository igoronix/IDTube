//
//  FBViewController.swift
//  IDTube
//
//  Created by igor on 2/8/17.
//
//

import UIKit
import FacebookLogin

class FBViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = LoginButton(readPermissions: [.email,.publicProfile, .custom("user_birthday"), .custom("user_location")])
        button.delegate = self
        button.center = view.center
        view.addSubview(button)
        // Do any additional setup after loading the view.
    }
}

extension FBViewController: LoginButtonDelegate {
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        print("Did complete login via LoginButton with result \(result)")
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print("Did logout via LoginButton")
    }
}
