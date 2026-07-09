<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<title>我的农场</title>
<style>
:root {
  --grass:#8fc45f; --grass-d:#6ba13d; --grass-l:#b6dd8a;
  --sky:#bfe6f7;
  --wood:#c07f45; --wood-d:#8a561f; --wood-l:#e0b075;
  --soil:#7a5333; --soil-d:#573a20; --soil-l:#9a6d42;
  --panel:#fffaf0; --panel-2:#fff3dc;
  --text:#4a3b2a; --text-light:#9a8768;
  --gold:#f6c445; --gold-d:#d99b1f;
  --red:#e07b6c; --blue:#7bb4d4; --pink:#e892b0; --green:#6fa84a;
  --jy:#E892B0; --sq:#6B9B77;
  --shadow: 0 6px 20px rgba(90,60,25,.14);
  --radius: 18px;
}
* { margin:0; padding:0; box-sizing:border-box; -webkit-tap-highlight-color:transparent; }
body {
  font-family: "PingFang SC","Microsoft YaHei","Noto Sans SC",sans-serif;
  background: #e8f3d6;
  color: var(--text); min-height: 100vh;
  background-image:
    radial-gradient(circle at 20% 0%, #cdeeb0 0%, transparent 45%),
    radial-gradient(circle at 90% 10%, #bfe6f7 0%, transparent 40%),
    linear-gradient(180deg,#dff0c8,#e8f3d6);
}

/* ===== PIN ===== */
.pin-overlay {
  position:fixed; inset:0; z-index:1000;
  display:flex; align-items:center; justify-content:center;
  background: linear-gradient(160deg,#8fc45f,#5d8f3a);
  transition: opacity .45s, visibility .45s;
}
.pin-overlay::before {
  content:""; position:absolute; inset:0;
  background:
    radial-gradient(circle at 15% 20%, rgba(255,255,255,.25) 0 3px, transparent 4px) 0 0/60px 60px,
    radial-gradient(circle at 60% 70%, rgba(255,255,255,.18) 0 2px, transparent 3px) 0 0/40px 40px;
  opacity:.5;
}
.pin-overlay.hidden { opacity:0; visibility:hidden; }
.pin-box {
  position:relative; background: var(--panel); border-radius: 24px;
  padding: 34px 28px; text-align:center; max-width: 330px; width: 88%;
  box-shadow: 0 18px 50px rgba(0,0,0,.25);
  border: 4px solid var(--wood-l);
}
.pin-box .icon { font-size: 56px; margin-bottom: 6px; filter: drop-shadow(0 4px 6px rgba(0,0,0,.15)); }
.pin-box h2 { font-size: 22px; font-weight: 800; margin-bottom: 4px; color: var(--wood-d); }
.pin-box .hint { font-size: 13px; color: var(--text-light); margin-bottom: 18px; }
.pin-input {
  width: 100%; padding: 13px 16px; border: 3px solid #e7ddc7;
  border-radius: 14px; font-size: 20px; text-align: center;
  letter-spacing: 8px; outline: none; transition: border .3s; background:#fffdf7;
}
.pin-input:focus { border-color: var(--grass-d); }
.pin-btn {
  margin-top: 14px; width: 100%; padding: 13px; border: none;
  border-radius: 14px; font-size: 16px; font-weight: 800; letter-spacing:2px;
  background: linear-gradient(180deg,#8fc45f,#6ba13d); color: white; cursor: pointer;
  box-shadow: 0 5px 0 #588a30; transition: transform .12s, box-shadow .12s;
}
.pin-btn:active { transform: translateY(4px); box-shadow: 0 1px 0 #588a30; }
.pin-error { color: var(--red); font-size: 13px; margin-top: 10px; min-height: 20px; font-weight:600; }

/* ===== 布局 ===== */
.app-container { max-width: 520px; margin: 0 auto; padding: 10px 12px 100px; overflow: hidden; }

/* ===== 顶部 HUD（木牌） ===== */
.hud {
  display:flex; align-items:center; gap:10px;
  background: linear-gradient(180deg,var(--wood-l),var(--wood));
  border: 3px solid var(--wood-d); border-radius: 18px;
  padding: 8px 12px; box-shadow: var(--shadow); position:relative;
  margin-bottom: 12px;
}
.hud-avatar {
  width: 48px; height: 48px; flex-shrink:0; border-radius: 50%;
  background: radial-gradient(circle at 35% 30%, #fff, #ffe4b0);
  border: 3px solid #fff; box-shadow: 0 2px 6px rgba(0,0,0,.2);
  display:flex; align-items:center; justify-content:center; font-size: 26px;
}
.hud-info { flex:1; min-width:0; color:#fff; }
.hud-name { font-size: 15px; font-weight: 800; text-shadow: 0 1px 2px rgba(0,0,0,.25); }
.hud-coins { display:flex; gap:8px; margin-top:3px; }
.hud-coins span {
  background: rgba(255,255,255,.9); color: var(--wood-d);
  border-radius: 20px; padding: 2px 10px; font-size: 12px; font-weight: 700;
  display:inline-flex; align-items:center; gap:3px;
}
.hud-coins b { color: var(--gold-d); }
.hud-logo {
  font-size: 15px; font-weight: 900; color: #fff; white-space:nowrap;
  text-shadow: 0 2px 3px rgba(0,0,0,.3); letter-spacing:1px;
}

/* ===== 面板 ===== */
.panel { display: none; animation: panelIn .35s ease; }
.panel.active { display: block; }
@keyframes panelIn { from{opacity:0; transform:translateY(8px);} to{opacity:1; transform:none;} }
.card {
  background: var(--panel); border-radius: var(--radius); padding: 18px;
  box-shadow: var(--shadow); margin-bottom: 14px; border: 3px solid #efe2c8;
}
.card-title { text-align:center; font-weight:800; font-size:16px; margin-bottom:12px; color:var(--wood-d); }

/* ============================================================
   农场场景（等距 2.5D）
   ============================================================ */
.farm-scene {
  position: relative; height: 60vh; min-height: 400px; max-height: 520px;
  border-radius: 22px; overflow: hidden;
  border: 10px solid var(--wood-d);
  outline: 4px solid var(--wood-l);
  outline-offset: 2px;
  box-shadow:
    var(--shadow),
    0 0 0 6px var(--wood),
    0 0 0 10px var(--wood-l),
    inset 0 0 60px rgba(0,0,0,.08);
  background:
    linear-gradient(180deg,#bfe6f7 0%, #cfeacb 22%, #a7d477 40%, #8fc45f 66%, #7ab84e 100%);
  perspective: 1000px; perspective-origin: 50% 30%;
  touch-action: manipulation;
}
/* 远处山丘 */
.hill { position:absolute; border-radius:50%; }
.hill.h1 { width:70%; height:120px; left:-10%; top:14%; background:#9cce74; }
.hill.h2 { width:60%; height:110px; right:-8%; top:12%; background:#8fc767; }
/* 河流 */
.river {
  position:absolute; left:-6%; bottom:-4%; width:52%; height:80px;
  background: linear-gradient(180deg,#8fd0ee,#6bb6dd);
  border-radius: 60% 40% 30% 70%/60% 50% 60% 40%;
  transform: rotate(-6deg); box-shadow: inset 0 3px 8px rgba(255,255,255,.5);
  overflow:hidden;
}
.river::after {
  content:""; position:absolute; inset:0;
  background: repeating-linear-gradient(80deg, transparent 0 14px, rgba(255,255,255,.35) 14px 18px);
  animation: flow 5s linear infinite;
}
@keyframes flow { to { transform: translateX(-40px); } }

/* 云朵 */
.cloud { position:absolute; font-size: 40px; opacity:.9; filter: drop-shadow(0 3px 4px rgba(0,0,0,.06)); will-change: transform; }
.cloud.c1 { top: 6%; left:-15%; animation: drift 34s linear infinite; }
.cloud.c2 { top: 15%; left:-25%; font-size:30px; animation: drift 46s linear infinite 6s; }
@keyframes drift { from{transform:translateX(0);} to{transform:translateX(150vw);} }

/* 装饰景物 */
.scenery { position:absolute; user-select:none; filter: drop-shadow(0 8px 6px rgba(0,0,0,.18)); }
.scenery.tree   { left: 1%;  top: 20%; font-size: 92px; transform-origin: bottom center; animation: sway 5s ease-in-out infinite; }
.scenery.tree2  { left: 8%;  bottom: 6%; font-size: 54px; transform-origin: bottom center; animation: sway 6s ease-in-out infinite .8s; }
.scenery.bush   { right: 3%; bottom: 30%; font-size: 46px; }
.scenery.flower1{ left: 20%; bottom: 4%; font-size: 26px; animation: sway 4s ease-in-out infinite; }
.scenery.chick  { right: 22%; bottom: 12%; font-size: 32px; animation: hop 2.4s ease-in-out infinite; z-index:5; }
.scenery.sheep  { left: 30%; top: 22%; font-size: 30px; animation: hop 3s ease-in-out infinite .5s; }
@keyframes sway { 0%,100%{transform:rotate(-3deg);} 50%{transform:rotate(3deg);} }
@keyframes hop { 0%,70%,100%{transform:translateY(0);} 80%{transform:translateY(-8px);} 90%{transform:translateY(0);} }
/* 更多花卉 */
.scenery.flower2 { left: 62%; bottom: 16%; font-size: 24px; animation: sway 3.5s ease-in-out infinite .4s; }
.scenery.flower3 { right: 8%; bottom: 8%; font-size: 22px; animation: sway 4s ease-in-out infinite .9s; }
.scenery.bush2 { left: 4%; bottom: 18%; font-size: 30px; }

/* 栅栏 */
.fence-post {
  position:absolute; width:6px; height:20px;
  background:linear-gradient(180deg,#e0c495,#c49a5f);
  border-radius:3px 3px 0 0; z-index:3;
  box-shadow: 0 2px 2px rgba(0,0,0,.15);
}
.fence-rail {
  position:absolute; height:5px; border-radius:3px;
  background:linear-gradient(180deg,#dbb980,#c49a5f); z-index:3;
  box-shadow: 0 2px 2px rgba(0,0,0,.12);
}
/* 石子小路 */
.stone-path {
  position:absolute; right:8%; top:28%; width: 60px; height: 42px;
  background:
    radial-gradient(circle 12px at 10px 10px, #d8cab0 90%, transparent),
    radial-gradient(circle 10px at 32px 24px, #cfc0a2 90%, transparent),
    radial-gradient(circle 14px at 18px 30px, #dccfb8 90%, transparent),
    radial-gradient(circle 8px at 44px 12px, #c8b898 90%, transparent),
    radial-gradient(circle 11px at 42px 34px, #d4c5a8 90%, transparent);
  z-index:2; border-radius: 30% 30% 10% 10%;
  transform: rotate(-8deg);
}
/* 标牌 */
.garden-sign {
  position:absolute; left: 38%; top: 24%; z-index: 4;
  filter: drop-shadow(0 4px 3px rgba(0,0,0,.2));
}
.sign-post {
  width: 5px; height: 34px; background: #b8804a; border-radius: 2px;
  margin: 0 auto;
}
.sign-board {
  width: 40px; height: 28px; background: #f5e6c8; border: 2px solid #c49a5f;
  border-radius: 6px; display:flex; align-items:center; justify-content:center;
  font-size: 16px; margin-bottom: -2px;
}
/* 烟囱烟 */
.chimney-smoke { position:absolute; right: 4%; top: 8%; z-index: 6; }
.smoke-puff {
  display:block; width:12px; height:12px; border-radius:50%;
  background: rgba(220,220,220,.6);
  margin: 0 auto;
  animation: smokeRise 3s ease-out infinite;
}
.smoke-puff.p1 { animation-delay: 0s; }
.smoke-puff.p2 { animation-delay: 1s; }
.smoke-puff.p3 { animation-delay: 2s; }
@keyframes smokeRise {
  0% { opacity:.5; transform: translateY(0) scale(.6); }
  50% { opacity:.35; transform: translateY(-14px) scale(1); }
  100% { opacity:0; transform: translateY(-28px) scale(1.5); }
}
/* 农舍窗户 */
.fh-window {
  position:absolute; top:20px; left:28px; width:16px; height:16px;
  background: #c8e8f8; border: 2px solid #8a561f; border-radius: 2px;
}
.fh-window::after {
  content:""; position:absolute; top:50%; left:0; width:100%; height:2px; background:#8a561f;
  box-shadow: 0 -7px 0 #8a561f;
}

/* 农舍 + 风车 */
.farmhouse { position:absolute; right: 4%; top: 16%; width: 108px; height: 120px; z-index:4; filter: drop-shadow(0 10px 8px rgba(0,0,0,.2)); }
.fh-body { position:absolute; bottom:0; left:14px; width:80px; height:60px; background:linear-gradient(180deg,#f4e2c0,#e6cfa0); border-radius:6px; border:2px solid #c9ab74; }
.fh-roof { position:absolute; top:14px; left:6px; width:96px; height:44px; background:linear-gradient(180deg,#e6857a,#c85b52); clip-path: polygon(50% 0, 100% 100%, 0 100%); border-radius:4px; }
.fh-door { position:absolute; bottom:0; left:44px; width:22px; height:34px; background:#a9713d; border-radius:6px 6px 0 0; }
.windmill { position:absolute; right: 2%; top: 4%; width: 60px; height: 96px; z-index:5; }
.wm-tower { position:absolute; bottom:0; left:50%; transform:translateX(-50%); width:0; height:0; border-left:12px solid transparent; border-right:12px solid transparent; border-bottom:70px solid #d9c199; }
.wm-hub { position:absolute; top:18px; left:50%; transform:translateX(-50%); width:10px; height:10px; background:#8a561f; border-radius:50%; z-index:2; }
.wm-blades { position:absolute; top:23px; left:50%; width:0; height:0; animation: spin 7s linear infinite; will-change: transform; }
.wm-blades i {
  position:absolute; left:-4px; top:-40px; width:8px; height:40px;
  background:linear-gradient(180deg,#fff,#e3d6b6); border:1px solid #c9b485;
  border-radius:4px; transform-origin: 50% 100%;
}
.wm-blades i:nth-child(2){ transform:rotate(90deg); }
.wm-blades i:nth-child(3){ transform:rotate(180deg); }
.wm-blades i:nth-child(4){ transform:rotate(270deg); }
@keyframes spin { to { transform: rotate(360deg); } }

/* ===== 会走路的小猫 ===== */
.farm-cat {
  position:absolute; z-index: 7; cursor:pointer; text-align:center;
  transition: left 2.5s linear, top 2.5s linear;
  pointer-events: auto;
}
.farm-cat .fp-tag {
  font-size: 10px; background: rgba(255,255,255,.92); color:var(--wood-d);
  border-radius: 10px; padding: 1px 7px; font-weight:700; display:inline-block;
  margin-top: 2px; position: relative; z-index: 1;
}
/* 猫精灵 */
.cat-sprite {
  position: relative; width: 52px; height: 48px; margin: 0 auto;
  transform-origin: center bottom;
}
.cat-shadow {
  position:absolute; bottom: 3px; left:50%; transform:translateX(-50%);
  width: 34px; height: 7px; border-radius: 50%;
  background: radial-gradient(rgba(0,0,0,.22), transparent);
}
/* 身体 */
.cat-body-shape {
  position:absolute; bottom: 6px; left: 50%; transform: translateX(-50%);
  width: 30px; height: 18px; border-radius: 50%;
  background: linear-gradient(180deg, #f9b84a, #e8983a);
  box-shadow: inset 0 -3px 3px rgba(0,0,0,.1);
}
.cat-body-shape .cat-pattern {
  position:absolute; top: 2px; left:50%; transform:translateX(-50%);
  width: 20px; height: 5px; border-radius: 3px;
  background: rgba(255,255,255,.22);
}
/* 头+耳朵 */
.cat-head {
  position:absolute; bottom: 19px; left: 50%; transform: translateX(-50%);
  width: 26px; height: 22px; z-index: 2;
}
.cat-ear {
  position:absolute; top: 0; width: 0; height: 0;
  border-left: 5px solid transparent; border-right: 5px solid transparent;
  border-bottom: 10px solid #e8983a;
}
.cat-ear.ear-l { left: 2px; transform: rotate(-12deg); }
.cat-ear.ear-r { right: 2px; transform: rotate(12deg); }
.cat-ear::after {
  content:""; position:absolute; top: 3px; left: -3px;
  width: 0; height: 0;
  border-left: 3px solid transparent; border-right: 3px solid transparent;
  border-bottom: 6px solid #f5c5a0;
}
.cat-face {
  position:absolute; bottom: 0; left: 50%; transform: translateX(-50%);
  width: 22px; height: 18px; border-radius: 50%;
  background: radial-gradient(circle at 35% 30%, #fdd, #f9b84a);
  display: flex; align-items: center; justify-content: center;
  font-size: 12px; line-height: 1;
}
/* 腿 */
.cat-legs { position:absolute; bottom: 2px; left: 50%; transform: translateX(-50%); width: 28px; height: 8px; }
.leg {
  position:absolute; bottom:0; width:5px; height:7px; border-radius:2px;
  background: #e8983a; transform-origin: top center;
}
.leg.fl { left: 3px; } .leg.fr { left: 9px; }
.leg.bl { right: 9px; } .leg.br { right: 3px; }
/* 尾巴 */
.cat-tail {
  position:absolute; bottom: 9px; right: -1px;
  width: 16px; height: 5px; border-radius: 50%;
  background: linear-gradient(90deg, #e8983a, #c87828 70%, #b86820);
  transform-origin: left center;
  animation: tailWag 1.8s ease-in-out infinite;
}
@keyframes tailWag {
  0%,100% { transform: rotate(6deg) translateY(-1px); }
  50%     { transform: rotate(-12deg) translateY(2px); }
}
/* 走路动画 */
.cat-sprite.walking .leg.fl { animation: legFL .45s ease-in-out infinite; }
.cat-sprite.walking .leg.fr { animation: legFR .45s ease-in-out infinite .22s; }
.cat-sprite.walking .leg.bl { animation: legBL .45s ease-in-out infinite .22s; }
.cat-sprite.walking .leg.br { animation: legBR .45s ease-in-out infinite; }
@keyframes legFL { 0%,100%{transform:rotate(0);} 50%{transform:rotate(-24deg);} }
@keyframes legFR { 0%,100%{transform:rotate(-24deg);} 50%{transform:rotate(0);} }
@keyframes legBL { 0%,100%{transform:rotate(0);} 50%{transform:rotate(24deg);} }
@keyframes legBR { 0%,100%{transform:rotate(24deg);} 50%{transform:rotate(0);} }
.cat-sprite.walking { animation: catBob .45s ease-in-out infinite; }
@keyframes catBob { 0%,100%{transform:translateY(0);} 50%{transform:translateY(-3px);} }
/* 面朝左 */
.cat-sprite.face-left { transform: scaleX(-1); }
.cat-sprite.face-left.walking { animation: catBobL .45s ease-in-out infinite; }
@keyframes catBobL { 0%,100%{transform:scaleX(-1) translateY(0);} 50%{transform:scaleX(-1) translateY(-3px);} }
/* 坐着 */
.cat-sprite.sitting .leg { height: 4px; border-radius: 2px 2px 0 0; }

/* 等距田地 */
.iso-wrap {
  position:absolute; left: 50%; top: 56%; transform: translate(-50%,-50%);
  transform-style: preserve-3d; z-index: 3;
}
.iso-field {
  display:grid; grid-template-columns: repeat(3, 76px); grid-auto-rows: 76px; gap: 12px;
  transform: rotateX(55deg) rotateZ(-45deg); transform-style: preserve-3d;
  filter: drop-shadow(0 18px 12px rgba(60,40,20,.25));
}
.garden-plot {
  position: relative; border-radius: 10px; cursor: pointer;
  display:flex; align-items:center; justify-content:center;
  background: linear-gradient(160deg,var(--soil-l),var(--soil));
  border: 2px solid var(--soil-d);
  box-shadow: 0 8px 0 var(--soil-d), 0 12px 14px rgba(0,0,0,.25), inset 0 3px 5px rgba(255,255,255,.12);
  transform-style: preserve-3d; transition: transform .18s, box-shadow .18s, filter .2s;
}
/* 犁沟纹理 */
.garden-plot::before {
  content:""; position:absolute; inset:8px; border-radius:6px;
  background: repeating-linear-gradient(90deg, rgba(0,0,0,.10) 0 3px, transparent 3px 12px);
  pointer-events:none;
}
.garden-plot.empty { filter: brightness(.96); }
.garden-plot.empty::after {
  content:"＋"; position:absolute; inset:0;
  display:flex; align-items:center; justify-content:center;
  color:rgba(255,255,255,.65); font-size:28px; font-weight:300;
  /* 朝向镜头，不跟随地块 3D 倾斜，保证可读 */
  transform: rotateZ(45deg) rotateX(-55deg) translateZ(2px);
  pointer-events:none;
}
.garden-plot.planted { background: linear-gradient(160deg,#7fae52,#5f8a38); border-color:#4c6f2c; box-shadow:0 8px 0 #4c6f2c, 0 12px 14px rgba(0,0,0,.25), inset 0 3px 5px rgba(255,255,255,.15); }
.garden-plot.needs-water { background: linear-gradient(160deg,#a98f5a,#8a6d38); border-color:#6e5527; }
.garden-plot.ready-harvest { background: linear-gradient(160deg,#8fbf5a,#6fa03e); animation: readyGlow 1.8s ease-in-out infinite; }
@keyframes readyGlow {
  0%,100% { box-shadow:0 8px 0 #4c6f2c, 0 12px 14px rgba(0,0,0,.25), 0 0 0 0 rgba(246,196,69,.6); }
  50%     { box-shadow:0 8px 0 #4c6f2c, 0 12px 22px rgba(0,0,0,.3), 0 0 26px 6px rgba(246,196,69,.55); }
}
.garden-plot:active { transform: translateZ(-4px); box-shadow:0 4px 0 var(--soil-d), 0 6px 10px rgba(0,0,0,.25); }

/* 立起来朝向镜头的作物 */
.garden-plot .plant-emoji {
  font-size: 40px; line-height:1;
  transform: rotateZ(45deg) rotateX(-55deg) translateY(-8px);
  transform-origin: center bottom;
  filter: drop-shadow(0 4px 3px rgba(0,0,0,.3));
}
.garden-plot.planted:not(.ready-harvest) .plant-emoji { animation: cropSway 3.4s ease-in-out infinite; will-change: transform; }
.garden-plot.needs-water .plant-emoji { animation-duration: 1.3s; }
.garden-plot.ready-harvest .plant-emoji { animation: cropBob 1.1s ease-in-out infinite; will-change: transform; }
.garden-plot .plant-emoji.grew { animation: growPop .7s cubic-bezier(.34,1.6,.5,1) !important; }
@keyframes cropSway {
  0%,100% { transform: rotateZ(45deg) rotateX(-55deg) translateY(-8px) rotate(-5deg); }
  50%     { transform: rotateZ(45deg) rotateX(-55deg) translateY(-8px) rotate(5deg); }
}
@keyframes cropBob {
  0%,100% { transform: rotateZ(45deg) rotateX(-55deg) translateY(-8px) scale(1); }
  50%     { transform: rotateZ(45deg) rotateX(-55deg) translateY(-16px) scale(1.12); }
}
@keyframes growPop {
  0%   { transform: rotateZ(45deg) rotateX(-55deg) translateY(6px) scale(.3); }
  60%  { transform: rotateZ(45deg) rotateX(-55deg) translateY(-14px) scale(1.35); }
  100% { transform: rotateZ(45deg) rotateX(-55deg) translateY(-8px) scale(1); }
}
/* 地块状态徽标（朝向镜头，不做 3D 倾斜，保证可读） */
.garden-plot .plot-badge {
  position:absolute; top: -8px; left: 50%;
  transform: translate(-50%, -120%);
  background: rgba(74,59,42,.92); color:#fff; font-size:10px; font-weight:700;
  padding: 2px 7px; border-radius: 10px; white-space:nowrap; pointer-events:none;
  z-index: 2;
}
.garden-plot.ready-harvest .plot-badge { background: var(--gold-d); }
.garden-plot.empty .plot-badge { display:none; }
/* 地块特效层（水滴/星光），朝向镜头 */
.plot-fx {
  position:absolute; inset:0; overflow:visible; pointer-events:none; z-index:9;
  transform: rotateZ(45deg) rotateX(-55deg); transform-origin:center bottom;
  display:flex; align-items:center; justify-content:center;
}
.plot-fx .drop { position:absolute; top:-30px; font-size:16px; animation: dropFall .85s ease-in forwards; }
@keyframes dropFall { 0%{opacity:0;transform:translateY(-30px) scale(.7);} 25%{opacity:1;} 100%{opacity:0;transform:translateY(34px) scale(1);} }
.plot-fx .spark { position:absolute; font-size:17px; animation: sparkOut .8s ease-out forwards; }
@keyframes sparkOut { 0%{opacity:0;transform:translate(0,0) scale(.3);} 30%{opacity:1;} 100%{opacity:0;transform:translate(var(--sx,0),var(--sy,0)) scale(1.3);} }

@keyframes petBreathe { 0%,100%{transform:translateY(0) scale(1);} 50%{transform:translateY(-6px) scale(1.04);} }

/* 底部种子托盘 */
.seed-tray {
  background: linear-gradient(180deg,var(--panel),var(--panel-2));
  border: 3px solid #efe2c8; border-radius: var(--radius);
  padding: 12px 14px; box-shadow: var(--shadow);
}
.seed-tray-hint { text-align:center; font-size:12px; color:var(--text-light); margin-bottom:10px; }
.seed-label { text-align:center; font-size:13px; font-weight:700; color:var(--wood-d); margin-bottom:10px; }
.seed-list { display:grid; grid-template-columns: repeat(auto-fill, minmax(80px,1fr)); gap:8px; }
.seed-option {
  background:#fff; border:2px solid #e7ddc7; border-radius: 12px;
  padding: 8px 6px; cursor:pointer; text-align:center; transition: all .15s;
  font-size:12px; color:var(--text);
}
.seed-option .so-emoji { font-size: 26px; display:block; margin-bottom:2px; }
.seed-option .so-name { font-weight:700; }
.seed-option .so-desc { font-size:10px; color:var(--text-light); }
.seed-option:active { transform: scale(.94); }
.seed-option.selected { border-color: var(--grass-d); background:#eef8e2; box-shadow:0 3px 0 var(--grass-d); }

/* ============================================================
   宠物
   ============================================================ */
.pet-display { text-align:center; padding: 12px 0 6px; }
.pet-stage { position:relative; display:inline-block; }
.pet-shadow {
  position:absolute; left:50%; bottom:6px; transform:translateX(-50%);
  width:80px; height:16px; border-radius:50%;
  background: radial-gradient(rgba(0,0,0,.18),transparent); animation: shadowPulse 3.2s ease-in-out infinite;
}
.pet-emoji {
  position:relative; z-index:1; font-size:110px; line-height:1.2; cursor:pointer;
  user-select:none; display:inline-block; transform-origin:center bottom;
  animation: petBreathe 3.2s ease-in-out infinite;
}
.pet-emoji.m-great { animation: petBounce 1.5s ease-in-out infinite; }
.pet-emoji.m-good  { animation: petBreathe 3.2s ease-in-out infinite; }
.pet-emoji.m-ok    { animation: petBreathe 3.8s ease-in-out infinite; }
.pet-emoji.m-bad   { animation: petSad 1.7s ease-in-out infinite; }
.pet-emoji.react   { animation: petWiggle .5s ease-out; }
@keyframes petBounce { 0%,100%{transform:translateY(0) scale(1,1);} 30%{transform:translateY(-20px) scale(1.06,.94);} 50%{transform:translateY(0) scale(1.04,.96);} 70%{transform:translateY(-9px);} }
@keyframes petSad { 0%,100%{transform:translateY(5px) rotate(-2.5deg);} 50%{transform:translateY(7px) rotate(2.5deg);} }
@keyframes petWiggle { 0%{transform:translateY(0) scale(1) rotate(0);} 25%{transform:translateY(-16px) scale(1.16) rotate(-9deg);} 55%{transform:translateY(-4px) scale(1.08) rotate(7deg);} 100%{transform:translateY(0) scale(1) rotate(0);} }
@keyframes shadowPulse { 0%,100%{transform:translateX(-50%) scale(1);opacity:.8;} 50%{transform:translateX(-50%) scale(.82);opacity:.5;} }
.particle { position:absolute; left:50%; top:42%; font-size:26px; pointer-events:none; z-index:2; animation: floatUp 1.2s ease-out forwards; }
@keyframes floatUp { 0%{opacity:0;transform:translate(-50%,0) scale(.4) rotate(0);} 20%{opacity:1;} 100%{opacity:0;transform:translate(calc(-50% + var(--dx,0)),-96px) scale(1.25) rotate(var(--rot,0));} }

.pet-name { font-size:22px; font-weight:800; margin:6px 0 2px; }
.pet-name input { border:none; border-bottom:2px dashed #ddd; font-size:22px; font-weight:800; text-align:center; width:150px; outline:none; background:transparent; color:var(--text); font-family:inherit; }
.pet-name input:focus { border-bottom-color: var(--grass-d); }
.pet-mood { font-size:14px; color:var(--text-light); min-height:22px; }
.pet-level { font-size:12px; color:var(--wood); margin-top:2px; font-weight:600; }

.stats-grid { display:grid; grid-template-columns:1fr 1fr; gap:12px; margin:16px 0; }
.stat-item .stat-header { display:flex; justify-content:space-between; font-size:12px; margin-bottom:4px; }
.stat-item .stat-header span:first-child { color:var(--text-light); font-weight:600; }
.stat-item .stat-header span:last-child { font-weight:700; }
.stat-bar { height:12px; background:#eee3cf; border-radius:8px; overflow:hidden; border:1px solid #e0d3ba; }
.stat-bar-fill { height:100%; border-radius:8px; transition: width .5s, background .4s; }
.fill-hunger{background:linear-gradient(90deg,#f0c85a,#e8b85a);} .fill-happy{background:linear-gradient(90deg,#ef8f80,#e07b6c);}
.fill-energy{background:linear-gradient(90deg,#8fc0dd,#7bb4d4);} .fill-clean{background:linear-gradient(90deg,#82bd63,#6fa84a);}

.pet-actions { display:grid; grid-template-columns:repeat(4,1fr); gap:8px; }
.action-btn {
  padding:12px 4px; border:none; border-radius:14px; cursor:pointer;
  font-size:13px; font-weight:700; transition: transform .12s, box-shadow .12s;
  display:flex; flex-direction:column; align-items:center; gap:3px;
}
.action-btn .btn-emoji { font-size:24px; }
.action-btn.feed { background:#fff0d8; color:#c78a3c; box-shadow:0 4px 0 #e9c489; }
.action-btn.play { background:#ffe0dc; color:#c75b5b; box-shadow:0 4px 0 #eeb0a8; }
.action-btn.rest { background:#dfeefa; color:#5a8aa8; box-shadow:0 4px 0 #a9cfe6; }
.action-btn.wash { background:#e2f3d8; color:#4f8768; box-shadow:0 4px 0 #a9d69a; }
.action-btn:active { transform: translateY(3px); box-shadow:0 1px 0 rgba(0,0,0,.15); }
.action-btn:disabled { opacity:.45; filter:grayscale(30%); box-shadow:none; }
.cooldown-text { text-align:center; font-size:12px; color:var(--text-light); margin-top:12px; min-height:18px; }

/* ===== 留言板 ===== */
.msg-input-area { display:flex; gap:8px; margin-bottom:14px; }
.msg-input-area input { flex:1; padding:12px 14px; border:2px solid #e7ddc7; border-radius:12px; font-size:14px; outline:none; font-family:inherit; transition:border .3s; background:#fffdf7; }
.msg-input-area input:focus { border-color:var(--grass-d); }
.msg-send-btn { padding:12px 18px; border:none; border-radius:12px; background:linear-gradient(180deg,#8fc45f,#6ba13d); color:#fff; font-weight:700; font-size:14px; cursor:pointer; box-shadow:0 4px 0 #588a30; }
.msg-send-btn:active { transform:translateY(3px); box-shadow:0 1px 0 #588a30; }
.msg-list { max-height:420px; overflow-y:auto; display:flex; flex-direction:column; gap:10px; }
.msg-item { padding:11px 14px; border-radius:14px; max-width:85%; }
.msg-item.jy { background:#fff0f4; align-self:flex-start; }
.msg-item.sq { background:#f0f7f2; align-self:flex-end; text-align:right; }
.msg-item .msg-author { font-size:12px; font-weight:700; margin-bottom:4px; }
.msg-item.jy .msg-author { color:var(--jy); } .msg-item.sq .msg-author { color:var(--sq); }
.msg-item .msg-content { font-size:14px; line-height:1.5; word-break:break-word; }
.msg-item .msg-time { font-size:11px; color:var(--text-light); margin-top:4px; }
.msg-empty,.log-empty { text-align:center; color:var(--text-light); padding:32px; font-size:14px; }

/* ===== 日志 ===== */
.log-list { list-style:none; max-height:440px; overflow-y:auto; }
.log-item { display:flex; gap:10px; padding:10px 0; border-bottom:1px solid #f2ece0; font-size:13px; align-items:center; }
.log-item .log-icon { font-size:26px; flex-shrink:0; }
.log-item .log-text { flex:1; line-height:1.4; }
.log-item .log-author { font-weight:700; }
.log-item .log-time { font-size:11px; color:var(--text-light); white-space:nowrap; }

/* ===== 底部导航（木栏） ===== */
.bottom-nav {
  position:fixed; bottom:0; left:50%; transform:translateX(-50%);
  max-width:520px; width:100%; z-index:100;
  display:flex; gap:6px; padding:8px 12px 18px;
  background: linear-gradient(180deg,var(--wood-l),var(--wood));
  border-top:3px solid var(--wood-d);
  box-shadow:0 -4px 16px rgba(90,60,25,.2);
}
.nav-item {
  flex:1; padding:8px 2px; border:none; background:rgba(255,255,255,.15);
  border-radius:14px; cursor:pointer; color:#fff8ec; font-size:11px; font-weight:700;
  transition: all .18s; text-align:center;
}
.nav-item .nav-icon { font-size:23px; display:block; margin-bottom:2px; filter: drop-shadow(0 2px 2px rgba(0,0,0,.2)); }
.nav-item.active { background:#fffaf0; color:var(--wood-d); box-shadow:0 4px 0 var(--wood-d); transform:translateY(-3px); }

/* ===== Toast ===== */
.toast {
  position:fixed; top:20px; left:50%; transform:translateX(-50%) translateY(-12px);
  background:rgba(61,50,44,.95); color:#fff; padding:11px 24px; border-radius:22px;
  font-size:14px; font-weight:600; z-index:2000; opacity:0; transition:all .3s; pointer-events:none;
  box-shadow:0 6px 20px rgba(0,0,0,.25);
}
.toast.show { opacity:1; transform:translateX(-50%) translateY(0); }

@media (max-width: 380px) {
  .pet-emoji { font-size:92px; }
  .iso-field { grid-template-columns: repeat(3, 66px); grid-auto-rows: 66px; gap:10px; }
  .farm-scene { min-height:360px; }
}
@media (prefers-reduced-motion: reduce) {
  .pet-emoji,.pet-shadow,.garden-plot,.garden-plot .plant-emoji,.cloud,.scenery,.wm-blades,.river::after,.cat-tail,.cat-sprite.walking,.cat-sprite.walking .leg { animation:none !important; }
}
</style>
</head>
<body>

<!-- PIN -->
<div class="pin-overlay" id="pinOverlay">
  <div class="pin-box">
    <div class="icon">🌾</div>
    <h2>我的农场</h2>
    <p class="hint">输入你的专属暗号，进入农场</p>
    <input type="password" class="pin-input" id="pinInput" maxlength="6" placeholder="••••" autocomplete="off">
    <button class="pin-btn" onclick="checkPin()">进入农场</button>
    <p class="pin-error" id="pinError"></p>
  </div>
</div>

<div class="toast" id="toast"></div>

<!-- 主体 -->
<div class="app-container" id="app">
  <div class="hud">
    <div class="hud-avatar" id="hudAvatar">👤</div>
    <div class="hud-info">
      <div class="hud-name" id="userBadge">未登录</div>
      <div class="hud-coins">
        <span>🌟 Lv.<b id="hudLevel">1</b></span>
        <span>📅 <b id="hudDays">0</b> 天</span>
      </div>
    </div>
    <div class="hud-logo">🌾 我的农场</div>
  </div>

  <!-- 农场（菜园） -->
  <div class="panel active" id="panelGarden">
    <div class="farm-scene">
      <div class="hill h1"></div><div class="hill h2"></div>
      <div class="cloud c1">☁️</div><div class="cloud c2">☁️</div>
      <div class="river"></div>

      <div class="scenery tree">🌳</div>
      <div class="scenery tree2">🌲</div>
      <div class="scenery bush">🪨</div>
      <div class="scenery bush2">🌾</div>
      <div class="scenery flower1">🌷</div>
      <div class="scenery flower2">🌼</div>
      <div class="scenery flower3">🌸</div>
      <div class="scenery sheep">🐑</div>
      <div class="scenery chick">🐔</div>

      <!-- 栅栏 -->
      <div class="fence-post" style="left:16%;top:32%;"></div>
      <div class="fence-post" style="left:24%;top:30%;"></div>
      <div class="fence-post" style="left:32%;top:29%;"></div>
      <div class="fence-post" style="left:64%;top:29%;"></div>
      <div class="fence-post" style="left:72%;top:30%;"></div>
      <div class="fence-post" style="left:80%;top:32%;"></div>
      <div class="fence-rail" style="left:15%;top:34%;width:22%;"></div>
      <div class="fence-rail" style="left:60%;top:34%;width:22%;"></div>

      <!-- 石子小路 -->
      <div class="stone-path"></div>

      <!-- 标牌 -->
      <div class="garden-sign">
        <div class="sign-post"></div>
        <div class="sign-board">🌱</div>
      </div>

      <div class="windmill"><div class="wm-tower"></div><div class="wm-hub"></div><div class="wm-blades"><i></i><i></i><i></i><i></i></div></div>
      <div class="farmhouse"><div class="fh-roof"></div><div class="fh-body"></div><div class="fh-door"></div><div class="fh-window"></div></div>
      <div class="chimney-smoke">
        <span class="smoke-puff p1"></span><span class="smoke-puff p2"></span><span class="smoke-puff p3"></span>
      </div>

      <!-- 会走路的小猫 -->
      <div class="farm-cat" id="farmCat" onclick="switchTab('pet')">
        <div class="cat-sprite" id="catSprite">
          <div class="cat-shadow" id="catShadow"></div>
          <div class="cat-body-shape">
            <div class="cat-pattern"></div>
          </div>
          <div class="cat-head">
            <div class="cat-ear ear-l"></div>
            <div class="cat-ear ear-r"></div>
            <div class="cat-face" id="catFace">😸</div>
          </div>
          <div class="cat-legs">
            <span class="leg fl"></span><span class="leg fr"></span>
            <span class="leg bl"></span><span class="leg br"></span>
          </div>
          <div class="cat-tail">
            <span class="tail-tip"></span>
          </div>
        </div>
        <span class="fp-tag" id="farmPetTag">小可爱</span>
      </div>

      <div class="iso-wrap"><div class="iso-field" id="gardenGrid"></div></div>
    </div>

    <div class="seed-tray">
      <div class="seed-tray-hint">🌱 选种子 → 点空地播种 → 浇水照料 → 成熟收获</div>
      <div class="seed-label" id="seedLabel">👆 请先选择种子</div>
      <div class="seed-list" id="seedList"></div>
    </div>
  </div>

  <!-- 宠物 -->
  <div class="panel" id="panelPet">
    <div class="card">
      <div class="pet-display">
        <div class="pet-stage" id="petStage">
          <div class="pet-shadow"></div>
          <div class="pet-emoji" id="petEmoji" onclick="clickPet()">🐱</div>
        </div>
        <div class="pet-name"><input id="petNameInput" value="小可爱" maxlength="8" onchange="renamePet(this.value)"></div>
        <div class="pet-mood" id="petMood">心情不错~</div>
        <div class="pet-level" id="petLevel">Lv.1 · 累计照料 0 天</div>
      </div>
      <div class="stats-grid">
        <div class="stat-item">
          <div class="stat-header"><span>🍖 饱腹</span><span id="hungerVal">100</span></div>
          <div class="stat-bar"><div class="stat-bar-fill fill-hunger" id="hungerBar" style="width:100%"></div></div>
        </div>
        <div class="stat-item">
          <div class="stat-header"><span>😊 开心</span><span id="happyVal">100</span></div>
          <div class="stat-bar"><div class="stat-bar-fill fill-happy" id="happyBar" style="width:100%"></div></div>
        </div>
        <div class="stat-item">
          <div class="stat-header"><span>⚡ 精力</span><span id="energyVal">100</span></div>
          <div class="stat-bar"><div class="stat-bar-fill fill-energy" id="energyBar" style="width:100%"></div></div>
        </div>
        <div class="stat-item">
          <div class="stat-header"><span>🛁 清洁</span><span id="cleanVal">100</span></div>
          <div class="stat-bar"><div class="stat-bar-fill fill-clean" id="cleanBar" style="width:100%"></div></div>
        </div>
      </div>
      <div class="pet-actions">
        <button class="action-btn feed" id="btnFeed" onclick="feedPet()"><span class="btn-emoji">🍖</span>喂食</button>
        <button class="action-btn play" id="btnPlay" onclick="playPet()"><span class="btn-emoji">🎾</span>玩耍</button>
        <button class="action-btn rest" id="btnRest" onclick="restPet()"><span class="btn-emoji">😴</span>睡觉</button>
        <button class="action-btn wash" id="btnWash" onclick="washPet()"><span class="btn-emoji">🛁</span>洗澡</button>
      </div>
      <div class="cooldown-text" id="cooldownText"></div>
    </div>
  </div>

  <!-- 留言板 -->
  <div class="panel" id="panelMsg">
    <div class="card">
      <div class="card-title">💬 留言板</div>
      <div class="msg-input-area">
        <input type="text" id="msgInput" placeholder="想说点什么…" maxlength="300" onkeydown="if(event.key==='Enter')sendMsg()">
        <button class="msg-send-btn" onclick="sendMsg()">发送</button>
      </div>
      <div class="msg-list" id="msgList"><div class="msg-empty">还没有留言~<br>说点什么吧 💬</div></div>
    </div>
  </div>

  <!-- 日志 -->
  <div class="panel" id="panelLog">
    <div class="card">
      <div class="card-title">📋 农场记录</div>
      <ul class="log-list" id="logList"><li class="log-empty">还没有记录~<br>快去照顾宠物或种菜吧 🌱</li></ul>
    </div>
  </div>
</div>

<!-- 底部导航 -->
<nav class="bottom-nav" id="bottomNav">
  <button class="nav-item active" onclick="switchTab('garden')"><span class="nav-icon">🌱</span>农场</button>
  <button class="nav-item" onclick="switchTab('pet')"><span class="nav-icon">🐱</span>宠物</button>
  <button class="nav-item" onclick="switchTab('msg')"><span class="nav-icon">💬</span>留言</button>
  <button class="nav-item" onclick="switchTab('log')"><span class="nav-icon">📋</span>记录</button>
</nav>

<script>
// ==================== 配置 ====================
const SUPABASE_URL = 'https://ddoqigftcyvlpswowocs.supabase.co';
const SUPABASE_KEY = 'sb_publishable_tDUVrR31skXEveQN0khzQA_RgIpvFQr';

const USERS = {
  '0430': { name:'姜宇静', emoji:'🌸', cls:'jy', color:'#E892B0' },
  '0823': { name:'施志强', emoji:'🌲', cls:'sq', color:'#6B9B77' }
};

// ==================== 种子库 ====================
const SEED_LIBRARY = {
  sunflower:  { name:'向日葵', emoji:'🌻', growTime:3, harvestEmoji:'🌻', desc:'3天成熟' },
  rose:       { name:'玫瑰',   emoji:'🌹', growTime:4, harvestEmoji:'🌹', desc:'4天成熟' },
  strawberry: { name:'草莓',   emoji:'🍓', growTime:3, harvestEmoji:'🍓', desc:'3天成熟' },
  tomato:     { name:'番茄',   emoji:'🍅', growTime:3, harvestEmoji:'🍅', desc:'3天成熟' },
  carrot:     { name:'胡萝卜', emoji:'🥕', growTime:4, harvestEmoji:'🥕', desc:'4天成熟' },
  cabbage:    { name:'白菜',   emoji:'🥬', growTime:3, harvestEmoji:'🥬', desc:'3天成熟' },
  pepper:     { name:'辣椒',   emoji:'🌶️', growTime:4, harvestEmoji:'🌶️', desc:'4天成熟' },
  corn:       { name:'玉米',   emoji:'🌽', growTime:4, harvestEmoji:'🌽', desc:'4天成熟' },
  cactus:     { name:'仙人掌', emoji:'🌵', growTime:5, harvestEmoji:'🌵', desc:'5天成熟' },
};
const STAGE_EMOJIS = ['🟫','🌰','🌱','🌿'];

// ==================== 全局状态 ====================
let supabase = null, isOnline = false, currentUser = null, selectedSeed = null;
let pet = { hunger:100, happy:100, energy:100, clean:100, lastFed:0, lastPlayed:0, lastRested:0, lastWashed:0, name:'小可爱', careDays:0, level:1 };
let garden = Array(9).fill(null).map((_,i)=>({ idx:i, seed:null, plantedAt:null, wateredAt:null, stage:0, waterCount:0 }));
let logs = [], messages = [];
let cooldowns = { feed:0, play:0, rest:0, wash:0 };

// ==================== 动态加载 ====================
function loadScript(src) {
  return new Promise((resolve, reject) => {
    if (document.querySelector(`script[src="${src}"]`)) return resolve();
    const s = document.createElement('script');
    s.src = src; s.onload = resolve; s.onerror = () => reject(new Error('load fail'));
    document.head.appendChild(s);
  });
}

// ==================== 初始化 ====================
async function init() {
  try {
    await loadScript('https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.min.js');
    supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_KEY);
    const { data } = await supabase.from('pet').select('*').single();
    if (data) { isOnline = true; console.log('✅ 云端同步'); }
  } catch(e) { console.log('📦 本地模式'); }

  if (isOnline) { await loadCloud(); setupRealtime(); }
  else { loadLocal(); }

  applyDecay();
  renderAll();
  startTimers();
  document.getElementById('pinInput').focus();
}

// ==================== PIN + 用户 ====================
function checkPin() {
  const input = document.getElementById('pinInput').value.trim();
  const user = USERS[input];
  if (user) {
    currentUser = user;
    document.getElementById('pinOverlay').classList.add('hidden');
    document.getElementById('pinError').textContent = '';
    updateUserUI();
    toast(`欢迎回到农场，${user.name} ${user.emoji}`);
  } else {
    document.getElementById('pinError').textContent = '暗号不对，再试试~';
    document.getElementById('pinInput').value = '';
    document.getElementById('pinInput').focus();
  }
}
document.getElementById('pinInput').addEventListener('keydown', e => { if(e.key==='Enter') checkPin(); });

function updateUserUI() {
  if (!currentUser) return;
  document.getElementById('hudAvatar').textContent = currentUser.emoji;
  document.getElementById('userBadge').textContent = currentUser.name;
}

// ==================== 云端数据 ====================
async function loadCloud() {
  try {
    const [pr, gr, lr, mr] = await Promise.all([
      supabase.from('pet').select('*').single(),
      supabase.from('garden').select('*').order('plot_index'),
      supabase.from('activities').select('*').order('created_at',{ascending:false}).limit(60),
      supabase.from('messages').select('*').order('created_at',{ascending:true}).limit(100)
    ]);
    if (pr.data) pet = { ...pet, ...pr.data,
      lastFed: ts(pr.data.last_fed), lastPlayed: ts(pr.data.last_played),
      lastRested: ts(pr.data.last_rested), lastWashed: ts(pr.data.last_washed) };
    if (gr.data?.length) {
      // 确保始终有 9 块地，防止云端数据条数异常
      const cloudPlots = gr.data.map(r=>({ idx:r.plot_index, seed:r.plant_type, plantedAt:ts(r.planted_at), wateredAt:ts(r.watered_at), stage:r.stage||0, waterCount:r.water_count||0 }));
      garden = Array(9).fill(null).map((_,i) => cloudPlots.find(p => p.idx === i) || { idx:i, seed:null, plantedAt:null, wateredAt:null, stage:0, waterCount:0 });
    }
    if (lr.data) logs = lr.data.map(r=>({ icon:r.icon, text:r.action, author:r.user_name, ts:ts(r.created_at) }));
    if (mr.data) messages = mr.data.map(r=>({ id:r.id, author:r.author, content:r.content, ts:ts(r.created_at) }));
    applyDecay();
  } catch(e) { console.error(e); loadLocal(); }
}

async function savePet() {
  if (!isOnline) { saveLocal(); return; }
  await supabase.from('pet').upsert({
    id:1, hunger:pet.hunger, happiness:pet.happy, energy:pet.energy, cleanliness:pet.clean,
    last_fed:iso(pet.lastFed), last_played:iso(pet.lastPlayed), last_rested:iso(pet.lastRested), last_washed:iso(pet.lastWashed),
    name:pet.name, care_days:pet.careDays, level:pet.level
  });
}
async function saveGarden() {
  if (!isOnline) { saveLocal(); return; }
  await supabase.from('garden').upsert(garden.map(p=>({
    plot_index:p.idx, plant_type:p.seed, planted_at:iso(p.plantedAt), watered_at:iso(p.wateredAt),
    stage:p.stage, water_count:p.waterCount
  })));
}
async function saveLog(icon, text) {
  logs.unshift({ icon, text, author: currentUser?.name, ts: Date.now() });
  if (logs.length > 60) logs.length = 60;
  if (isOnline) await supabase.from('activities').insert({ icon, action:text, user_name:currentUser?.name });
  saveLocal(); renderLog();
}
async function saveMsg(content) {
  const msg = { id: Date.now(), author: currentUser.name, content, ts: Date.now() };
  messages.push(msg);
  if (isOnline) await supabase.from('messages').insert({ author:currentUser.name, content });
  saveLocal(); renderMessages();
}

function setupRealtime() {
  ['pet','garden','activities','messages'].forEach(tbl => {
    supabase.channel(tbl).on('postgres_changes',{event:'*',schema:'public',table:tbl},async()=>{
      await loadCloud(); renderAll();
    }).subscribe();
  });
}

// ==================== 本地 ====================
function loadLocal() {
  try {
    const s = JSON.parse(localStorage.getItem('gardenApp')||'{}');
    if (s.pet) pet = { ...pet, ...s.pet };
    if (s.garden) garden = s.garden;
    if (s.logs) logs = s.logs;
    if (s.messages) messages = s.messages;
    applyDecay();
  } catch(e) {}
}
function saveLocal() { localStorage.setItem('gardenApp', JSON.stringify({ pet, garden, logs, messages })); }

// ==================== 衰减 ====================
function applyDecay() {
  const now = Date.now();
  pet.hunger = Math.max(0, Math.min(100, pet.hunger - Math.floor((now - pet.lastFed)/(8*60*1000))));
  pet.happy  = Math.max(0, Math.min(100, pet.happy  - Math.floor((now - pet.lastPlayed)/(12*60*1000))));
  pet.energy = Math.max(0, Math.min(100, pet.energy - Math.floor((now - pet.lastRested)/(6*60*1000))));
  pet.clean  = Math.max(0, Math.min(100, pet.clean  - Math.floor((now - pet.lastWashed)/(16*60*1000))));
}

// ==================== 宠物操作 ====================
function feedPet() {
  if (cooldowns.feed > 0) return;
  if (pet.hunger >= 100) { toast('已经吃饱了~'); return; }
  pet.hunger = Math.min(100, pet.hunger + 35);
  pet.lastFed = Date.now();
  pet.energy = Math.min(100, pet.energy + 5);
  recordCare(); cooldowns.feed = 20;
  savePet(); saveLog('🍖', `${currentUser.name} 喂了宠物`);
  renderPet(); petReact(); spawnParticles('🍖', 5); toast('🍖 饱腹 +35');
}
function playPet() {
  if (cooldowns.play > 0) return;
  if (pet.energy < 10) { toast('太累了，先休息吧~'); return; }
  pet.happy = Math.min(100, pet.happy + 30);
  pet.lastPlayed = Date.now();
  pet.energy = Math.max(0, pet.energy - 10);
  pet.clean = Math.max(0, pet.clean - 5);
  pet.hunger = Math.max(0, pet.hunger - 8);
  recordCare(); cooldowns.play = 30;
  savePet(); saveLog('🎾', `${currentUser.name} 陪宠物玩耍`);
  renderPet(); petReact(); spawnParticles('🎾', 4); spawnParticles('💕', 3); toast('🎾 开心 +30');
}
function restPet() {
  if (cooldowns.rest > 0) return;
  if (pet.energy >= 100) { toast('精力充沛，不想睡~'); return; }
  pet.energy = Math.min(100, pet.energy + 50);
  pet.lastRested = Date.now();
  pet.hunger = Math.max(0, pet.hunger - 12);
  recordCare(); cooldowns.rest = 60;
  savePet(); saveLog('😴', `${currentUser.name} 让宠物睡了觉`);
  renderPet(); spawnParticles('💤', 4); toast('😴 精力 +50');
}
function washPet() {
  if (cooldowns.wash > 0) return;
  if (pet.clean >= 100) { toast('已经很干净了~'); return; }
  pet.clean = Math.min(100, pet.clean + 45);
  pet.lastWashed = Date.now();
  pet.happy = Math.min(100, pet.happy + 5);
  recordCare(); cooldowns.wash = 45;
  savePet(); saveLog('🛁', `${currentUser.name} 给宠物洗了澡`);
  renderPet(); petReact(); spawnParticles('🫧', 6); toast('🛁 清洁 +45');
}
function recordCare() {
  const now = new Date();
  const today = `${now.getFullYear()}-${now.getMonth()+1}-${now.getDate()}`;
  if (pet._lastCareDate !== today) { pet._lastCareDate = today; pet.careDays = (pet.careDays||0) + 1; pet.level = Math.floor(pet.careDays/3) + 1; }
}
function clickPet() {
  petReact();
  spawnParticles(['❤️','✨','💕','🌟'][Math.floor(Math.random()*4)], 5);
  toast(['喵呜~','嗷~','咕噜咕噜~','蹭了蹭你','汪！','叽叽~','✨'][Math.floor(Math.random()*7)]);
}
// 触发一次性反应动画，播完自动回到心情待机动画
function petReact() {
  const el = document.getElementById('petEmoji');
  el.classList.remove('react'); void el.offsetWidth; el.classList.add('react');
  el.addEventListener('animationend', () => el.classList.remove('react'), { once:true });
}
// 从宠物身上向上飘散表情粒子
function spawnParticles(emoji, count = 6) {
  const stage = document.getElementById('petStage');
  if (!stage) return;
  for (let i = 0; i < count; i++) {
    const p = document.createElement('span');
    p.className = 'particle';
    p.textContent = emoji;
    p.style.setProperty('--dx', (Math.random()*120 - 60) + 'px');
    p.style.setProperty('--rot', (Math.random()*80 - 40) + 'deg');
    p.style.left = (42 + Math.random()*16) + '%';
    p.style.animationDelay = (Math.random()*0.18) + 's';
    stage.appendChild(p);
    setTimeout(() => p.remove(), 1500);
  }
}
function renamePet(name) { pet.name = name || '小可爱'; savePet(); saveLog('✏️', `${currentUser.name} 给宠物改名：${pet.name}`); renderPet(); }

// ==================== 农场 ====================
function selectSeed(key) { selectedSeed = key; document.getElementById('seedLabel').textContent = '✅ 已选：'+SEED_LIBRARY[key].name+' — 点击空地播种'; renderSeedList(); }
function clickPlot(idx) {
  const plot = garden[idx];
  if (!plot.seed) {
    if (!selectedSeed) { toast('👆 请先在下方选择种子'); return; }
    plot.seed = selectedSeed; plot.plantedAt = Date.now(); plot.wateredAt = Date.now(); plot.stage = 1; plot.waterCount = 1;
    const name = SEED_LIBRARY[selectedSeed].name; selectedSeed = null;
    document.getElementById('seedLabel').textContent = '👆 请先选择种子';
    saveGarden(); saveLog('🌰', `${currentUser.name} 在${idx+1}号地种下${name}`);
    renderAll(); popPlot(idx); toast(`种下${name}！🌰`);
  } else if (plot.stage >= SEED_LIBRARY[plot.seed].growTime) {
    const name = SEED_LIBRARY[plot.seed].name;
    saveLog('🧺', `${currentUser.name} 收获了${idx+1}号地的${name}`);
    plot.seed = null; plot.plantedAt = null; plot.wateredAt = null; plot.stage = 0; plot.waterCount = 0;
    saveGarden(); renderAll(); spawnPlotFx(idx, 'spark'); toast(`收获成功！🧺 ${name}`);
  } else {
    const hoursSinceWater = (Date.now() - plot.wateredAt) / 3600000;
    if (hoursSinceWater < 1) { toast('刚浇过水，过会儿再来~'); return; }
    const prevStage = plot.stage;
    plot.wateredAt = Date.now(); plot.waterCount++;
    if (plot.waterCount >= plot.stage + 1 && plot.stage < SEED_LIBRARY[plot.seed].growTime) plot.stage++;
    saveGarden(); saveLog('💧', `${currentUser.name} 给${idx+1}号地${SEED_LIBRARY[plot.seed].name}浇水`);
    renderAll(); spawnPlotFx(idx, 'drop');
    if (plot.stage > prevStage) popPlot(idx);
    toast('💧 浇水成功！');
  }
}
function getPlotDisplay(plot) {
  if (!plot.seed) return { emoji:'', cls:'empty', label:'空地' };
  const seed = SEED_LIBRARY[plot.seed];
  if (plot.stage >= seed.growTime) return { emoji:seed.harvestEmoji, cls:'planted ready-harvest', label:'可收获' };
  const h = (Date.now() - plot.wateredAt) / 3600000;
  return { emoji: STAGE_EMOJIS[Math.min(plot.stage,3)]||'🌿', cls: h>8?'planted needs-water':'planted', label:`第${plot.stage}天` };
}
// 找到指定地块 DOM（renderAll 后调用）
function plotEl(idx) { return document.getElementById('gardenGrid').children[idx]; }
// 破土/长大的一次性弹出动画
function popPlot(idx) {
  const el = plotEl(idx); if (!el) return;
  const sprout = el.querySelector('.plant-emoji'); if (!sprout) return;
  sprout.classList.remove('grew'); void sprout.offsetWidth; sprout.classList.add('grew');
  sprout.addEventListener('animationend', () => sprout.classList.remove('grew'), { once:true });
}
// 地块特效：浇水水滴 / 收获星光
function spawnPlotFx(idx, type) {
  const el = plotEl(idx); if (!el) return;
  const fx = document.createElement('div'); fx.className = 'plot-fx';
  if (type === 'drop') {
    for (let i = 0; i < 5; i++) {
      const d = document.createElement('span'); d.className = 'drop'; d.textContent = '💧';
      d.style.left = (18 + Math.random()*60) + '%';
      d.style.animationDelay = (Math.random()*0.25) + 's';
      fx.appendChild(d);
    }
  } else {
    for (let i = 0; i < 8; i++) {
      const s = document.createElement('span'); s.className = 'spark'; s.textContent = i % 2 ? '✨' : '⭐';
      const ang = Math.random()*Math.PI*2, dist = 26 + Math.random()*18;
      s.style.setProperty('--sx', Math.cos(ang)*dist + 'px');
      s.style.setProperty('--sy', Math.sin(ang)*dist + 'px');
      s.style.animationDelay = (Math.random()*0.15) + 's';
      fx.appendChild(s);
    }
  }
  el.appendChild(fx);
  setTimeout(() => fx.remove(), 1000);
}

// ==================== 留言板 ====================
function sendMsg() {
  const input = document.getElementById('msgInput');
  const content = input.value.trim();
  if (!content) return;
  if (!currentUser) { toast('请先输入暗号进入'); return; }
  saveMsg(content);
  input.value = '';
  renderMessages();
  toast('留言发送成功 💬');
}
function renderMessages() {
  const list = document.getElementById('msgList');
  if (!messages.length) { list.innerHTML = '<div class="msg-empty">还没有留言~<br>说点什么吧 💬</div>'; return; }
  list.innerHTML = messages.map(m => {
    const user = Object.values(USERS).find(u => u.name === m.author) || { cls:'jy', color:'#999' };
    return `<div class="msg-item ${user.cls}">
      <div class="msg-author">${m.author}</div>
      <div class="msg-content">${escHtml(m.content)}</div>
      <div class="msg-time">${fmtTime(m.ts)}</div>
    </div>`;
  }).join('');
  list.scrollTop = list.scrollHeight;
}

// ==================== 渲染 ====================
function renderAll() { renderPet(); renderGarden(); renderMessages(); renderLog(); renderSeedList(); }
function renderPet() {
  const total = pet.hunger + pet.happy + pet.energy + pet.clean;
  let emoji, mood;
  if (total >= 340) { emoji='😸'; mood='状态极佳！容光焕发~'; }
  else if (total >= 260) { emoji='🐱'; mood='还不错，挺舒服的~'; }
  else if (total >= 160) { emoji='😐'; mood='有点不舒服…需要照顾一下'; }
  else if (pet.hunger < 25) { emoji='😿'; mood='好饿…快给我吃的！'; }
  else if (pet.clean < 25) { emoji='😾'; mood='脏兮兮的…想洗澡！'; }
  else if (pet.energy < 20) { emoji='😴'; mood='困得睁不开眼了…'; }
  else if (pet.happy < 25) { emoji='😞'; mood='好无聊…陪我玩会儿吧'; }
  else { emoji='🐱'; mood='还可以~'; }
  const petEl = document.getElementById('petEmoji');
  petEl.textContent = emoji;
  const moodClass = total >= 340 ? 'm-great'
    : total >= 260 ? 'm-good'
    : (pet.hunger < 25 || pet.happy < 25 || pet.energy < 20 || pet.clean < 25) ? 'm-bad'
    : 'm-ok';
  if (!petEl.classList.contains(moodClass)) {
    petEl.classList.remove('m-great','m-good','m-ok','m-bad');
    petEl.classList.add(moodClass);
  }
  document.getElementById('petNameInput').value = pet.name;
  document.getElementById('petMood').textContent = mood;
  document.getElementById('petLevel').textContent = `Lv.${pet.level||1} · 累计照料 ${pet.careDays||0} 天`;
  // 农场里的宠物 + HUD
  document.getElementById('catFace').textContent = emoji;
  document.getElementById('farmPetTag').textContent = pet.name;
  document.getElementById('hudLevel').textContent = pet.level||1;
  document.getElementById('hudDays').textContent = pet.careDays||0;
  ['hunger','happy','energy','clean'].forEach((k,i) => {
    const val = pet[k==='happy'?'happy':k];
    const ids = ['hungerVal','happyVal','energyVal','cleanVal'];
    const bars = ['hungerBar','happyBar','energyBar','cleanBar'];
    document.getElementById(ids[i]).textContent = val;
    document.getElementById(bars[i]).style.width = val+'%';
    document.getElementById(bars[i]).style.background = val < 25 ? '#D08070' : '';
  });
}
function renderGarden() {
  document.getElementById('gardenGrid').innerHTML = garden.map((p,i) => {
    const d = getPlotDisplay(p);
    return `<div class="garden-plot ${d.cls}" onclick="clickPlot(${i})">
      <span class="plant-emoji">${d.emoji}</span>
      <span class="plot-badge">${d.label}</span>
    </div>`;
  }).join('');
}
function renderLog() {
  const list = document.getElementById('logList');
  if (!logs.length) { list.innerHTML = '<li class="log-empty">还没有记录~<br>快去照顾宠物或种菜吧 🌱</li>'; return; }
  list.innerHTML = logs.map(l => `
    <li class="log-item">
      <span class="log-icon">${l.icon}</span>
      <span class="log-text"><span class="log-author">${l.author||''}</span> ${l.text.replace(l.author+' ','')}</span>
      <span class="log-time">${fmtTime(l.ts)}</span>
    </li>`).join('');
}
function renderSeedList() {
  document.getElementById('seedList').innerHTML = Object.entries(SEED_LIBRARY).map(([k,v])=>
    `<button class="seed-option${selectedSeed===k?' selected':''}" onclick="selectSeed('${k}')" title="${v.desc}">
      <span class="so-emoji">${v.harvestEmoji}</span>
      <span class="so-name">${v.name}</span>
      <span class="so-desc">${v.desc}</span>
    </button>`
  ).join('');
}

function switchTab(t) {
  document.querySelectorAll('.panel').forEach(p=>p.classList.remove('active'));
  document.querySelectorAll('.bottom-nav .nav-item').forEach(b=>b.classList.remove('active'));
  const map = { pet:'panelPet', garden:'panelGarden', msg:'panelMsg', log:'panelLog' };
  document.getElementById(map[t]).classList.add('active');
  const labels = { pet:'宠物', garden:'农场', msg:'留言', log:'记录' };
  document.querySelectorAll('.bottom-nav .nav-item').forEach(b=>{
    if (b.textContent.includes(labels[t])) b.classList.add('active');
  });
  if (t === 'garden') renderSeedList();
  if (t === 'msg') { renderMessages(); document.getElementById('msgInput').focus(); }
}

// ==================== 小猫自动走路 ====================
let catPos = { x: 45, y: 87 };   // 初始位置（百分比，底部草地）
let catTarget = null;
let catWalking = false;

function initCat() {
  const cat = document.getElementById('farmCat');
  if (!cat) return;
  cat.style.left = catPos.x + '%';
  cat.style.top = catPos.y + '%';
  cat.style.transform = 'translate(-50%, -50%)';
  pickCatTarget();
  setInterval(pickCatTarget, 4000 + Math.random() * 3000);
  requestAnimationFrame(catStep);
}

function pickCatTarget() {
  // 猫在农场周边走动，避开田地中央（30-75% x, 30-68% y）
  const zones = [
    { x: [8, 25],  y: [60, 86] },   // 左下草地
    { x: [70, 90], y: [58, 84] },   // 右下
    { x: [8, 45],  y: [78, 92] },   // 底部草地
    { x: [55, 90], y: [76, 92] },   // 底部右侧
    { x: [6, 30],  y: [35, 58] },   // 左侧中段
    { x: [72, 92], y: [32, 55] },   // 右侧中段
  ];
  const zone = zones[Math.floor(Math.random() * zones.length)];
  catTarget = {
    x: zone.x[0] + Math.random() * (zone.x[1] - zone.x[0]),
    y: zone.y[0] + Math.random() * (zone.y[1] - zone.y[0]),
  };
}

function catStep() {
  const cat = document.getElementById('farmCat');
  const sprite = document.getElementById('catSprite');
  if (!cat || !sprite || !catTarget) {
    requestAnimationFrame(catStep);
    return;
  }

  const dx = catTarget.x - catPos.x;
  const dy = catTarget.y - catPos.y;
  const dist = Math.sqrt(dx * dx + dy * dy);

  if (dist < 1.5) {
    // 到达目标，休息
    if (catWalking) {
      catWalking = false;
      sprite.classList.remove('walking');
      sprite.classList.add('sitting');
    }
    requestAnimationFrame(catStep);
    return;
  }

  // 走路中
  if (!catWalking) {
    catWalking = true;
    sprite.classList.remove('sitting');
    sprite.classList.add('walking');
  }

  // 朝向
  if (dx < -0.5) sprite.classList.add('face-left');
  else if (dx > 0.5) sprite.classList.remove('face-left');

  // 移动
  const speed = 0.35;
  catPos.x += (dx / dist) * speed;
  catPos.y += (dy / dist) * speed;
  cat.style.left = catPos.x + '%';
  cat.style.top = catPos.y + '%';

  requestAnimationFrame(catStep);
}

// ==================== 计时器 ====================
function startTimers() {
  initCat();
  setInterval(() => { applyDecay(); renderPet(); saveLocal(); }, 60000);
  setInterval(() => {
    let changed = false;
    for (const k of ['feed','play','rest','wash']) { if (cooldowns[k] > 0) { cooldowns[k]--; changed=true; } }
    if (changed) {
      const parts = [];
      if (cooldowns.feed>0) parts.push(`喂食 ${cooldowns.feed}s`);
      if (cooldowns.play>0) parts.push(`玩耍 ${cooldowns.play}s`);
      if (cooldowns.rest>0) parts.push(`睡觉 ${cooldowns.rest}s`);
      if (cooldowns.wash>0) parts.push(`洗澡 ${cooldowns.wash}s`);
      document.getElementById('cooldownText').textContent = parts.length ? '⏳ '+parts.join(' · ') : '';
    }
  }, 1000);
}

// ==================== 工具 ====================
function toast(msg) { const t=document.getElementById('toast'); t.textContent=msg; t.classList.add('show'); clearTimeout(t._tid); t._tid=setTimeout(()=>t.classList.remove('show'),2000); }
function ts(v) { return v ? new Date(v).getTime() : 0; }
function iso(v) { return v ? new Date(v).toISOString() : null; }
function fmtTime(ts) {
  const diff = Date.now() - ts;
  if (diff < 60000) return '刚刚';
  if (diff < 3600000) return Math.floor(diff/60000)+'分钟前';
  if (diff < 86400000) return Math.floor(diff/3600000)+'小时前';
  const d = new Date(ts);
  return `${d.getMonth()+1}/${d.getDate()} ${String(d.getHours()).padStart(2,'0')}:${String(d.getMinutes()).padStart(2,'0')}`;
}
function escHtml(s) { const d=document.createElement('div'); d.textContent=s; return d.innerHTML; }

init();
</script>
</body>
</html>
