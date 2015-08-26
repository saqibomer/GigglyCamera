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
    var selectedDevice: AVCaptureDevice? = nil;
    let captureSession = AVCaptureSession();
    var previewLayer: AVCaptureVideoPreviewLayer? = nil;
    var observer:NSObjectProtocol? = nil
    let stillImageOutput = AVCaptureStillImageOutput()
    
    var captureButton : UIButton!
    var previewImage : UIImageView!
    var capturedImage : UIImage!
    
//    let previewController = ImagePreviewViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
        selectedDevice = findCameraWithPosition(.Back);
        
        processOrientationNotifications();
        
        
        
    }
    
    deinit {
        // Cleanup
        if observer != nil {
            NSNotificationCenter.defaultCenter().removeObserver(observer!);
        }
        
        UIDevice.currentDevice().endGeneratingDeviceOrientationNotifications();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.previewLayer?.bounds = self.view.bounds
        
    }
    
    
    // Stop Session and remove view from super view
    func stopSession(){
        
       
        self.captureSession.stopRunning()
        self.captureButton.removeFromSuperview()
        self.previewLayer?.removeFromSuperlayer()
        
        // Show Preview of Image
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("previewView") as! ImagePreviewViewController
//        println("captured Image \(capturedImage)")
        vc.cameraImage = capturedImage
        
//        println("camera Image = \(vc.cameraImage)")
//        self.presentedViewController?.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
        self.presentViewController(vc, animated: true, completion: nil)
        
            
    }
    
    func getImage() {
        
        if let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) {
            stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
//                UIImageWriteToSavedPhotosAlbum(UIImage(data: imageData), nil, nil, nil)
                
                self.capturedImage = UIImage(data: imageData)
                self.stopSession()
                
            }
        }
        
    }
    
    // Capture Image
    
    func captureImage () {
        
        stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }
        
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: Selector("getImage"), userInfo: nil, repeats: false)
        
        
        
        
        
        
    }
    
    func findCameraWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo);
        for device in devices as! [AVCaptureDevice] {
            if(device.position == position) {
                return device;
            }
        }
        
        return nil;
    }
    
    func startCapture() {
        if let device = selectedDevice {
            var err : NSError? = nil
            captureSession.addInput(AVCaptureDeviceInput(device: device, error: &err))
            
            if err != nil {
                println("error: \(err?.localizedDescription)")
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            captureButton = UIButton(frame: CGRect(x: self.view.frame.width / 2 - 25, y: self.view.frame.height - 60, width: 50, height: 50))
            captureButton.setImage(UIImage(named: "cameraIcon")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), forState: UIControlState.Normal)
            captureButton.addTarget(self, action: "captureImage", forControlEvents: UIControlEvents.TouchUpInside)
            self.view.layer.addSublayer(previewLayer)
            
            previewLayer?.frame = self.view.layer.frame;
            self.view.addSubview(captureButton)
            captureSession.startRunning()
        }
        
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator);
        if let layer = previewLayer {
            layer.frame = CGRectMake(0,0,size.width, size.height);
        }
    }
    
    func processOrientationNotifications() {
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications();
        observer = NSNotificationCenter.defaultCenter().addObserverForName(UIDeviceOrientationDidChangeNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [unowned self](notification: NSNotification!) -> Void in
            if let layer = self.previewLayer {
                switch UIDevice.currentDevice().orientation {
                case .LandscapeLeft: layer.connection.videoOrientation = .LandscapeRight;
                case .LandscapeRight: layer.connection.videoOrientation = .LandscapeLeft;
                default: layer.connection.videoOrientation = .Portrait;
                }
            }
        }
    }
    
    
    
    @IBAction func didtakePicture(sender: AnyObject) {
        
        startCapture();
        
        
    }


}

