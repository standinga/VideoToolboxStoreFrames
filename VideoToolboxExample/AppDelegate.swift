//
//  AppDelegate.swift
//  VideoToolboxExample
//
//  Created by michal on 26/10/2020.
//

import AVFoundation
import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, AVManagerDelegate {

    var window: NSWindow!
    var window2: NSWindow!

    let avManager = AVManager()

    let cameraView = VideoView()

    let decoderView = VideoView()

    private var coder: H264Coder?

    private var decoder: H264Decoder?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.center()
        window.setTitleWithRepresentedFilename("Camera")
        window.contentView = NSHostingView(rootView: cameraView)
        window.makeKeyAndOrderFront(nil)

        window2 = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window2.isReleasedWhenClosed = false
        window2.center()
        window2.setTitleWithRepresentedFilename("Decoded")
        window2.contentView = NSHostingView(rootView: decoderView)
        window2.makeKeyAndOrderFront(nil)

        avManager.delegate = self
        avManager.start()
    }

    // MARK: - AVManagerDelegate

    func onSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        cameraView.render(sampleBuffer)
        if coder == nil,
           let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) {
            let dimens = formatDescription.dimensions
            coder = H264Coder(width: dimens.width, height: dimens.height, callback: { encodedBuffer in
                self.decodeCompressedFrame(encodedBuffer)
            })
        }
        coder?.encode(sampleBuffer)
    }

    func didChangeFormat(_ format: AVCaptureDevice.Format) {
        print("didchangeformat")
        coder?.stop()
        coder = nil
        decoder?.stop()
        decoder = nil
    }

    private func decodeCompressedFrame(_ sampleBuffer: CMSampleBuffer) {
        if decoder == nil,
           let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) {
            decoder = H264Decoder(formatDescription: formatDescription) { decoded in
                self.decoderView.render(decoded)
            }
        }
        decoder?.decode(sampleBuffer)
    }

}

