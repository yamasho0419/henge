import SpriteKit

class Stage6: StageConfiguration {
    let timeLimit: TimeInterval = 10.0
    func setup(in scene: GameScene) {
        let midX = scene.frame.midX
        let midY = scene.frame.midY
        
        // 1. 導入：ゆっくりと開閉する大きな門
        // 隙間が 40px 〜 160px の間で変化する
        // 円(60px)で通れるタイミングと、変身が必要なタイミングが交互に訪れる
        scene.createPulsingWall(yPos: midY - 200, baseGap: 100, amplitude: 60, speed: 4.0)
        
        // 2. メイン：高速パルス・ツイン
        // 二つの壁が異なるリズムで伸縮。中央にコイン。
        // 面白さ：隙間が「最大」になった瞬間を狙って、縦棒(8px)で一気に二つの壁を抜き去る！
        scene.createPulsingWall(yPos: midY, baseGap: 80, amplitude: 70, speed: 2.5)
        scene.createCoin(pos: CGPoint(x: midX, y: midY))
        
        // 3. 最後の試練：極小パルス
        // 隙間が 5px 〜 40px という極狭の設定。
        // ここは「縦棒（幅8px）」に変身していても、隙間が最大の瞬間(40px)しか通れない数学的制約
        scene.createPulsingWall(yPos: midY + 200, baseGap: 22.5, amplitude: 17.5, speed: 1.5)
    }
}
