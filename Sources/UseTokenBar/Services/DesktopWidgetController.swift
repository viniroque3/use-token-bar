import Foundation
import AppKit
import SwiftUI

public final class DesktopWidgetController {
    public static let shared = DesktopWidgetController()

    private var panel: NSPanel?

    private init() {}

    public func setWidgetSize(_ size: DesktopWidgetSize) {
        DispatchQueue.main.async {
            switch size {
            case .off:
                self.panel?.orderOut(nil)
            case .small, .large:
                self.showWidget(size: size)
            }
        }
    }

    private func showWidget(size: DesktopWidgetSize) {
        let width: CGFloat = size == .small ? 180 : 350
        let height: CGFloat = size == .small ? 140 : 250

        if panel == nil {
            let p = NSPanel(
                contentRect: NSRect(x: 100, y: 100, width: width, height: height),
                styleMask: [.borderless, .nonactivatingPanel],
                backing: .buffered,
                defer: false
            )
            p.isFloatingPanel = true
            p.level = .floating
            p.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            p.isMovable = true
            p.isMovableByWindowBackground = true
            p.backgroundColor = .clear
            p.hasShadow = true

            if let screen = NSScreen.main {
                let screenRect = screen.visibleFrame
                let originX = screenRect.maxX - width - 40
                let originY = screenRect.minY + 60
                p.setFrameOrigin(NSPoint(x: originX, y: originY))
            }

            self.panel = p
        }

        guard let p = self.panel else { return }

        let hostingView = NSHostingView(rootView: DesktopWidgetView(size: size))
        p.contentView = hostingView

        var frame = p.frame
        frame.size = NSSize(width: width, height: height)
        p.setFrame(frame, display: true, animate: true)

        p.orderFrontRegardless()
    }
}
