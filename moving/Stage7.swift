import SpriteKit

class Stage7: StageConfiguration {
    let timeLimit: TimeInterval = 15.0
    func setup(in scene: GameScene) {
        let midX = scene.frame.midX
        let midY = scene.frame.midY
        
        // ★ 中央に2つの1/4円を配置
        // 2つの扇を少し離して配置し、その「回転する隙間」を縫って上に登る設計
        
        // 左側の扇：時計回りに回転
        scene.createQuadrantObstacle(pos: CGPoint(x: midX - 60, y: midY),
                                     radius: 120, speed: 2.5, startAngle: 0, clockwise: true)
        
        // 右側の扇：反時計回りに回転
        scene.createQuadrantObstacle(pos: CGPoint(x: midX + 60, y: midY),
                                     radius: 120, speed: 2.5, startAngle: .pi, clockwise: false)
        
        // 3. 隙間の奥（上）にあるご褒美
        // 扇の回転を読み切り、中央を突破した先にコインを配置
        scene.createCoin(pos: CGPoint(x: midX, y: midY + 150))
        
        // 4. 最後の仕上げ：最上部の固定壁
        // 登りきった後に「縦棒」に変身しないと通れない狭い出口
        scene.createStaticWall(yPos: midY + 300, gapX: 100)
    }
}
