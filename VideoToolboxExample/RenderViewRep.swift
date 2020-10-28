//
//  RenderView.swift
//  VideoToolboxExample
//
//  Created by michal on 26/10/2020.
//

import AppKit
import AVFoundation
import MetalKit
import SwiftUI

final class RenderViewRep: NSViewRepresentable {

    typealias NSViewType = RenderView

    var view: RenderView!

    func makeNSView(context: Context) -> RenderView {
        let view = RenderView(frame: .zero, device: MTLCreateSystemDefaultDevice())
        self.view = view
        return view
    }

    func updateNSView(_ nsView: RenderView, context: Context) {
        print("updateNSView")
    }

    func render(_ sampleBuffer: CMSampleBuffer) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        view?.render(imageBuffer)
    }

}

class RenderView: MTKView {

    private var ciImage: CIImage? {
        didSet {
            draw()
        }
    }

    private lazy var commandQueue: MTLCommandQueue? = { [unowned self] in
        return self.device!.makeCommandQueue()
    }()

    private lazy var ciContext: CIContext = { [unowned self] in
        return CIContext(mtlDevice: self.device!)
    }()

    override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        wantsLayer = true
        if super.device == nil {
            fatalError("No metal")
        }
        framebufferOnly = false
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func draw(_ rect: CGRect) {
        self.render()
    }

    // disable error sound for key down events (space bar for play / pause)
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        return true
    }

    func render(_ pixelBuffer: CVImageBuffer) {
        ciImage = CIImage(cvImageBuffer: pixelBuffer)
    }

    private func render() {
        guard let ciImage = ciImage,
              let drawable = currentDrawable,
              let commandBuffer = commandQueue?.makeCommandBuffer() else { return }
        withExtendedLifetime(ciImage) { () -> Void in
            let renderDestination = CIRenderDestination(mtlTexture: drawable.texture, commandBuffer: commandBuffer)
            let task = try? ciContext.startTask(toRender: ciImage, to: renderDestination)
            commandBuffer.present(drawable)
            commandBuffer.commit()
            _ = try? task?.waitUntilCompleted()
        }

    }
}
