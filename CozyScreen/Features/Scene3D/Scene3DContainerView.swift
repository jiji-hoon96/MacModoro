import SwiftUI
import RealityKit

struct Scene3DContainerView: NSViewRepresentable {
    func makeNSView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        let coordinator = context.coordinator
        coordinator.setupScene(in: arView)

        return arView
    }

    func updateNSView(_ nsView: ARView, context: Context) {}

    func makeCoordinator() -> SceneCoordinator {
        SceneCoordinator()
    }
}
