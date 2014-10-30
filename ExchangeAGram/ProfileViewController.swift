//
//  ProfileViewController.swift
//  ExchangeAGram
//
//  Created by Dave Arnoldi on 2014/10/30.
//  Copyright (c) 2014 Dave Arnoldi. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, FBLoginViewDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var fbLoginView: FBLoginView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "publish_actions"]
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    //FB LOGIN functions from FBLoginDelegate
    
    
    func loginViewShowingLoggedInUser(loginView: FBLoginView!) {
        profileImageView.hidden = false
        nameLabel.hidden = false
    }

    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser!) {
        
        println(user)
        
        nameLabel.text = user.name
        
        let userImageURL = "https://graph.facebook.com/\(user.objectID)/picture?type=small"
        let url = NSURL(string: userImageURL)
        let imageDat = NSData(contentsOfURL: url!)
        let image = UIImage(data: imageDat!)
        profileImageView.image = image
    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        profileImageView.hidden = true
        nameLabel.hidden = true
    }
    
    func loginView(loginView: FBLoginView!, handleError error: NSError!) {
        println("Error: \(error.localizedDescription)")
    }
}
