//
//  ImagePreviewViewController.swift
//  GigglyCamera
//
//  Created by Saqib Omer on 8/26/15.
//  Copyright (c) 2015 Kaboom Labs. All rights reserved.
//

import UIKit

class ImagePreviewViewController: UIViewController {
    
    // Propertes
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var cameraImage : UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

//        self.view.backgroundColor = UIColor(patternImage: cameraImage!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        backgroundImageView.image = cameraImage
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
