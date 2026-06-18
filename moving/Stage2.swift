import SpriteKit

class Stage2: StageConfiguration {
    let timeLimit: TimeInterval = 20.0
    func setup(in scene: GameScene) {
        let midX = scene.frame.midX
        let midY = scene.frame.midY
        scene.createStaticWall(yPos: scene.frame.midY + 100, gapX: 50)
        scene.createStaticWall(yPos: scene.frame.midY - 100, gapX: 50)
        scene.createCoin(pos: CGPoint(x: midX + 150, y: midY))
    }
}

