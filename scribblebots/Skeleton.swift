//
//  Skeleton.swift
//  scribblebots
//
//  Created by Olivia Li on 12/15/22.
//

import Foundation
import SwiftUI


struct Stick: Shape {
    var points: [CGPoint]
    var size: CGSize
    var display: Bool
    func path(in rect: CGRect) -> Path {
        var path = Path()
        if !display {return path }
        path.move(to: points[0])
        for point in points {
            path.addLine(to: point)
        }
        return path.applying(CGAffineTransform.identity.scaledBy(x: size.width, y: size.height))
            .applying(CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -size.width, y: -size.height))
    }
}


struct StickFigureView: View {
    @ObservedObject var poseEstimator: PoseEstimator
    var size: CGSize
    var body: some View {
        if poseEstimator.bodyParts.isEmpty == false {
            ZStack {
                // Right leg
                let show_r_leg = poseEstimator.bodyParts[.rightAnkle]!.confidence >= 0.2 && poseEstimator.bodyParts[.rightKnee]!.confidence >= 0.2 && poseEstimator.bodyParts[.rightHip]!.confidence >= 0.2
                Stick(points: [poseEstimator.bodyParts[.rightAnkle]!.location, poseEstimator.bodyParts[.rightKnee]!.location, poseEstimator.bodyParts[.rightHip]!.location,
                               poseEstimator.bodyParts[.root]!.location], size: size, display: show_r_leg)
                    .stroke(lineWidth: 5.0)
                    .fill(Color.white)
                // Left leg
                let show_l_leg = poseEstimator.bodyParts[.leftAnkle]!.confidence >= 0.2 && poseEstimator.bodyParts[.leftKnee]!.confidence >= 0.2 && poseEstimator.bodyParts[.leftHip]!.confidence >= 0.2
                Stick(points: [poseEstimator.bodyParts[.leftAnkle]!.location, poseEstimator.bodyParts[.leftKnee]!.location, poseEstimator.bodyParts[.leftHip]!.location,
                               poseEstimator.bodyParts[.root]!.location], size: size, display: show_l_leg)
                    .stroke(lineWidth: 5.0)
                    .fill(Color.white)
                // Right arm
                let show_r_arm = poseEstimator.bodyParts[.rightWrist]!.confidence >= 0.2 && poseEstimator.bodyParts[.rightElbow]!.confidence >= 0.2 && poseEstimator.bodyParts[.rightShoulder]!.confidence >= 0.2
                Stick(points: [poseEstimator.bodyParts[.rightWrist]!.location, poseEstimator.bodyParts[.rightElbow]!.location, poseEstimator.bodyParts[.rightShoulder]!.location, poseEstimator.bodyParts[.neck]!.location], size: size, display: show_r_arm)
                    .stroke(lineWidth: 5.0)
                    .fill(Color.white)
                // Left arm
                let show_l_arm = poseEstimator.bodyParts[.leftWrist]!.confidence >= 0.2 && poseEstimator.bodyParts[.leftElbow]!.confidence >= 0.2 && poseEstimator.bodyParts[.leftShoulder]!.confidence >= 0.2
                Stick(points: [poseEstimator.bodyParts[.leftWrist]!.location, poseEstimator.bodyParts[.leftElbow]!.location, poseEstimator.bodyParts[.leftShoulder]!.location, poseEstimator.bodyParts[.neck]!.location], size: size, display: show_l_arm)
                    .stroke(lineWidth: 5.0)
                    .fill(Color.white)
                // Root to nose
                let show_face = poseEstimator.bodyParts[.root]!.confidence >= 0.2 && poseEstimator.bodyParts[.neck]!.confidence >= 0.2
                Stick(points: [poseEstimator.bodyParts[.root]!.location,
                               poseEstimator.bodyParts[.neck]!.location], size: size, display: show_face)
                    .stroke(lineWidth: 5.0)
                    .fill(Color.white)

                }
            }
        }
}


