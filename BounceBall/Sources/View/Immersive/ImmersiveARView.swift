//
//  ImmersiveView.swift
//  BounceBall
//
//  Created by apple on 9/12/25.
//

import SwiftUI
import ARKit
import RealityKit
import RealityKitContent

struct ImmersiveARView: View {
  @State var session = ARKitSession()
  
  @State var planeAnchorsSimple: [UUID: Entity] = [:]
  
  var body: some View {
    RealityView { content in
      
    } update: { content in
      
      for (_, entity) in planeAnchorsSimple {
        if !content.entities.contains(entity) {
          content.add(entity)
        }
      }
    }
    .task {
      try! await setupAndRunPlaneDetection()
    }
  }
  
  func setupAndRunPlaneDetection() async throws {
    let planeData = PlaneDetectionProvider(alignments: [.horizontal, .vertical, ])
    if PlaneDetectionProvider.isSupported {
      do {
        try await session.run([planeData])
        for await update in planeData.anchorUpdates {
          switch update.event {
          case .added, .updated:
            let anchor = update.anchor
            
            let planeEntitySimple = createSimplePlaneEntity(for: anchor)
            planeAnchorsSimple[anchor.id] = planeEntitySimple
            print("앵커ID:", anchor.id, anchor.timestamp)
            
          case .removed:
            let anchor = update.anchor
            planeAnchorsSimple.removeValue(forKey: anchor.id)
          }
          
        }
      }
      catch {
        print("ARKit session error \(error)")
      }
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





#Preview(immersionStyle: .mixed) {
  ImmersiveARView()
    .environment(AppModel())
}   