{SurfaceUtil, Shell, Balloon, NamedManager} = require("cuttlebone")
SSP = require("ikagaka.sakurascriptplayer.js")
window["Encoding"] = require("encoding-japanese")
window["JSZip"]    = require("jszip")

hwnd = null
shell = null
balloon = null
$ukapreView = null
nmdmgr = new NamedManager()

exports.loadBalloon = loadBalloon = (url)->
  NarLoader.loadFromURL(url)
  .then (origin)->
    balloonDir = origin.asArrayBuffer()
    balloon? && balloon.unload()
    balloon = new Balloon(balloonDir)
    balloon.load()
exports.load = load = (opt={})->
  opt.balloonURL ?= "https://ikagaka.github.io/cuttlebone/nar/origin.nar"
  new Promise (resolve, reject)-> $ ->
    $ukapreView = $(ukapreView).appendTo(document.body)
    $(nmdmgr.element).appendTo(document.body)
    Promise.resolve()
    .then -> loadBalloon(opt.balloonURL)
    .then -> setup()
    .then -> resolve()
    .catch (err)-> console.error(err, err.stack); reject(err)
setup = ->
  $ukapreView.find(".narfile").change ->
    NarLoader.loadFromBlob($(this).prop("files")[0]).then(changeNar)
  $ukapreView.find(".boot").click ->
    NarLoader.loadFromURL($ukapreView.find(".narurl").val()).then(changeNar)
  $ukapreView.find(".kill").click ->
    nmdmgr.namedies[hwnd]? && nmdmgr.vanish(hwnd)
  $frag = $(document.createDocumentFragment())
  $("a[href]").each (elm,i)->
    url = $(this).attr("href")
    if /\.nar$/.test(url)
      $("<option />").val(url).text(url).appendTo($frag)
  $ukapreView.find(".narurl").append($frag)
  do ->
    # DnD
    dragging = false
    relLeft = relTop = 0
    $ukapreView.mousedown (ev)->
      dragging = true
      {top, left} = $ukapreView.offset()
      {pageX, pageY, clientX, clientY} = SurfaceUtil.getEventPosition(ev)
      relLeft = clientX - (left - window.scrollX) # サーフェス左上を起点としたマウスの相対座標
      relTop  = clientY - (top  - window.scrollY)
    $ukapreView.mouseup -> dragging = false
    $(document.body).mousemove (ev)->
      return if !dragging
      {pageX, pageY, clientX, clientY} = SurfaceUtil.getEventPosition(ev)
      $ukapreView.css({top: clientY-relTop, left: clientX-relLeft})
changeNar = (nanikaDir)->
  shelllist = nanikaDir.getDirectory("shell").listChildren()
  $frag = $(document.createDocumentFragment())
  shelllist.forEach (shellId)->
    $("<option />").val(shellId).text(shellId).appendTo($frag)
  $ukapreView.find(".shellId").children().remove().end().append($frag)
  .unbind().change -> changeShell(nanikaDir)
  if shelllist.length is 0
    return console.warn("this nar does not have any shell")
  if shelllist.indexOf("master") isnt -1
  then $ukapreView.find(".shellId").val("master").change()
  else $ukapreView.find(".shellId").val(shelllist[0]).change()
changeShell = (nanikaDir)->
  shellId = $ukapreView.find(".shellId").val()
  shellDir = nanikaDir.getDirectory("shell/"+shellId).asArrayBuffer()
  shell? && shell.unload()
  shell = new Shell(shellDir)
  shell.load().then (shell)-> uiMain()
uiMain = ->
  nmdmgr.namedies[hwnd]? && nmdmgr.vanish(hwnd)
  hwnd = nmdmgr.materialize(shell, balloon)
  named = nmdmgr.named(hwnd)
  ssp = new SSP(named)
  do ->
    $ukapreView.unbind().find(".pos").click -> named.scopes.forEach (scope)-> scope.position({right: 0, bottom:0})
    $ukapreView.unbind().submit (ev)-> ev.preventDefault(); ssp.play($ukapreView.find(".ss").val())

  do ->
    $frag = $(document.createDocumentFragment())
    Object.keys(shell.surfaceTree).forEach (surfaceId)->
      $frag.append($("<option />").val(surfaceId).text(surfaceId))
    $ukapreView.find(".surfaceId").children().remove().end().append($frag)
    .unbind().change ->
      scopeId = $ukapreView.find(".scopeId").val()
      surfaceId = $ukapreView.find(".surfaceId").val()
      $frag = $(document.createDocumentFragment())
      $("<option />").val("").text("---").appendTo($frag)
      if shell.surfaceTree[surfaceId]?
        shell.surfaceTree[surfaceId].animations.forEach (animation, i)->
          $("<option />").val(i).text(i+":"+animation.interval).appendTo($frag)
      $ukapreView.find(".animationId").children().remove().end().append($frag)
      ssp.play("\\p[#{scopeId}]\\s[#{surfaceId}]\\e")
    .val(0).change()
    .find(".animationId").unbind().change ->
      animationId = $(this).val()
      if !!srf && isFinite(Number(animationId))
        srf.stop(Number(animationId))
        srf.play(Number(animationId))
  do ->
    # 着せ替えメニュー
    $frag = $(document.createDocumentFragment())
    Object.keys(shell.bindgroup).forEach (scopeId)->
      $li = $("<li />").appendTo($frag)
      Object.keys(shell.bindgroup[scopeId]).forEach (bindgroupId)->
        $checkbox = $("<input type='checkbox' name='bindgroupId' />")
        .attr("data-scopeId", scopeId).val(bindgroupId)
        .prop("checked", shell.bindgroup[scopeId][bindgroupId])
        $("<label />").text(bindgroupId+":").append($checkbox).appendTo($li)
    $ukapreView.find(".bindgroupId").children().remove().end().append($frag)
    .find("input[name='bindgroupId'][type='checkbox']").unbind().change ->
      scopeId = $(this).attr("data-scopeId")
      bindgroupIds = {}
      $(this).each ->
        bindgroupId = $(this).val()
        if $(this).prop("checked")
        then shell.bind(scopeId, bindgroupId)
        else shell.unbind(scopeId, bindgroupId)
      shell.render()
  do ->
    # 当たり判定描画
    $ukapreView.find(".collisionDraw").unbind().change ->
      if $(this).prop("checked")
      then shell.showRegion()
      else shell.hideRegion()
  return


ukapreView = """
<form id="sspInputBox">
  <style scoped>
    #sspInputBox {
      display: inline-box;
      position: absolute;
      top: 10px;
      left: 10px;
      padding: 10px;
      background-color: #D2E0E6;
      border: 1px solid gray;
      border-top: none;
      border-left: none;
    }
    #sspInputBox input[type='text'] {
      width: 30em;
    }
  </style>
  <p>
    <label>nar: <input type="file" class="narfile" /></label>
    <label>url: <select name="narurl" class="narurl"></select></label>
    <input type="button" class="boot" value="BOOT" />
    <input type="button" class="kill" value="KILL" />
  </p>
  <p>
    <label>shell: <select name="shellId" class="shellId"></select></label>
    <label>scope: <input type="number" name="scopeId" class="scopeId" value="0" /></label>
    <label>surface: <select name="surfaceId" class="surfaceId"></select></label>
    <label>animation: <select name="animationId" class="animationId"></select></label>
    <label>collision: <input type="checkbox" class="collisionDraw" /></label>
    bindgroup: <ol class="bindgroupId" start="0"/></ol>
  </p>
  <p>
    <input type='text' class="ss" value="\\0\\s[0]Hello World!\\w8\\1\\s[10]Hello Ukagaka!\\e"/>
    <input type="submit" class="play" value="PLAY" />
    <input type="button" class="pos" value="POSITION" />
  </p>
</form>
"""
