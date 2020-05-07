//
//  ViewController.swift
//  macOS Camera
//
//  Created by Mihail Șalari. on 4/24/17.
//  Copyright © 2017 Mihail Șalari. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {

    // MARK: - Properties
    
    fileprivate var previewLayer: AVCaptureVideoPreviewLayer!
    fileprivate var videoSession: AVCaptureSession!
    fileprivate var cameraDevice: AVCaptureDevice!
    
    
    // MARK: - LyfeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.prepareCamera()
    }

    override func viewWillAppear() {
        if let window = self.view.window {
            window.level = .screenSaver
        }

        self.startSession()
        super.viewWillAppear()
    }

    override func viewWillDisappear() {
        self.stopSession()
        super.viewWillDisappear()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}


// MARK: - Prepare&Start&Stop camera

extension ViewController {
    
    func startSession() {
        if let videoSession = videoSession {
            if !videoSession.isRunning {
                videoSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        if let videoSession = videoSession {
            if videoSession.isRunning {
                videoSession.stopRunning()
            }
        }
    }
    
    fileprivate func prepareCamera() {
        self.videoSession = AVCaptureSession()
        self.videoSession.sessionPreset = AVCaptureSession.Preset.photo
        self.previewLayer = AVCaptureVideoPreviewLayer(session: videoSession)
        self.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        for device in AVCaptureDevice.devices() {
            if device.hasMediaType(AVMediaType.video) {
                cameraDevice = device
                    
                if cameraDevice != nil  {
                    do {
                        let input = try AVCaptureDeviceInput(device: cameraDevice)
                            
                            
                        if videoSession.canAddInput(input) {
                            videoSession.addInput(input)
                        }
                            
                        if let previewLayer = self.previewLayer {
                            if let connection = previewLayer.connection {
                                connection.automaticallyAdjustsVideoMirroring = false
                                connection.isVideoMirrored = true
                            }
                                
                            previewLayer.frame = self.view.bounds
                            view.layer = previewLayer
                            view.wantsLayer = true
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            
            
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer delegate", attributes: []))
            if videoSession.canAddOutput(videoOutput) {
                videoSession.addOutput(videoOutput)
            }
        }
    }
}

extension ViewController {

    @IBAction func flipHorizontal(_ sender: Any) {
        if let layer = view.layer {
            let halfWidth = layer.bounds.width * 0.5
            let transform = layer.affineTransform()
                .translatedBy(x:halfWidth, y:0)
                .scaledBy(x:-1, y:1)
                .translatedBy(x:-halfWidth, y:0)
            layer.setAffineTransform(transform)
        }
    }
}


// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    internal func captureOutput(_ captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        #if DEBUG
        print(Date())
        #endif
    }
}
