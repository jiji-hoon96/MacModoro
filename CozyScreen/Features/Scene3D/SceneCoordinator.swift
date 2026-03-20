import RealityKit
import AppKit
import Combine

final class SceneCoordinator: NSObject {
    private var anchorEntity: AnchorEntity?
    private var characterEntity: ModelEntity?
    private var behaviorController: CharacterBehaviorController?
    private var cancellables = Set<AnyCancellable>()
    private weak var arView: ARView?

    func setupScene(in arView: ARView) {
        self.arView = arView

        let anchor = AnchorEntity(world: [0, 0, 0])
        arView.scene.addAnchor(anchor)
        self.anchorEntity = anchor

        setupCamera(in: arView)
        setupLighting(in: anchor)
        setupGroundPlane(in: anchor)
        loadCharacter(in: anchor)
    }

    private func setupCamera(in arView: ARView) {
        let camera = PerspectiveCamera()
        camera.camera.fieldOfViewInDegrees = 60
        camera.position = [0, 2, 5]
        camera.look(at: [0, 0, 0], from: camera.position, relativeTo: nil)

        let cameraAnchor = AnchorEntity(world: .zero)
        cameraAnchor.addChild(camera)
        arView.scene.addAnchor(cameraAnchor)
    }

    private func setupLighting(in anchor: AnchorEntity) {
        let directionalLight = DirectionalLight()
        directionalLight.light.color = .white
        directionalLight.light.intensity = 1000
        directionalLight.light.isRealWorldProxy = false
        directionalLight.position = [2, 4, 2]
        directionalLight.look(at: [0, 0, 0], from: directionalLight.position, relativeTo: nil)
        anchor.addChild(directionalLight)

        let ambientLight = PointLight()
        ambientLight.light.color = .init(white: 0.8, alpha: 1)
        ambientLight.light.intensity = 300
        ambientLight.position = [0, 3, 0]
        anchor.addChild(ambientLight)
    }

    private func setupGroundPlane(in anchor: AnchorEntity) {
        let groundMesh = MeshResource.generatePlane(width: 10, depth: 10)
        var groundMaterial = SimpleMaterial()
        groundMaterial.color = .init(tint: .init(white: 0.3, alpha: 0.5))

        let ground = ModelEntity(mesh: groundMesh, materials: [groundMaterial])
        ground.position = [0, 0, 0]
        anchor.addChild(ground)
    }

    private func loadCharacter(in anchor: AnchorEntity) {
        let settings = AppSettings.shared
        let character = settings.selectedCharacter

        Task { @MainActor in
            do {
                let entity: ModelEntity

                if character.isBuiltIn {
                    entity = createPlaceholderCharacter()
                } else {
                    let loaded = try await Entity.loadModel(contentsOf: character.fileURL)
                    entity = loaded
                }

                entity.position = [0, 0, 0]
                entity.scale = [0.5, 0.5, 0.5]
                anchor.addChild(entity)

                self.characterEntity = entity

                let controller = CharacterBehaviorController(
                    entity: entity,
                    bounds: SIMD2<Float>(8, 8)
                )
                controller.start()
                self.behaviorController = controller
            } catch {
                print("Failed to load character: \(error)")
                let placeholder = createPlaceholderCharacter()
                placeholder.position = [0, 0, 0]
                anchor.addChild(placeholder)
                self.characterEntity = placeholder

                let controller = CharacterBehaviorController(
                    entity: placeholder,
                    bounds: SIMD2<Float>(8, 8)
                )
                controller.start()
                self.behaviorController = controller
            }
        }
    }

    private func createPlaceholderCharacter() -> ModelEntity {
        let bodyMesh = MeshResource.generateSphere(radius: 0.3)
        var bodyMaterial = SimpleMaterial()
        bodyMaterial.color = .init(tint: .systemTeal)

        let body = ModelEntity(mesh: bodyMesh, materials: [bodyMaterial])
        body.position.y = 0.3

        let headMesh = MeshResource.generateSphere(radius: 0.15)
        var headMaterial = SimpleMaterial()
        headMaterial.color = .init(tint: .systemPink)

        let head = ModelEntity(mesh: headMesh, materials: [headMaterial])
        head.position = [0, 0.4, 0]
        body.addChild(head)

        return body
    }
}
