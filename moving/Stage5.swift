import SpriteKit

class Stage5: StageConfiguration {
    let timeLimit: TimeInterval = 20.0
    func setup(in scene: GameScene) {
        let midX = scene.frame.midX
        let midY = scene.frame.midY
        
        // 1. 中央のターゲット（コイン）を配置
        scene.createCoin(pos: CGPoint(x: midX, y: midY))
        
        // 2. 時計回りに回転する細長い障害物（1つ）
        // 横幅（長さ）を240px、厚みを10pxに設定し、より「細長い」形状にしました
        let wallSize = CGSize(width: 240, height: 10)
        // 回転半径を調整。中心から少し離すことで、コイン周辺に自機が入るスペースを確保しています
        let orbitRadius: CGFloat = 120
        let rotateSpeed: TimeInterval = 3.0 // 3秒で一周
        
        // 回転の軸となるノード
        let pivotNode = SKNode()
        pivotNode.position = CGPoint(x: midX, y: midY)
        scene.addChild(pivotNode)
        
        // 障害物本体の作成
        let obstacle = SKShapeNode(rectOf: wallSize)
        obstacle.fillColor = .red
        obstacle.strokeColor = .white
        obstacle.lineWidth = 1
        obstacle.position = CGPoint(x: orbitRadius, y: 0)
        
        // 物理ボディの設定
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: wallSize)
        obstacle.physicsBody?.isDynamic = false
        obstacle.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        
        pivotNode.addChild(obstacle)
        
        // 時計回りの回転アクションを実行
        // 負の方向に回転させることで時計回りになります
        pivotNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: -CGFloat.pi * 2, duration: rotateSpeed)))
    }
}
