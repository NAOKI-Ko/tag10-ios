import SpriteKit
import SwiftUI

struct ContentView: View {
    @State private var scene = GameScene(size: CGSize(width: 390, height: 844))

    var body: some View {
        ZStack {
            Color(red: 14 / 255, green: 18 / 255, blue: 24 / 255)
                .ignoresSafeArea()

            SpriteView(scene: scene)
        }
        .onAppear {
            scene.scaleMode = .resizeFill
        }
    }
}
