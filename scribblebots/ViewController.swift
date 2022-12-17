import Foundation
import UIKit
import AVFoundation
import Vision
import SwiftUI


var webSocket: URLSessionWebSocketTask?

class ViewController: UIViewController {

    private var cameraSession: AVCaptureSession?
    var delegate: AVCaptureVideoDataOutputSampleBufferDelegate?
    private let cameraQueue = DispatchQueue(
        label: "CameraOutput",
        qos: .userInteractive
    )
    override func loadView() {
        view = CameraView()
    }
    private var cameraView: CameraView { view as! CameraView }
    override func viewDidAppear(_ animated: Bool) {
        setupForWebSockets()
        super.viewDidAppear(animated)
        do {
            if cameraSession == nil {
                try prepareAVSession()
                cameraView.previewLayer.session = cameraSession
                cameraView.previewLayer.videoGravity = .resizeAspectFill
            }
            cameraSession?.startRunning()
        } catch {
            print(error.localizedDescription)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        cameraSession?.stopRunning()
        super.viewWillDisappear(animated)
    }
    func prepareAVSession() throws {
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.high
        
        guard let videoDevice = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: .front)
        else { return }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice)
        else { return }
        
        guard session.canAddInput(deviceInput)
        else { return }
        
        session.addInput(deviceInput)
        
        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
            dataOutput.setSampleBufferDelegate(delegate, queue: cameraQueue)
        } else { return }
        
        session.commitConfiguration()
        cameraSession = session
    }
    
}

extension ViewController: URLSessionWebSocketDelegate {
    func setupForWebSockets() {
        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        let url = URL(string: "ws://192.168.131.78:8000")
        webSocket = urlSession.webSocketTask(with: url!)
        webSocket?.resume()
    }

    func ping() {
        webSocket?.sendPing(pongReceiveHandler: { error in
            if let error = error {
                print("Ping error: \(error)")
            }
        })
    }

    func close() {
        webSocket?.cancel(with: .goingAway, reason: "Demo ended".data(using: .utf8))
    }
//
    func send(message: String) {
        DispatchQueue.global().asyncAfter(deadline: .now()) {
            webSocket?.send(.string(message), completionHandler: {error in
                if let error = error {
                    print("Send error: \(error)")
                }
            })

        }
    }
    
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Did open socket")
        ping()
    }

    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Did close to connection with reason")
    }
}


final class CameraView: UIView {
    
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
      }
}



