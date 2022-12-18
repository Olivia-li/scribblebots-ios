import Foundation
import AVFoundation
import Vision
import Combine


func jsonToString(json: Any, prettyPrinted: Bool = false) -> String {
    var options: JSONSerialization.WritingOptions = []
    if prettyPrinted {
      options = JSONSerialization.WritingOptions.prettyPrinted
    }

    do {
      let data = try JSONSerialization.data(withJSONObject: json, options: options)
      if let string = String(data: data, encoding: String.Encoding.utf8) {
        return string
      }
    } catch {
      print(error)
    }

    return ""
}

struct wristJSON: CustomStringConvertible {
    var points: [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint]
    
    // Left Leg
    var leftAnkle: VNRecognizedPoint
    var leftKnee: VNRecognizedPoint
    var leftHip: VNRecognizedPoint
    
    // Right leg
    var rightAnkle: VNRecognizedPoint
    var rightKnee: VNRecognizedPoint
    var rightHip: VNRecognizedPoint
    
    //Left Arm
    var leftWrist: VNRecognizedPoint
    var leftElbow: VNRecognizedPoint
    var leftShoulder: VNRecognizedPoint
    
    //Right Arm
    var rightWrist: VNRecognizedPoint
    var rightElbow: VNRecognizedPoint
    var rightShoulder: VNRecognizedPoint
    
    // Root
    var root: VNRecognizedPoint
    var neck: VNRecognizedPoint
    
    
    init(points: [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint]) {
        self.points = points
        self.leftWrist = self.points[.leftWrist]!
        self.rightWrist = self.points[.rightWrist]!
        
        // Left Leg
        self.leftAnkle = self.points[.leftAnkle]!
        self.leftKnee = self.points[.leftAnkle]!
        self.leftHip = self.points[.leftHip]!
        
        // Right Leg
        self.rightAnkle = self.points[.rightAnkle]!
        self.rightKnee = self.points[.rightAnkle]!
        self.rightHip = self.points[.rightHip]!
        
        // Left Arm
        self.leftWrist = self.points[.leftWrist]!
        self.leftElbow = self.points[.leftElbow]!
        self.leftShoulder = self.points[.leftShoulder]!
        
        // Right Arm
        self.rightWrist = self.points[.rightWrist]!
        self.rightElbow = self.points[.rightElbow]!
        self.rightShoulder = self.points[.rightShoulder]!
        
        // Root
        self.root = self.points[.root]!
        self.neck = self.points[.neck]!
    }
    
    
    
    var description: String {
        return jsonToString(json:
        ["wrist": ["lx": leftWrist.x, "ly": leftWrist.y, "rx": rightWrist.x, "ry": rightWrist.y],
         "body": [
            [["x": leftAnkle.x, "y": leftAnkle.y],
             ["x": leftKnee.x, "y": leftKnee.y],
             ["x": leftHip.x, "y": leftHip.y]],
            
            [["x": rightAnkle.x, "y": rightAnkle.y],
             ["x": rightKnee.x, "y": rightKnee.y],
             ["x": rightHip.x, "y": rightHip.y]],
            
            [["x": leftWrist.x, "y": leftWrist.y],
             ["x": leftElbow.x, "y": leftElbow.y],
             ["x": leftShoulder.x, "y": leftShoulder.y]],
            
            [["x": rightWrist.x, "y": rightWrist.y],
             ["x": rightElbow.x, "y": rightElbow.y],
             ["x": rightShoulder.x, "y": rightShoulder.y]],
            
            [["x": rightShoulder.x, "y": rightShoulder.y],
             ["x": neck.x, "y": neck.y],
             ["x": leftShoulder.x, "y": leftShoulder.y]],
            
            [["x": leftHip.x, "y": leftHip.y],
             ["x": rightHip.x, "y": rightHip.y]],
            
            [["x": root.x, "y": root.y],
             ["x": neck.x, "y": root.y]]
         ]
        ])
    }
    
    func toString() -> String {
        return description
    }
}

class PoseEstimator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {
    let sequenceHandler = VNSequenceRequestHandler()
    @Published var bodyParts = [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint]() {
        didSet {
            if bodyParts[.leftWrist]!.confidence >= 0.2 && bodyParts[.rightWrist]!.confidence >= 0.2 {
                let data = wristJSON(points: bodyParts).toString()
                print(data)
                vc.send(message: data)
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
