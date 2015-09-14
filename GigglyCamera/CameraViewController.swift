//
//  CameraViewController.swift
//  GigglyCamera
//
//  Created by Saqib Omer on 9/11/15.
//  Copyright (c) 2015 Kaboom Labs. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import AssetsLibrary

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    
    @IBOutlet weak var previewView: UIView!
    
    // Preoperties
    private let captureSession = AVCaptureSession()
    private let sessionQueue = dispatch_queue_create("com.kaboomlab.gigglycam.sessionqueue", nil)
    private let captureQueue = dispatch_queue_create("com.kaboomlab.gigglycam.capturequeue", nil)
    private let previewLayer = AVCaptureVideoPreviewLayer()
    private let captureOutput = AVCaptureMovieFileOutput()
    private let stillCaptureOutput = AVCaptureStillImageOutput()
    private var currentAssets = [AVAsset]()
    
    @IBOutlet weak var cameraButton: UIButton!
    
//    var tapGesture : UIGestureRecognizer!
//    var tapAndHoldGesture : UIGestureRecognizer!
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if captureSession.inputs.count == 0 {
            dispatch_async(sessionQueue, { () -> Void in
                // Setup Input
                let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
                let input = AVCaptureDeviceInput.deviceInputWithDevice(device, error: nil) as! AVCaptureDeviceInput?
                if (self.captureSession.canAddInput(input)) {
                    self.captureSession.addInput(input)
                } else {
                    println("Failed to add input")
                }
                
                if (self.captureSession.canAddOutput(self.captureOutput)) {
                    self.captureSession.addOutput(self.captureOutput)
                } else {
                    println("Failed to add output")
                }
                self.captureSession.startRunning()
                
            })
        }
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = previewLayer.superlayer.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previewLayer.session = captureSession
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewView.layer.insertSublayer(previewLayer, atIndex: 0)
        
        
        // Gestures to cameraButton
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapGesture:")
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: "tapGesture:")
        
        self.cameraButton.addGestureRecognizer(tapGesture)
        self.cameraButton.addGestureRecognizer(longTapGesture)
        
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func onPreviewLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .Began {
            self.view.backgroundColor = UIColor.redColor()
            dispatch_async(captureQueue, { () -> Void in
                self.captureOutput.startRecordingToOutputFileURL(CameraViewController.getTemporaryFileURL(), recordingDelegate: self)
            })
        } else if sender.state == .Ended {
            self.view.backgroundColor = UIColor.whiteColor()
            dispatch_async(captureQueue, { () -> Void in
                self.captureOutput.stopRecording()
            })
        }
    }
    

    
    func getImage() {
        
        if let videoConnection = stillCaptureOutput.connectionWithMediaType(AVMediaTypeVideo) {
            stillCaptureOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                                UIImageWriteToSavedPhotosAlbum(UIImage(data: imageData), nil, nil, nil)
                println("Image Saved")
                
                
            }
        }
        
    }
    
    // Capture Image
    
    func captureImage () {
        
        stillCaptureOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
        if captureSession.canAddOutput(stillCaptureOutput) {
            captureSession.addOutput(stillCaptureOutput)
        }
        
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("getImage"), userInfo: nil, repeats: false)
        
        
        
        
        
    }
    
    @IBAction func tapGesture(gesture: UIGestureRecognizer) {
        
       
        
        if let tapGestue  = gesture as? UITapGestureRecognizer {
            
            println("Tap gesture")
            captureImage()
        }
            
            
        else if let longTapGesture = gesture as? UILongPressGestureRecognizer {
            
            if longTapGesture.state == .Began {
                
                // Set tint color of image
                let buttonImage = UIImage(named: "cameraIcon")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                self.cameraButton.setImage(buttonImage, forState: .Normal)
                self.cameraButton.tintColor = UIColor.redColor()
                
//                self.cameraButton.backgroundColor = UIColor.redColor()
                dispatch_async(captureQueue, { () -> Void in
                    self.captureOutput.startRecordingToOutputFileURL(CameraViewController.getTemporaryFileURL(), recordingDelegate: self)
                    
                })
                println("Camera Recording Started")

            } else if longTapGesture.state == .Ended {
                
                // Set tint color of image
                let buttonImage = UIImage(named: "cameraIcon")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                self.cameraButton.setImage(buttonImage, forState: .Normal)
                self.cameraButton.tintColor = UIColor.clearColor()
                
                dispatch_async(captureQueue, { () -> Void in
                    self.captureOutput.stopRecording()
                })
                
                println("Camera Recording stopped")

            }
            
        }
        
        
    }
    
    @IBAction func longGestureAction(sender: UILongPressGestureRecognizer) {
        
        println("Long Tapped")
    }
    
    private class func getTemporaryFileURL() -> NSURL {
        let guid = NSUUID().UUIDString
        let outputFile = "video_\(guid).mp4"
        let outputDirectory = NSTemporaryDirectory()
        let outputPath = outputDirectory.stringByAppendingPathComponent(outputFile)
        let outputURL = NSURL.fileURLWithPath(outputPath)
        
        
        
        assert(!NSFileManager.defaultManager().fileExistsAtPath(outputPath), "Could not setup an output file. File exists.")
        
        return outputURL!
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        println("File saved! \(outputFileURL)")
        
        
        
        currentAssets.append(AVAsset.assetWithURL(outputFileURL) as! AVAsset)
        ALAssetsLibrary().writeVideoAtPathToSavedPhotosAlbum(outputFileURL, completionBlock:{ (path:NSURL!, error:NSError!) -> Void in
            if error != nil {
                println("Video Saved to camera roll")
//                let fileManage = NSFileManager.defaultManager()
//                fileManage.removeItemAtURL(outputFileURL, error: NSErrorPointer())
            }
            
        })
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        let playerVC = segue.destinationViewController as! AVPlayerViewController
//        doneButton.enabled = false
        
        var counter = currentAssets.count
        for asset in currentAssets {
            asset.loadValuesAsynchronouslyForKeys(["duration"], completionHandler: { () -> Void in
                var error: NSError?
                assert(asset.statusOfValueForKey("duration", error: &error) == .Loaded, "Failed to load clip duration")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    counter -= 1
                    if (counter == 0) {
                        self.composeVideoForPlayer(playerVC)
                        self.currentAssets.removeAll(keepCapacity: true)
                    }
                })
                
            })
        }
    }
    
    // We should be doing this work in the backgroud most likely, but since it's very simple we're safe on the main queue
    private func composeVideoForPlayer(viewController: AVPlayerViewController) {
        let composition = AVMutableComposition()
        var startTime = kCMTimeZero
        for asset in currentAssets {
            let range = CMTimeRangeMake(kCMTimeZero, asset.duration)
            var error: NSError?
            composition.insertTimeRange(range, ofAsset: asset, atTime: startTime, error: &error)
            startTime = CMTimeAdd(startTime, asset.duration)
            startTime = CMTimeAdd(startTime, CMTimeMake(1, startTime.timescale))
        }
        
        // Rotate to the orientation we recorded in. Note this code doesn't deal with cropping.
        let compositionVideoTrack = composition.tracksWithMediaType(AVMediaTypeVideo).last as! AVMutableCompositionTrack
        let assetBasisTrack = currentAssets[0].tracksWithMediaType(AVMediaTypeVideo).last as! AVAssetTrack
        compositionVideoTrack.preferredTransform = assetBasisTrack.preferredTransform
        
        viewController.player = AVPlayer(playerItem: AVPlayerItem(asset: composition))
    }

}
