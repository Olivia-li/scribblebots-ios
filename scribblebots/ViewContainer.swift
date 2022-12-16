//
//  ARViewContainer.swift
//  scribblebots
//
//  Created by Olivia Li on 12/13/22.
//

import Foundation
import SwiftUI
import AVFoundation
import Vision

var vc = ViewController()

struct wristJSON: Codable, CustomStringConvertible {
    var lx: Double
    var ly: Double
    var rx: Double
    var ry: Double
    
    var description: String {
        return "lx: \(lx), ly: \(ly), rx: \(rx), ry: \(ry)"
    }
    
    func toString() -> String {
        return description
    }
}


struct ViewContainer: UIViewControllerRepresentable {
    var poseEstimator: PoseEstimator
    
    func makeUIViewController(context: Context) -> some UIViewController {
        vc.delegate = poseEstimator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        if poseEstimator.bodyParts[.leftWrist] != nil && poseEstimator.bodyParts[.rightWrist] != nil {
            let data = wristJSON(lx: poseEstimator.bodyParts[.leftWrist]!.x, ly: poseEstimator.bodyParts[.leftWrist]!.y, rx: poseEstimator.bodyParts[.rightWrist]!.x, ry: poseEstimator.bodyParts[.rightWrist]!.y)
            vc.send(message: data.toString())
        }
    }
}
