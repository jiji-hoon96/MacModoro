import SwiftUI
import RealityKit

struct Scene3DContainerView: NSViewRepresentable {
    func makeNSView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        arView.environment.background = .color(.clear)
        arView.wantsLayer = true
        arView.layer?.isOpaque = false
        arView.layer?.backgroundColor = .clear

        let coordinator = context.coordinator
        coordinator.setupScene(in: arView)

        return arView
    }

    func updateNSView(_ nsView: ARView, context: Context) {}

    func makeCoordinator() -> SceneCoordinator {
        SceneCoordinator()
    }
}
