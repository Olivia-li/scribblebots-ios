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



struct ViewContainer: UIViewControllerRepresentable {
    var poseEstimator: PoseEstimator
    
    func makeUIViewController(context: Context) -> some UIViewController {
        vc.delegate = poseEstimator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
