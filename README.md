# UnityShaders
Unity用シェーダーを作っていってます

#アップデート
イメージエフェクト版の簡易NINGYOU Shaderのスクリプトを追加しました。(2016/06/10)

##NINGYOUシェーダーについて

NINGYOUシェーダーは影の色味をいじることにより、リアル系シェーダとトゥーン系シェーダの中間のような表現ができるため、名前のとおりフィギュアや人形の質感表現に向いているシェーダーです。
現在UnityのAssetStoreに登録する前の段階で、テストコードとして登録しています。

###使い方

Unityはフリー版ライセンスでも大丈夫です。シェーダーは4つあります。

* FigureShader.shader - バンプマップなし、カラーテクスチャとディフューズとスペキュラの設定がある。
* FigureShader_DS.shader - FigureShader.shader の両面表示版
* FigureShader_Bump.shader - バンプマップ、カラーテクスチャとディフューズとスペキュラの設定がある。
* FigureShader_Bump_DS.shader - FigureShader_Bump.shader の両面表示版

パラメータの意味については以下を参照してください。

* Main Color - ベース色だが現在未実装。基本テクスチャありきなので、将来的には廃止するかも
* Specular Color - スペキュラ反射の色、明るい色だと強い反射をする
* Shadow Color - 影の色を濃くする。128(0.5)あたりから調整するのが良い
* Specular Sharpness - スペキュラ反射の鋭さ。0に設定すると表示がおかしくなるので注意。だいたい0.5-20ぐらいの範囲
* Warm color Division - 暖色系の色味の変化量を設定する。大きいほど変化が弱くなる。0を設定しない。2-16あたりが効果が分かりやすい
* Cold color Division - 寒色系の色味の変化量を設定する。大きいほど変化が弱くなる。0を設定しない。2-16あたりが効果が分かりやすい
* Warm color Cofficient - 暖色系の色味の変化のしやすさを設定する。大きいほど変化がしにくくなる。0を設定しない。大体0.5-2.0の範囲
* Cold color Cofficient - 寒色系の色味の変化のしやすさを設定する。大きいほど変化がしにくくなる。0を設定しない。大体0.5-2.0の範囲
* Base (RGB) - カラーテクスチャ
* Normal Map - 法線マップ
* Diffuse Strength - 光源に対する反応を変化させる。0.0-1.0の間で設定する
* Bump Strength - バンプマップの強さを変化させる。0.0-2.0の間で設定する


####ImageEffect(SelectiveNCorrection.cs)の使い方
* SelectiveNCorrection.csをカメラのあるGameObjectにドラッグ＆ドロップ
* N CorrectionのテクスチャにImageEffects/Texturesフォルダ内にあるhue_val1かhue_val2をセット(hue_defaultは色味変化が付けられていないテクスチャ)
* パラメータを変えて使う

自分で色味の変化を定義したい場合は、各色が一番暗くなったときに色相がどう変化するかを想定して、hue_default.bmpをPhotoshopやGimpなどのソフトで色相をいじってください。

###ライセンスについて

Copyright (c) 2015 Tatsuro Matsubara

MITライセンスのもとで公開しています。  
http://opensource.org/licenses/mit-license.php
