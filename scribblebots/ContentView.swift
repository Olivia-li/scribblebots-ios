import SwiftUI

struct ContentView: View {
    
    @StateObject var poseEstimator = PoseEstimator()
    
    var body: some View {
        VStack {
            ZStack {
                GeometryReader { geo in
                    ViewContainer(poseEstimator: poseEstimator)
                    StickFigureView(poseEstimator: poseEstimator, size: geo.size)
                }
            }.frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width * 1920 / 1080, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            
        }
    }
}

