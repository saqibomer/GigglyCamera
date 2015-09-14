//
//  ViewController.swift
//  GigglyCamera
//
//  Created by Saqib Omer on 8/25/15.
//  Copyright (c) 2015 Kaboom Labs. All rights reserved.
//

import UIKit
import AVFoundation



class GigglyCameraViewController: UIViewController {
    
    // Properties
    
    
    @IBOutlet weak var cameraPreview: UIView!
    //Holds Captured Image
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var drawerButton: UIButton! // Drawer button to show/ hide imagesContainerView
    @IBOutlet weak var imagesContainerView: UIView! // Holds captured images
    @IBOutlet weak var imagesContainerBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var drawerButtonBottomConstraint: NSLayoutConstraint!
    
    let swipeUp = UISwipeGestureRecognizer() // Swipe Up gesture recognizer
    let swipeDown = UISwipeGestureRecognizer() // Swipe Down gesture recognizer
    
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var captureDevice : AVCaptureDevice?
    var devices = AVCaptureDevice.devices()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialiaze Capture Session
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        
        
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        println("Capture device found")
                        beginSession()
                    }
                }
            }
        }
        
        
        
        // Swipe Gesture
        swipeUp.direction = UISwipeGestureRecognizerDirection.Up
        swipeUp.addTarget(self, action: "swipedViewUp")
        drawerButton.addGestureRecognizer(swipeUp)
        
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        swipeDown.addTarget(self, action: "swipedViewDown")
        drawerButton.addGestureRecognizer(swipeDown)
        
        
        
        
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.previewLayer?.frame = CGRect(x: 0.0, y: 50.0, width: cameraPreview.frame.width, height: cameraPreview.frame.height)
        
    }
    
    // Status Bar is hidden
    
    override func prefersStatusBarHidden() -> Bool {
        
        return true
    }
    
    
    func updateDeviceSettings(focusValue : Float, isoValue : Float) {
        if let device = captureDevice {
            if(device.lockForConfiguration(nil)) {
                device.setFocusModeLockedWithLensPosition(focusValue, completionHandler: { (time) -> Void in
                    //
                })
                
                // Adjust the iso to clamp between minIso and maxIso based on the active format
                let minISO = device.activeFormat.minISO
                let maxISO = device.activeFormat.maxISO
                let clampedISO = isoValue * (maxISO - minISO) + minISO
                
                device.setExposureModeCustomWithDuration(AVCaptureExposureDurationCurrent, ISO: clampedISO, completionHandler: { (time) -> Void in
                    //
                })
                
                device.unlockForConfiguration()
            }
        }
    }
    
    func touchPercent(touch : UITouch) -> CGPoint {
        // Get the dimensions of the screen in points
        let screenSize = UIScreen.mainScreen().bounds.size
        
        // Create an empty CGPoint object set to 0, 0
        var touchPer = CGPointZero
        
        // Set the x and y values to be the value of the tapped position, divided by the width/height of the screen
        touchPer.x = touch.locationInView(self.view).x / screenSize.width
        touchPer.y = touch.locationInView(self.view).y / screenSize.height
        
        // Return the populated CGPoint
        return touchPer
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touchPer = touchPercent((touches.first as? UITouch)! )
        //focusTo(Float(touchPer.x))
        updateDeviceSettings(Float(touchPer.x), isoValue: Float(touchPer.y))
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touchPer = touchPercent( (touches.first as? UITouch)! )
        //focusTo(Float(touchPer.x))
        updateDeviceSettings(Float(touchPer.x), isoValue: Float(touchPer.y))
    }
    
    
    
    
    func configureDevice() {
        if let device = captureDevice {
            device.lockForConfiguration(nil)
            if device.isFocusModeSupported(.Locked) {
               device.focusMode = .Locked
            }
            
            device.unlockForConfiguration()
        }
        
    }

    func switchCamera() {
        
        var inputs = captureSession.inputs
        
        for input in inputs {
//            self.captureSession.removeInput(input as! AVCaptureInput)
            println(input)
            for device in devices {
                // Make sure this particular device supports video
                if (device.hasMediaType(AVMediaTypeVideo)) {
                    // Finally check the position and confirm we've got the back camera
                    if(device.position == AVCaptureDevicePosition.Back) {
                        captureDevice = device as? AVCaptureDevice
                        if captureDevice != nil {
                            println(captureDevice)
                            
                            
                            beginSession()
                        }
                    }
                }
            }

        }
//        self.previewLayer?.removeFromSuperlayer()
//        self.captureSession.stopRunning()
        
        
    }
    
    func beginSession() {
        
        configureDevice()
        
        var err : NSError? = nil
        captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))
        
        if err != nil {
            println("error: \(err?.localizedDescription)")
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreview.layer.zPosition = -1
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.cameraPreview.layer.addSublayer(previewLayer)
        captureSession.startRunning()
    }
    
    func switchCameraDevice() {
        
        
        
        switchCamera()
        
        // Loop through all the capture devices on this phone
//        for device in devices {
//            // Make sure this particular device supports video
//            if (device.hasMediaType(AVMediaTypeVideo)) {
//                // Finally check the position and confirm we've got the back camera
//                if(device.position == AVCaptureDevicePosition.Front) {
//                    captureDevice = device as? AVCaptureDevice
//                    if captureDevice != nil {
//                        println(captureDevice)
//                        
//                        
//                        beginSession()
//                    }
//                }
//            }
//        }
        
    }
    
    @IBAction func switchCameraAction(sender: AnyObject) {
        
        switchCameraDevice()
    }
    
    // Mark: Start Camera
    @IBAction func didtakePicture(sender: AnyObject) {
        
        
        
    }
    
    
    func swipedViewUp(){
        
        self.imagesContainerBottomConstraint.constant = +100
        self.drawerButtonBottomConstraint.constant = 112
        self.drawerButton.setImage(UIImage(named: "dragIcon"), forState: UIControlState.Normal)
        
        
        println("Swiped Up")
    }
    
    func swipedViewDown(){
        
        self.imagesContainerBottomConstraint.constant = -100
        self.drawerButtonBottomConstraint.constant = 0
        self.drawerButton.setImage(UIImage(named: "dragIconUp"), forState: UIControlState.Normal)
        
        
        println("Swiped Down")
    }
    


}

