import SpriteKit

class Stage1: StageConfiguration {
    let timeLimit: TimeInterval = 20.0
    func setup(in scene: GameScene) {
        let midX = scene.frame.midX
        let midY = scene.frame.midY
      
        
        // 1段目（下）：導入
        // 隙間を120pxに設定。かなり余裕を持って通れる
        scene.createStaticWall(yPos: midY - 200, gapX: 120)
        
        // 2段目（中）：回避の練習
        // 真ん中に150pxの障害物。左右どちらかに避けて進む
        scene.createCenterWall(yPos: midY, width: 150)
        
        // 3段目（上）：ここが変更点！
        // ★ 隙間を 20px -> 80px に拡大
        // 自機の円（直径60px）でも、左右に10pxずつの余裕を持って通り抜けられる設計
        scene.createStaticWall(yPos: midY + 200, gapX: 80)
        
        // コイン：一番上の壁を抜けた先に配置
        // 円のままでも取れるし、練習として変身して取ってもOK
        scene.createCoin(pos: CGPoint(x: midX, y: midY + 300))
    }
}
