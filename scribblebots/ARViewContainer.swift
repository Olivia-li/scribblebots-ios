//
//  ARViewContainer.swift
//  scribblebots
//
//  Created by Olivia Li on 12/13/22.
//

import Foundation
import SwiftUI
import ARKit
import RealityKit

private var bodySkeleton: BodySkeleton?
private let bodySkeletonAnchor = AnchorEntity()
private var webSocket: URLSessionWebSocketTask?

struct ARViewContainer: UIViewRepresentable {
    
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: true)
        
        arView.setupForBodyTracking()
        arView.setupForWebSockets()
        arView.scene.addAnchor(bodySkeletonAnchor)
        
        return arView
    }
        
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
        
    typealias UIViewType = ARView
    
}

extension ARView: ARSessionDelegate, URLSessionWebSocketDelegate {
    func setupForBodyTracking() {
        let configuration = ARBodyTrackingConfiguration()
        self.session.run(configuration)
        self.session.delegate = self
    }
    
    func setupForWebSockets() {
        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        let url = URL(string: "wss://scribblebots.ngrok.io")
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
    
    func send(message: String) {
        DispatchQueue.global().asyncAfter(deadline: .now()+1) {
            self.send(message: message)
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
    
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let bodyAnchor = anchor as? ARBodyAnchor{
                if let skeleton = bodySkeleton {
                    skeleton.update(with: bodyAnchor)
                    var json = HandJSON(lx: skeleton.l_hand!.position.x, ly: skeleton.l_hand!.position.y, rx: skeleton.r_hand!.position.x, ry: skeleton.r_hand!.position.y)
                    send(message: "{x: \(skeleton.l_hand!.position.x), y: \(skeleton.l_hand!.position.y)}")
                }
                else {
                    bodySkeleton = BodySkeleton(for: bodyAnchor)
                    bodySkeletonAnchor.addChild(bodySkeleton!)
                }
            }
        }
    }
}
