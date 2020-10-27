//
//  ContentView.swift
//  VideoToolboxExample
//
//  Created by michal on 26/10/2020.
//

import AVFoundation
import SwiftUI

struct VideoView: View {

    let displayView = RenderViewRep()
    
    var body: some View {
        displayView
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func render(_ sampleBuffer: CMSampleBuffer)  {
        displayView.render(sampleBuffer)
    }
}


struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        VideoView()
    }
}
