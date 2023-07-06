//
//  CameraView.swift
//  Matching App
//
//  Created by Ajanth Kumarakuruparan on 2023/06/19.
//

import SwiftUI
import ARKit

struct CameraView: View {
    @State private var minimizeCameraView = true
    var body: some View{
        Button(action: {
            minimizeCameraView.toggle()
        }, label: {
            Text("Toggle Camera View")
        })
        if minimizeCameraView{
            ViewFinder().frame(maxWidth: 17.5, maxHeight: 30).cornerRadius(0.5)
        }
        else{
            ViewFinder().frame(maxWidth: 350, maxHeight: 600).cornerRadius(10)
        }
    }
}

struct ViewFinder:UIViewRepresentable {
    @EnvironmentObject var arcontroller: ARController
    
    func makeUIView(context: Context) -> ARSCNView {
        return arcontroller.sceneView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        
    }
        
}
