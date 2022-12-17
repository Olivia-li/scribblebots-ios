import Foundation
import AVFoundation
import Vision
import Combine

struct wristJSON: Codable, CustomStringConvertible {
    var lx: Double
    var ly: Double
    var rx: Double
    var ry: Double

    var description: String {
        return "{\"lx\": \(lx),\"ly\": \(ly),\"rx\": \(rx),\"ry\": \(ry)}"
    }
    
    func toString() -> String {
        return description
    }
}

class PoseEstimator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {
    let sequenceHandler = VNSequenceRequestHandler()
    @Published var bodyParts = [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint]() {
        didSet {
            if bodyParts[.leftWrist]!.confidence != 0 && bodyParts[.rightWrist]!.confidence != 0 {

                
                let data = wristJSON(lx: bodyParts[.leftWrist]!.x, ly: bodyParts[.leftWrist]!.y, rx: bodyParts[.rightWrist]!.x, ry: bodyParts[.rightWrist]!.y)
                vc.send(message: data.toString())
            }
        }
    }
    var wasInBottomPosition = false
    @Published var isGoodPosture = true
    
    var subscriptions = Set<AnyCancellable>()
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let humanBodyRequest = VNDetectHumanBodyPoseRequest(completionHandler: detectedBodyPose)
        do {
            try sequenceHandler.perform(
              [humanBodyRequest],
              on: sampleBuffer,
                orientation: .right)
        } catch {
          print(error.localizedDescription)
        }
    }
    
    func detectedBodyPose(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNHumanBodyPoseObservation]
        else { return }
        guard let bodyParts = try? observations.first?.recognizedPoints(.all) else { return }
        DispatchQueue.main.async {
            self.bodyParts = bodyParts
        }
    }
    

}
