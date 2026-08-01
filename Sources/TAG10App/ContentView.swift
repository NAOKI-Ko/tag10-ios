import SpriteKit
import SwiftUI

struct ContentView: View {
    @State private var scene = GameScene(size: CGSize(width: 390, height: 844))

    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
            .onAppear {
                scene.scaleMode = .resizeFill
            }
    }
}
