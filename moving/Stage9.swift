import SpriteKit


class Stage9: StageConfiguration {
    let timeLimit: TimeInterval = 10.0
    func setup(in scene: GameScene) {
        let midX = scene.frame.midX
        let maxY = scene.frame.maxY
        
        // 5つの追従者：画面上部から一斉掃射のように降りてくる
        let spacing = scene.frame.width / 6
        for i in -2...2 {
            scene.createFollowingEnemy(pos: CGPoint(x: midX + CGFloat(i) * spacing, y: maxY - 150), speed: 1.2)
        }
        
        // ★ クランク・ゲート：横から入らないと通れない！
        // 横棒（高さ8px）に変身して、この迷路のような隙間を縫うように進む
        scene.createCrankGate(yPos: maxY - 250, gapY: 30)
        
        scene.createCoin(pos: CGPoint(x: midX, y: scene.frame.midY))
    }
}
