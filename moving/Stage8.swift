import SpriteKit

class Stage8: StageConfiguration {
    let timeLimit: TimeInterval = 15.0
    func setup(in scene: GameScene) {
        let midX = scene.frame.midX
        let midY = scene.frame.midY
        
        // 1. 追従者（プレッシャーを少し弱めるなら速度を 1.1 くらいに）
        scene.createFollowingEnemy(pos: CGPoint(x: scene.frame.minX + 50, y: scene.frame.minY + 50), speed: 1.1)
        
        // 2. 3つの扇（回転速度を大幅にダウン：数値を大きくする）
        
        // 下：4.5秒かけて1回転（かなりゆっくり）
        scene.createQuadrantObstacle(pos: CGPoint(x: midX, y: midY - 150),
                                     radius: 100, speed: 4.5, startAngle: 0, clockwise: true)
        
        // 中央：3.5秒かけて1回転（ここが一番の狙い目になる）
        scene.createQuadrantObstacle(pos: CGPoint(x: midX, y: midY),
                                     radius: 130, speed: 3.5, startAngle: .pi / 2, clockwise: false)
        
        // 上：4.0秒かけて1回転
        scene.createQuadrantObstacle(pos: CGPoint(x: midX, y: midY + 150),
                                     radius: 100, speed: 4.0, startAngle: .pi, clockwise: true)
        
        // 3. コインと最終防衛線はそのまま（タイミングが取りやすくなるはず）
        scene.createCoin(pos: CGPoint(x: midX + 80, y: midY))
        scene.createVerticalMovingEnemy(pos: CGPoint(x: midX - 100, y: midY + 300), duration: 1.5, range: 50)
        scene.createVerticalMovingEnemy(pos: CGPoint(x: midX + 100, y: midY + 300), duration: 1.5, range: -50)
    }
}
