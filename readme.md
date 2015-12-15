# ukagaka-preview - ukagaka shell preview bookmarklet

ゴースト配布ページにて nar を読み込んでシェルを表示するブックマークレットです。

## 使い方
1. 以下のスクリプトをブックマークとして登録します。
   ```
   javascript:(function(d,u,x,c,a){x=d.createElement("script");x.src=u;x.onload=function(){ukapre.load({balloonURL:c})};d.body.appendChild(x);}(document,"https://legokichi.github.io/ukagaka-preview/ukapre.js",null));
   ```
2. ゴースト配布ページを開きます。
3. ブックマークレットを実行します。
4. ページの一番上に管理画面が表示されます。
5. narを選択してBOOTボタンを押します。
6. ゴーストのシェルが表示されます。

## 備考
* クロスドメインには対応していない
  * 例えば [ssp.shillest.net](ssp.shillest.net) のゴースト配布ページは nar が HTTP 301 で別ドメインに飛ばされるためnarを読み込めない
* Shell.js@4.1.14 時点での実装状況
  * Shell/*/descript.txt 全般ダメ


## ギャラリー

[![汁親父](https://i.gyazo.com/500fe09e45715eaedc24e214106ad1b3.png)](https://web.archive.org/web/20080624135530/http://www.geocities.jp/kandolma/shiru.html)

[![空とあるゅう先生](https://raw.githubusercontent.com/legokichi/ukagaka-preview/master/screenshot.png)](http://himaoka.sakura.ne.jp/nanika.htm)

[![涼璃とまぐに](https://i.gyazo.com/e324464cd19f1deb48d0fd535c853de6.png)](https://web.archive.org/web/20110722114423/http://kasokeku.cool.ne.jp/)

[![HELLandHEAVEN](https://raw.githubusercontent.com/legokichi/ukagaka-preview/master/screenshot.gif)](http://www.tea-room.ne.jp/~shiki/saimohe/hah/index.html)

[![隣の羽山さん](https://i.gyazo.com/61e0841414389bd7ce3aa4d822e918ef.png)](http://macapeng.web.fc2.com/ukagaka/ukagaka.html)
