import SwiftUI
import ARKit
import RealityKit

struct ImmersiveARView: View {
  @State var session = ARKitSession()
  @State var planeAnchorsSimple: [UUID: Entity] = [:]
  
  let handTrackingProvider = HandTrackingProvider()
  let planeData = PlaneDetectionProvider(alignments: [.horizontal, .vertical])
  
  
  let leftCollection = Entity()
  let rightCollection = Entity()
  
  var body: some View {
    RealityView { content in
      content.add(leftCollection)
      content.add(rightCollection)
      createTestSpheres()
    } update: { content in
      
      for (_, entity) in planeAnchorsSimple {
        if !content.entities.contains(entity) {
          content.add(entity)
        }
      }
    }
    .persistentSystemOverlays(.hidden)
    .overlay(alignment: .topLeading) {
      VStack(alignment: .leading) {
        Text("통합 AR 세션")
        Text("HandTracking: \(HandTrackingProvider.isSupported ? "✅" : "❌")")
        Text("PlaneDetection: \(PlaneDetectionProvider.isSupported ? "✅" : "❌")")
        Text("구체 개수: \(leftCollection.children.count + rightCollection.children.count)")
        Text("평면 개수: \(planeAnchorsSimple.count)")
      }
      .padding()
      .background(.regularMaterial)
      .clipShape(RoundedRectangle(cornerRadius: 8))
      .padding()
    }
    .task {
      await startARSession()
    }
  }
  
  func createTestSpheres() {
    let joints: [HandSkeleton.JointName] = [
      .indexFingerTip, .thumbTip, .middleFingerTip
    ]
    
    for (index, jointName) in joints.enumerated() {
      // 왼손에 붙는 구체 (파란색)
      let leftSphere = ModelEntity(
        mesh: .generateSphere(radius: 0.03),
        materials: [SimpleMaterial(color: .blue, isMetallic: false)]
      )
      leftSphere.name = jointName.description
      leftSphere.position = SIMD3<Float>(-0.2, 1.5, -1.0 - Float(index) * 0.1)
      leftCollection.addChild(leftSphere)
      
      // 오른손에 붙는 구체 (초록색)
      let rightSphere = ModelEntity(
        mesh: .generateSphere(radius: 0.03),
        materials: [SimpleMaterial(color: .green, isMetallic: false)]
      )
      rightSphere.name = jointName.description
      rightSphere.position = SIMD3<Float>(0.2, 1.5, -1.0 - Float(index) * 0.1)
      rightCollection.addChild(rightSphere)
    }
    
    print("테스트 구체 생성 완료: \(joints.count * 2)개")
  }
  
  func startARSession() async {
    guard HandTrackingProvider.isSupported && PlaneDetectionProvider.isSupported else {
      print("필요한 ARKit기능이 지원되지 않음")
      return
    }
    
    do {
      try await session.run([planeData, handTrackingProvider])
      print("planeDetection + HandTracking ARKit세션 시작")
      
      await withTaskGroup(of: Void.self) { group in
        
        group.addTask {
          await self.processPlaneUpdatesRealtime()
        }
        
        group.addTask {
          await self.processHandUpdatesRealtime()
        }
      }
      
    } catch {
      print("ARKit 세션 에러: \(error)")
    }
  }
  
  func processPlaneUpdatesRealtime() async {
    print("planeDetection 실시간 업데이트 시작")
    
    for await update in planeData.anchorUpdates {
      await handlePlaneUpdateRealtime(update)
    }
  }
  
  @MainActor
  func handlePlaneUpdateRealtime(_ update: AnchorUpdate<PlaneAnchor>) {
    switch update.event {
    case .added, .updated:
      let anchor = update.anchor
      let planeEntity = createSimplePlaneEntity(for: anchor)
      planeAnchorsSimple[anchor.id] = planeEntity
      print("평면 실시간 추가/업데이트: \(anchor.id) (총 \(planeAnchorsSimple.count)개)")
      
    case .removed:
      let anchor = update.anchor
      planeAnchorsSimple.removeValue(forKey: anchor.id)
      print("평면 실시간 제거: \(anchor.id) (총 \(planeAnchorsSimple.count)개)")
    }
  }
  
  func processHandUpdatesRealtime() async {
    print("HandTracking 실시간 업데이트 시작")
    
    for await update in handTrackingProvider.anchorUpdates {
      await updateHandRealtime(update.anchor)
    }
  }
  
  @MainActor
  func updateHandRealtime(_ handAnchor: HandAnchor) {
    guard handAnchor.isTracked else { return }
    
    let collection = handAnchor.chirality == .left ? leftCollection : rightCollection
    let handName = handAnchor.chirality == .left ? "왼손" : "오른손"
    
    guard let handSkeleton = handAnchor.handSkeleton else {
      print("⚠️ \(handName) HandSkeleton 없음")
      return
    }
    
    let joints: [HandSkeleton.JointName] = [
      .indexFingerTip, .thumbTip, .middleFingerTip
    ]
    
    var updatedCount = 0
    
    for jointName in joints {
      if true,
         let sphere = collection.findEntity(named: jointName.description) {
        
        let joint = handSkeleton.joint(jointName)
        let worldTransform = handAnchor.originFromAnchorTransform
        let jointTransform = joint.anchorFromJointTransform
        
        sphere.setTransformMatrix(worldTransform * jointTransform, relativeTo: nil)
        sphere.isEnabled = true
        updatedCount += 1
      }
    }
    
    if updatedCount > 0 {
      print("\(handName) 업데이트: \(updatedCount)개 관절")
    }
  }
  
  func createSimplePlaneEntity(for anchor: PlaneAnchor) -> Entity {
    let extent = anchor.geometry.extent
    let mesh = MeshResource.generatePlane(width: extent.width, height: extent.height)
    let material = OcclusionMaterial()
    let testMaterial = [SimpleMaterial(color: .red, isMetallic: true)]
    
    let entity = ModelEntity(mesh: mesh, materials: [material])
    
    entity.transform = Transform(matrix: matrix_multiply(anchor.originFromAnchorTransform, extent.anchorFromExtentTransform))
    
    entity.generateCollisionShapes(recursive: true, static: true)
    let physicsMaterial = PhysicsMaterialResource.generate(friction: 0, restitution: 1)
    let physics = PhysicsBodyComponent(massProperties: .default, material: physicsMaterial, mode: .static)
    entity.components.set(physics)
    
    return entity
  }
}


