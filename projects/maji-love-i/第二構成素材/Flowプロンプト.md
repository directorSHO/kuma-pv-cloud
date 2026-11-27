# 第二構成：父・母メイン Aメロ（0:18–0:50）

画像4枚をそれぞれ開始画像として使い、8秒ずつ生成する想定です。これは構成上の仮タイムコードです。音源の歌唱位置との厳密な同期・口パクはまだ行っていません。生成可能な尺・消費クレジットはFlowの実際の画面で確認してください。

## 01 父ソロ：0:18–0:26

画像：01_父ソロ.png（既存素材）

8-second continuous shot, horizontal 16:9. Preserve this exact father bear identity and white, navy and silver ornate idol costume. Elegant minimal pale-gray studio. A very slow, steady camera dolly-in from the supplied framing toward a medium close-up. He looks calmly toward the camera, gently adjusts his lapel once, and makes a small restrained performance gesture. Natural breathing and occasional blink. Keep the head, paws and costume anatomically stable. No camera shake, no cuts, no new characters, no written text, no logos. No speech or music; original song will be added in editing.

## 02 父＋真顔の子ども：0:26–0:34

画像：02_父と子ども.png（新規素材）

8-second continuous shot, horizontal 16:9. Preserve the three bears and their exact costumes from the input. Father remains foreground left, calm and dignified, making one small open-paw gesture. The daughter in royal blue and son in mint stay behind him, visibly smaller by perspective. With completely deadpan faces they perform a tiny synchronized robot dance: elbows bent, forearms rotate once, one side-step left then return to their marks. Keep both children fully visible and separate from the father. Very slow restrained dolly-in, minimal white-gray studio, soft light. No extra bears, no facial morphing, no extra limbs, no text, no cuts. No speech or music.

編集で父パネル「家族愛耐久値：測定不能」を約0.8秒表示。顔や子どもに重ならない上部余白へ配置。

## 03 母ソロ：0:34–0:42

画像：03_母ソロ.png（既存素材）

8-second continuous shot, horizontal 16:9. Preserve the mother bear's exact identity, floral hair ornament and pink/burgundy ornate gown. Elegant pale-gray seamless studio. Smooth slow lateral camera slide from left to right, only a small distance, keeping her face at a stable size. She gently lowers the paw from her chest, tilts her head slightly and gives a warm subtle smile. Natural breathing and blink, gentle fabric movement. No orbit, no zoom, no cuts, no added characters or props, no text. No speech or music; the original song will be added later.

## 04 母＋真顔の子ども：0:42–0:50

画像：04_母と子ども.png（新規素材）

8-second continuous shot, horizontal 16:9. Preserve the exact mother bear foreground right and the two smaller cubs behind her on the left. Keep all costumes, faces and proportions unchanged. Mother smiles gracefully and makes a gentle outward paw gesture. Daughter in blue and son in mint keep perfectly serious faces while doing a small synchronized robot dance: forearms turn outward, one tiny side-step right and return. Keep their full bodies visible. Smooth slow lateral camera slide, subtle parallax, no large movement or orbit. Clean elegant white-gray studio. No extra characters, no text, no cuts, no speech or music.

編集で母パネル「笑顔バフ＋999」を約0.8秒表示。上部余白へ配置。

## 使い方

- 最初は01と03を生成。父・母のメイン映像を確保してから02と04を生成すると進めやすいです。
- UI素材2枚は透明PNG。画像生成には入れず、編集時に動画の上へ重ねます。
- 8秒×4本で32秒ですが、つなぎを調整する場合は既存のソロ静止画を短く差し込めます。
- キャラの口の動きは歌と同期済みではありません。厳密な口パクが必要なら音源に合わせて別工程にします。
- 動画は今回まだ生成していません。画像・UI・プロンプトの素材パックです。

## 新規画像の生成指定

内蔵画像生成を使用。家族集合画像と各親のソロ画像を参照し、同じ顔・衣装、白〜薄灰スタジオ、親を前景、真顔でロボット振付の娘と息子を後景に配置。文字・小物・他の親を追加しない指定。父は左、母は右の構図。
