!function(){"use strict"}(),function(){(function(){Crafty.c("Bullet",{init:function(){return this.requires("2D, Canvas, Color, Collision")},fire:function(a){return this.attr({damage:a.damage}),this.bind("EnterFrame",function(){var b;return this.x=this.x+a.speed,b=-Crafty.viewport._x+Crafty.viewport._width/Crafty.viewport._scale,this.x>b+200?this.destroy():void 0}),this.onHit("Edge",function(){return this.destroy()}),this}})}).call(this),function(){}.call(this),function(){Crafty.c("Enemy",{init:function(){return this.requires("2D, Canvas, Color, Collision")},enemy:function(){return this.attr({w:50,h:50,health:300}),this.color("#0000FF"),this.bind("EnterFrame",function(){var a;return this.x=this.x-1,a=-Crafty.viewport._x,this.x<a?this.destroy():void 0}),this.onHit("Bullet",function(a){var b;return b=a[0].obj,b.trigger("HitTarget",{target:this}),this.health-=b.damage,this.health<=0&&(b.trigger("DestroyTarget",{target:this}),this.destroy()),b.destroy()}),this}})}.call(this),function(){Crafty.c("GamepadControls",{init:function(){return this.requires("Listener"),this.bind("RemoveComponent",function(a){return"ControlScheme"===a?this.removeComponent("GamepadControls"):void 0})},remove:function(){return this.unbind("GamepadKeyChange",this._keyHandling)},setupControls:function(a){return a.addComponent("GamepadControls").controls(this.controlMap).addComponent("ControlScheme")},controls:function(a){return this.controlMap=a,null!=a.gamepadIndex?(this.requires("Gamepad"),this.gamepad(a.gamepadIndex),this.bind("GamepadKeyChange",this._keyHandling),this):void 0},_keyHandling:function(a){return a.button===this.controlMap.fire&&a.pressed?this.trigger("Fire",a):void 0},assignControls:function(a){return a.addComponent("GamepadMultiway, Gamepad").gamepad(this.controlMap.gamepadIndex).gamepadMultiway({speed:{y:3,x:1.5},gamepadIndex:this.controlMap.gamepadIndex}),this.listenTo(a,"GamepadKeyChange",function(b){return function(c){return c.button===b.controlMap.fire&&c.pressed?a.shoot():void 0}}(this))}})}.call(this),function(){Crafty.c("HUD",{init:function(){return this.requires("2D")},positionHud:function(a){var b,c,d;return b=a.x,c=a.y,d=a.z,this.attr({viewportX:b,viewportY:c,viewportZ:d,x:b-Crafty.viewport._x,y:c-Crafty.viewport._y,z:d}),this.hudFloat=Crafty.bind("ViewportScroll",function(a){return function(){return a.attr({x:a.viewportX-Crafty.viewport._x,y:a.viewportY-Crafty.viewport._y})}}(this)),this},remove:function(){return Crafty.unbind("ViewportScroll",this.hudFloat)}})}.call(this),function(){Crafty.c("Invincible",{init:function(){return this.requires("Delay, Color"),this.rawColor=this.color(),this.delay(this._blink,250,-1)},_blink:function(){return null==this.blinkOn&&(this.blinkOn=!0),this.blinkOn=!this.blinkOn,this.blinkOn?this.color(this.rawColor,.5):this.color(this.rawColor,100)},remove:function(){return this.color(this.rawColor),this.cancelDelay(this._blink)},invincibleDuration:function(a){return this.delay(function(){return this.removeComponent("Invincible")},a,0)}})}.call(this),function(){Crafty.c("KeyboardControls",{init:function(){return this.requires("Listener"),this.bind("RemoveComponent",function(a){return"ControlScheme"===a?this.removeComponent("KeyboardControls"):void 0})},remove:function(){return this.unbind("KeyDown",this._keyHandling)},setupControls:function(a){return a.addComponent("KeyboardControls").controls(this.controlMap).addComponent("ControlScheme")},controls:function(a){return this.controlMap=a,this.bind("KeyDown",this._keyHandling),this},_keyHandling:function(a){return a.key===this.controlMap.fire?this.trigger("Fire",a):void 0},assignControls:function(a){var b,c,d,e,f,g,h,i,j;b=this.controlMap,h={},d={up:-90,down:90,left:180,right:0};for(c in d){j=d[c],g=b[c],i=Crafty.keys;for(e in i)f=i[e],f===g&&(h[e]=j)}return a.addComponent("Multiway, Keyboard").multiway({y:3,x:1.5},h),this.listenTo(a,"KeyDown",function(c){return c.key===b.fire?a.shoot():void 0})}})}.call(this),function(){Crafty.c("Listener",{init:function(){return this.listeners=[]},remove:function(){var a,b,c,d,e,f,g,h;for(f=this.listeners,h=[],c=0,d=f.length;d>c;c++)g=f[c],e=g.object,b=g.event,a=g.callback,h.push(e.unbind(b,a));return h},listenTo:function(a,b,c,d){var e;return null==d&&(d=this),e=function(){return c.apply(d,arguments)},this.listeners.push({object:a,event:b,callback:e}),a.bind(b,e)}})}.call(this),function(){Crafty.c("Player",{lives:2,points:0,init:function(){},loseLife:function(){return this.lives>0?(this.lives-=1,this.trigger("UpdateLives",{lives:this.lives}),this.lives<=0?Crafty.trigger("PlayerDied",this):void 0):void 0},addPoints:function(a){return this.lives>0?(this.points+=a,this.trigger("UpdatePoints",{points:this.points})):void 0}})}.call(this),function(){Crafty.c("PlayerAssignable",{init:function(){return this.one("Fire",this._assignControls),this.preferredPlayer=null},_assignControls:function(){var a;return a=this._playerWithoutControls(this.preferredPlayer),null==a?void this.one("Fire",this._assignControls):(this.preferredPlayer=a.getId(),this.setupControls(a),a.one("Deactivated",function(a){return function(){return a.one("Fire",a._assignControls)}}(this)))},_playerWithoutControls:function(a){var b,c,d,e,f,g;if(null!==a&&(g=Crafty(a),!g.has("ControlScheme")))return g;for(f=Crafty("Player"),b=0,c=f.length;c>b;b++)if(e=f[b],d=Crafty(e),!d.has("ControlScheme"))return d}}),Crafty.c("ControlScheme",{init:function(){return this.trigger("Activated"),Crafty.trigger("PlayerActivated")},remove:function(){return this.trigger("Deactivated"),Crafty.trigger("PlayerDeactivated")}})}.call(this),function(){Crafty.c("PlayerControlledShip",{init:function(){return this.requires("2D, Canvas, Color, Collision, Delay"),this.attr({w:30,h:30}),this.bind("Moved",function(a){return this.hit("Edge")?this.attr({x:a.x,y:a.y}):void 0}),this._forcedSpeed={x:0,y:0},this.delay(function(){return this.addComponent("Invincible").invincibleDuration(2e3),this.onHit("Enemy",function(){return this.has("Invincible")?void 0:this.trigger("Hit")})},10,0),this.bind("EnterFrame",function(){return this.x+=this._forcedSpeed.x,this.hit("Edge")&&(this.x-=this._forcedSpeed.x),this.hit("Edge")?this.trigger("Hit"):void 0})},forcedSpeed:function(a){return null!=a.x&&null!=a.y?(this._forcedSpeed.x=a.x,this._forcedSpeed.y=a.y):(this._forcedSpeed.x=a,this._forcedSpeed.y=a),this},shoot:function(){return Crafty.e("Bullet").color(this.color()).attr({x:this.x+this.w,y:this.y+this.h/2,w:5,h:5}).fire({origin:this,damage:100,speed:this._forcedSpeed.x+3,direction:0}).bind("HitTarget",function(a){return function(){return a.trigger("BulletHit")}}(this)).bind("DestroyTarget",function(a){return function(){return a.trigger("BulletDestroyedTarget")}}(this))}})}.call(this),function(){Crafty.c("PlayerInfo",{init:function(){return this.requires("2D, Listener")},playerInfo:function(a,b){return this.player=b,this.score=Crafty.e("2D, DOM, Text, HUD").attr({w:150,h:20}).positionHud({x:a,y:10,z:2}).textFont({size:"12px",weight:"bold",family:"Courier new"}),this.player.has("Color")&&this.score.textColor(this.player.color()),this.lives=Crafty.e("2D, DOM, Text, HUD").attr({w:250,h:20}).positionHud({x:a,y:25,z:2}).textFont({size:"12px",weight:"bold",family:"Courier new"}),this.player.has("Color")&&this.lives.textColor(b.color()),this.updatePlayerInfo(),this.listenTo(b,"UpdateLives",this.updatePlayerInfo),this.listenTo(b,"UpdatePoints",this.updatePlayerInfo),this.listenTo(b,"NewComponent",function(a){var b,c,d,e;for(e=[],b=0,c=a.length;c>b;b++)d=a[b],"ControlScheme"===d&&e.push(this.updatePlayerInfo());return e}),this.listenTo(b,"RemoveComponent",function(a){return"ControlScheme"===a?this.updatePlayerInfo():void 0}),this},updatePlayerInfo:function(){return this.score.text(this.player.has("ControlScheme")?"Score: "+this.player.points:this.player.name),this.lives.text(this.player.has("ControlScheme")?0===this.player.lives?"Game Over":"Lives: "+this.player.lives:"Press fire to start!")}})}.call(this),function(){Crafty.c("ScrollWall",{init:function(){var a;return a=480,this.requires("2D, Canvas, Color, Edge, Collision"),this.attr({x:0,y:0,w:2,h:a,speed:{x:0,y:0}}),this._speed={x:0,y:0},this.wallEnd=Crafty.e("2D, Canvas, Color, ScrollFront").attr({x:-(Crafty.viewport.x-Crafty.viewport.width)-3,y:0,h:a,w:2}),this.bind("Remove",function(){return this.wallEnd.destroy()}),this.bind("EnterFrame",function(){var a;return a=this._speed.x,Crafty("PlayerControlledShip").each(function(){var b;return b=Crafty.viewport.width/3,this.x>-(Crafty.viewport.x-Crafty.viewport.width)-b?a+=2:void 0}),this.x+=a,this.wallEnd.x+=a,Crafty.viewport.scroll("_x",-this.x),Crafty.viewport._clamp()}),this.onHit("PlayerControlledShip",function(a){var b,c,d,e,f;for(f=[],c=0,d=a.length;d>c;c++)b=a[c],e=b.obj,f.push(e.attr({x:e.x+this._speed.x}));return f})},scrollWall:function(a){return null!=a.x&&null!=a.y?(this._speed.x=a.x,this._speed.y=a.y):(this._speed.x=a,this._speed.y=a),this},off:function(){return this.unbind("EnterFrame")}})}.call(this),function(){Crafty.c("ShipSpawnable",{init:function(){return this.requires("Listener"),this.bind("Activated",this.spawnShip)},remove:function(){return this.unbind("Activated",this.spawnShip)},spawnPosition:function(a,b){return this.spawnPosition={x:a,y:b},this},spawnShip:function(){var a;if(this.has("ControlScheme")&&this.lives>0)return a=Crafty.e("PlayerControlledShip").attr({x:this.spawnPosition.x-Crafty.viewport.x,y:this.spawnPosition.y-Crafty.viewport.y}),this.has("Color")&&a.color(this.color()),this.has("ControlScheme")&&this.assignControls(a),this.listenTo(a,"BulletHit",function(){return this.addPoints(10)}),this.listenTo(a,"BulletDestroyedTarget",function(){return this.addPoints(50)}),this.listenTo(a,"Hit",function(){return a.destroy(),this.loseLife(),this.spawnShip()}),Crafty.trigger("ShipSpawned",a),this}})}.call(this),function(){Crafty.c("ViewportRelativeMotion",{init:function(){},remove:function(){},viewportRelativeMotion:function(a){var b,c,d;return c=a.x,d=a.y,b=a.speed,this._startLocation={x:c,y:d},this._speed=b,this._initialViewport={x:Crafty.viewport.width/4},this._location={x:c+(c-this._initialViewport.x)*(this._speed-1),y:d},this.attr(this._location),this.motion=Crafty.bind("ViewportScroll",function(a){return function(){var b;return b=(a._initialViewport.x-Crafty.viewport._x)*(a._speed-1),c=a._location.x-b,a.attr({x:c})}}(this)),this},remove:function(){return Crafty.unbind("ViewportScroll",this.motion)}})}.call(this)}(),function(){(function(){Crafty.defineScene("GameOver",function(){return Crafty.background("#111"),Crafty.viewport.x=0,Crafty.viewport.y=0,Crafty.e("2D, DOM, Text").attr({x:200,y:210,w:450}).text("Game Over").textColor("#FF0000").textFont({size:"80px",weight:"bold",family:"Courier new"}),Crafty("Player ControlScheme").each(function(a){return Crafty.e("2D, DOM, Text").attr({x:240,y:310+50*a,w:700}).text(this.name+": "+this.points).textColor(this.color()).textFont({size:"50px",weight:"bold",family:"Courier new"})}),Crafty.e("Delay").delay(function(){return Crafty.e("2D, DOM, Text").attr({x:200,y:590,w:750}).text("Press fire to start again").textColor("#FF0000").textFont({size:"30px",weight:"bold",family:"Courier new"}),Crafty("Player").each(function(){return this.removeComponent("ControlScheme").attr({lives:2,points:0}),this.one("Activated",function(){return Crafty.enterScene("Space",{stage:1})})}),this.delay(function(){return Crafty.enterScene("Intro")},6e4,0)},2e3,0)},function(){return Crafty("Delay").each(function(){return this.destroy()}),Crafty("Player").each(function(){return this.unbind("Activated")})})}).call(this),function(){Crafty.defineScene("Intro",function(){return Crafty.background("#000000"),Crafty.viewport.x=0,Crafty.viewport.y=0,Crafty.e("2D, DOM, Text, Tween, Delay").attr({x:150,y:210,w:450}).text("Speedlazer").textColor("#0000ff").textFont({size:"40px",weight:"bold",family:"Courier new"}).delay(function(){return this.tween({x:250},1e3),this.one("TweenEnd",function(){return this.tween({x:150},1e3)})},2e3,-1),Crafty.e("2D, DOM, Text, Tween, Delay").attr({x:200,y:290,w:750}).text("Press fire to start!").textColor("#FF0000").textFont({size:"20px",weight:"bold",family:"Courier new"}).delay(function(){return this.tween({alpha:0},1e3),this.one("TweenEnd",function(){return this.tween({alpha:1},1e3)})},2e3,-1),Crafty("Player").each(function(){return this.removeComponent("ControlScheme").attr({lives:2,points:0}),this.one("Activated",function(){return Crafty.enterScene("Space",{stage:1})})})},function(){return Crafty("Player").each(function(){return this.unbind("Activated")})})}.call(this),function(){Crafty.defineScene("Space",function(a){var b,c;return b=window.Game,Crafty.background("#000"),Crafty.viewport.x=0,Crafty.viewport.y=0,c=b.levelGenerator.createLevel({stage:a.stage}),c.addBlock("CityStart"),c.addBlock("Dialog",{dialog:[{has:["Player 1"],name:"John",lines:["Let's do some target practice!"]},{has:["Player 1","Player 2"],name:"Jim",lines:["Yeah let's shoot stuff!"]},{only:["Player 2"],name:"Jim",lines:["Woohoo target practice!"]}]}),c.addBlock("OpenSpace"),c.generateBlocks(10),c.addBlock("LevelEnd"),c.start(),Crafty.one("ShipSpawned",function(){return Crafty.e("ScrollWall").scrollWall(1)}),Crafty.bind("ShipSpawned",function(a){return a.forcedSpeed(1)}),Crafty("Player").each(function(a){return this.addComponent("ShipSpawnable").spawnPosition(140,300+50*a),Crafty.e("PlayerInfo").playerInfo(30+180*a,this)}),Crafty("Player ControlScheme").each(function(){return this.spawnShip()}),Crafty.bind("EndOfLevel",function(){return c.stop(),Crafty.enterScene("Space",{stage:a.stage+1})}),Crafty.bind("PlayerDied",function(){var a;return a=!1,Crafty("Player ControlScheme").each(function(){return this.lives>0?a=!0:void 0}),a?void 0:(c.stop(),Crafty.enterScene("GameOver"))})},function(){return Crafty.unbind("EnterFrame"),Crafty.unbind("PlayerDied"),Crafty.unbind("ShipSpawned"),Crafty.unbind("EndOfLevel"),Crafty("Player").each(function(){return this.removeComponent("ShipSpawnable")})})}.call(this)}(),function(){"use strict";var a={start:function(){Crafty.load([],function(){Crafty.init(640,480),Crafty.background("#000000"),Crafty.e("Player, Color").attr({name:"Player 1"}).setName("Player 1").color("#FF0000"),Crafty.e("Player, Color").attr({name:"Player 2"}).setName("Player 2").color("#00FF00"),Crafty.e("Player, Color").attr({name:"Player 3"}).setName("Player 3").color("#0000FF"),Crafty.e("KeyboardControls, PlayerAssignable").controls({fire:Crafty.keys.SPACE,up:Crafty.keys.UP_ARROW,down:Crafty.keys.DOWN_ARROW,left:Crafty.keys.LEFT_ARROW,right:Crafty.keys.RIGHT_ARROW}),Crafty.e("KeyboardControls, PlayerAssignable").controls({fire:Crafty.keys.G,up:Crafty.keys.W,down:Crafty.keys.S,left:Crafty.keys.A,right:Crafty.keys.D}),Crafty.e("GamepadControls, PlayerAssignable").controls({gamepadIndex:0,fire:0}),Crafty.e("GamepadControls, PlayerAssignable").controls({gamepadIndex:1,fire:0}),Crafty.enterScene("Intro")})}};window.Game=a}(),function(){(function(){var a;a=this.Game,a.Level=function(){function a(a,b){this.generator=a,this.data=null!=b?b:{},this.blocks=[],this.bufferLength=2500,this.generationPosition={x:0,y:40},this.visibleHeight=480-this.generationPosition.y}return a.prototype.addBlock=function(a,b){var c,d;return null==b&&(b={}),d=this.generator.buildingBlocks[a],c=new d(this,b),this.blocks.push(c)},a.prototype.generateBlocks=function(a,b){var c,d,e,f,g,h;if(null==b&&(b={}),0!==this.blocks.length){for(e=this.blocks[this.blocks.length-1],c=e.name,h=[],f=d=1,g=a;g>=1?g>=d:d>=g;f=g>=1?++d:--d)c=this._determineNextTileType(c,b),h.push(this.addBlock(c,b));return h}},a.prototype.start=function(){return Crafty.viewport.x=0,Crafty.viewport.y=0,this._update(0),this.blocks[0].enter(),Crafty.bind("LeaveBlock",function(a){return function(b){return a._update(b),b>0&&(a.blocks[b].inScreen(),a.blocks[b-1].leave()),b>1?a.blocks[b-2].clean():void 0}}(this)),Crafty.bind("EnterBlock",function(a){return function(b){return a.blocks[b].enter()}}(this))},a.prototype.stop=function(){var a,b,c,d,e;for(Crafty.unbind("LeaveBlock"),Crafty.unbind("EnterBlock"),d=this.blocks,e=[],b=0,c=d.length;c>b;b++)a=d[b],e.push(a.clean());return e},a.prototype._update=function(a){var b,c,d,e,f,g,h,i,j;for(j=(null!=(g=this.blocks[a])?g.x:void 0)||0,c=j+this.bufferLength,h=this.blocks,i=[],d=e=0,f=h.length;f>e;d=++e)if(b=h[d],d>=a){if(b.build(this.generationPosition,d),this.generationPosition={x:b.x+b.delta.x,y:b.y+b.delta.y},this.generationPosition.x>c)break;i.push(void 0)}return i},a.prototype._determineNextTileType=function(a,b){var c,d,e,f,g,h,i,j,k,l,m,n;if(e=this.generator.buildingBlocks[a],g=e.prototype.next,k=2,d=this.blocks.length,d>=k){for(n=0,m=this.blocks,h=m.length-1;h>=0&&(c=m[h],c.blockType===a);h+=-1)n++;if(n>=k){for(l=[],i=0,j=g.length;j>i;i++)f=g[i],f!==a&&l.push(f);g=l}}return g[Math.floor(Math.random()*g.length)]},a}()}).call(this),function(){var a;a=this.Game,a.LevelBlock=function(){function a(a,b){this.level=a,this.settings=b,this.createdElements=[],this.createdBindings=[]}return a.prototype.screenHeight=480,a.prototype.build=function(a,b){return this.generated?void 0:(null==this.x&&(this.x=a.x),null==this.y&&(this.y=a.y),this.generated=!0,this.generate(),this._notifyEnterFunction(b))},a.prototype._notifyEnterFunction=function(a){return Crafty.e("2D, Canvas, Color, Collision").attr({x:this.x,y:this.y,w:10,h:800}).onHit("ScrollFront",function(){return this.triggeredFront?void 0:(Crafty.trigger("EnterBlock",a),this.triggeredFront=!0)}).onHit("ScrollWall",function(){return this.destroy(),Crafty.trigger("LeaveBlock",a)})},a.prototype.generate=function(){},a.prototype.enter=function(){},a.prototype.inScreen=function(){},a.prototype.leave=function(){},a.prototype.clean=function(){var a,b,c,d,e,f,g,h;for(g=this.createdElements,c=0,e=g.length;e>c;c++)b=g[c],b.destroy();for(this.createdElements=[],h=this.createdBindings,d=0,f=h.length;f>d;d++)a=h[d],Crafty.unbind(a.event,a.callback);return this.createdBindings=[]},a.prototype.add=function(a,b,c){return c.attr({x:this.x+a,y:this.y+b}),this.createdElements.push(c)},a.prototype.addBackground=function(a,b,c,d){return c.addComponent("ViewportRelativeMotion").viewportRelativeMotion({x:this.x+a,y:this.y+b,speed:d}),this.createdElements.push(c)},a.prototype.bind=function(a,b){return this.createdBindings.push({event:a,callback:b}),Crafty.bind(a,b)},a}()}.call(this),function(){var a;a=this.Game,a.LevelGenerator=function(){function b(){this.buildingBlocks={}}return b.prototype.defineBlock=function(a){return this.buildingBlocks[a.prototype.name]=a},b.prototype.createLevel=function(b){return new a.Level(this,b)},b}(),a.levelGenerator=new a.LevelGenerator}.call(this)}(),function(){(function(){var a,b,c,d,e,f,g,h,i,j=function(a,b){function c(){this.constructor=a}for(var d in b)k.call(b,d)&&(a[d]=b[d]);return c.prototype=b.prototype,a.prototype=new c,a.__super__=b.prototype,a},k={}.hasOwnProperty;i=this.Game.levelGenerator,i.defineBlock(a=function(a){function b(){return b.__super__.constructor.apply(this,arguments)}return j(b,a),b.prototype.name="CityStart",b.prototype.delta={x:200,y:0},b.prototype.next=["OpenSpace"],b.prototype.generate=function(){var a;return a=2,this.add(0,0,Crafty.e("2D, Canvas, Edge").attr({w:this.delta.x,h:a})),this.add(0,this.level.visibleHeight-a,Crafty.e("2D, Canvas, Edge").attr({w:this.delta.x,h:a}))},b.prototype.enter=function(){var a,c;return b.__super__.enter.apply(this,arguments),c=250,a=Crafty.e("2D, DOM, Text, Tween, Delay, HUD").attr({w:350,z:1}).text("Stage "+this.level.data.stage).positionHud({x:c+this.x,y:240,z:-1}),this.add(c,340,a),a.textColor("#FF0000").textFont({size:"30px",weight:"bold",family:"Courier new"}).delay(function(){return this.tween({viewportY:a.viewportY+500,alpha:0},3e3)},3e3,0)},b}(this.Game.LevelBlock)),i.defineBlock(c=function(a){function b(){return b.__super__.constructor.apply(this,arguments)}return j(b,a),b.prototype.name="LevelEnd",b.prototype.delta={x:800,y:0},b.prototype.next=[],b.prototype.generate=function(){var a;return a=2,this.add(0,0,Crafty.e("2D, Canvas, Edge, Color").attr({w:this.delta.x,h:a})),this.add(0,this.level.visibleHeight-a,Crafty.e("2D, Canvas, Edge, Color").attr({w:this.delta.x,h:a}))},b.prototype.inScreen=function(){var a;return Crafty("ScrollWall").each(function(){return this.off()}),a=Crafty.e("2D, Canvas, Color, Collision").attr({w:10,h:this.level.visibleHeight}).onHit("PlayerControlledShip",function(){return Crafty.trigger("EndOfLevel"),this.destroy()}),this.add(640,0,a)},b}(this.Game.LevelBlock)),i.defineBlock(d=function(a){function b(){return b.__super__.constructor.apply(this,arguments)}return j(b,a),b.prototype.name="OpenSpace",b.prototype.delta={x:1e3,y:0},b.prototype.next=["OpenSpace","TunnelStart"],b.prototype.supports=["speed","cleared"],b.prototype.generate=function(){var a;return a=2,this.add(0,0,Crafty.e("2D, Canvas, Edge").attr({w:this.delta.x,h:a})),this.add(0,this.level.visibleHeight-a,Crafty.e("2D, Canvas, Edge").attr({w:this.delta.x,h:a})),this.add(400,75,Crafty.e("2D, Canvas, Edge, Color").color("#505045").attr({w:22,h:35})),this.add(900,25,Crafty.e("2D, Canvas, Edge, Color").color("#404045").attr({w:42,h:35})),this.add(600,125,Crafty.e("2D, Canvas, Edge, Color").color("#505045").attr({w:32,h:40})),this.add(500,225,Crafty.e("2D, Canvas, Edge, Color").color("#505045").attr({w:32,h:20})),this.add(800,275,Crafty.e("2D, Canvas, Edge, Color").color("#404040").attr({w:42,h:15}))},b}(this.Game.LevelBlock)),i.defineBlock(g=function(a){function b(){return b.__super__.constructor.apply(this,arguments)}return j(b,a),b.prototype.name="TunnelStart",b.prototype.delta={x:1e3,y:0},b.prototype.next=["TunnelEnd","Tunnel","TunnelTwist"],b.prototype.supports=["speed","cleared"],b.prototype.generate=function(){var a;return a=2,this.add(0,0,Crafty.e("2D, Canvas, Edge, Color").color("#404040").attr({w:350,h:15})),this.add(350,0,Crafty.e("2D, Canvas, Edge, Color").color("#404040").attr({w:100,h:70})),this.add(450,0,Crafty.e("2D, Canvas, Edge, Color").color("#404040").attr({w:550,h:25})),this.add(0,this.level.visibleHeight-a,Crafty.e("2D, Canvas, Edge").attr({w:this.delta.x,h:a})),this.add(380,0,Crafty.e("2D, Canvas, Color").color("#202020").attr({z:-1,w:this.delta.x-380,h:this.level.visibleHeight})),this.addBackground(380,this.level.visibleHeight-360,Crafty.e("2D, Canvas, Color").color("#303030").attr({z:2,w:40,h:360}),1.5),this.addBackground(380,this.level.visibleHeight-180,Crafty.e("2D, Canvas, Color").color("#505050").attr({z:-1,w:40,h:180}),.5),this.addBackground(380,this.level.visibleHeight-90,Crafty.e("2D, Canvas, Color").color("#606060").attr({z:-2,w:40,h:90}),.25)},b.prototype.enter=function(){var a;return a=this.settings.only||[],-1===a.indexOf("cleared")?(this.add(650,150,Crafty.e("Enemy").enemy()),this.add(1e3+50*Math.random(),200+75*Math.random(),Crafty.e("Enemy").enemy()),this.add(1200+50*Math.random(),50+125*Math.random(),Crafty.e("Enemy").enemy()),this.add(1200+250*Math.random(),300+50*Math.random(),Crafty.e("Enemy").enemy())):void 0},b}(this.Game.LevelBlock)),i.defineBlock(f=function(a){function b(){return b.__super__.constructor.apply(this,arguments)}return j(b,a),b.prototype.name="TunnelEnd",b.prototype.delta={x:1e3,y:0},b.prototype.next=["OpenSpace","TunnelStart"],b.prototype.supports=["speed","cleared"],b.prototype.generate=function(){var a,b;return b=2,this.add(0,0,Crafty.e("2D, Canvas, Edge").attr({w:this.delta.x,h:b})),a=15,this.add(0,this.level.visibleHeight-a,Crafty.e("2D, Canvas, Edge, Color").color("#404040").attr({w:350,h:a})),a=70,this.add(350,this.level.visibleHeight-a,Crafty.e("2D, Canvas, Edge, Color").color("#404040").attr({w:100,h:a})),a=25,this.add(450,this.level.visibleHeight-a,Crafty.e("2D, Canvas, Edge, Color").color("#404040").attr({w:550,h:a})),this.add(0,0,Crafty.e("2D, Canvas, Color").color("#202020").attr({z:-1,w:380,h:this.level.visibleHeight})),this.addBackground(380,this.level.visibleHeight-360,Crafty.e("2D, Canvas, Color").color("#303030").attr({z:2,w:40,h:360}),1.5),this.addBackground(380,this.level.visibleHeight-180,Crafty.e("2D, Canvas, Color").color("#505050").attr({z:-1,w:40,h:180}),.5),this.addBackground(380,this.level.visibleHeight-90,Crafty.e("2D, Canvas, Color").color("#606060").attr({z:-2,w:40,h:90}),.25)},b.prototype.enter=function(){var a;return a=this.settings.only||[],-1===a.indexOf("cleared")?(this.add(650,150,Crafty.e("Enemy").enemy()),this.add(1e3+50*Math.random(),200+75*Math.random(),Crafty.e("Enemy").enemy()),this.add(1200+50*Math.random(),50+125*Math.random(),Crafty.e("Enemy").enemy()),this.add(1200+250*Math.random(),300+50*Math.random(),Crafty.e("Enemy").enemy())):void 0},b}(this.Game.LevelBlock)),i.defineBlock(e=function(a){function b(){return b.__super__.constructor.apply(this,arguments)}return j(b,a),b.prototype.name="Tunnel",b.prototype.delta={x:1e3,y:0},b.prototype.next=["TunnelEnd","Tunnel","TunnelTwist"],b.prototype.supports=["speed","cleared"],b.prototype.generate=function(){var a;return this.add(0,0,Crafty.e("2D, Canvas, Edge, Color").color("#404040").attr({w:350,h:15})),this.add(350,0,Crafty.e("2D, Canvas, Edge, Color").color("#404040").attr({w:100,h:70})),this.add(450,0,Crafty.e("2D, Canvas, Edge, Color").color("#404040").attr({w:550,h:25})),a=15,this.add(0,this.level.visibleHeight-a,Crafty.e("2D, Canvas, Edge, Color").color("#404040").attr({w:350,h:a})),a=70,this.add(350,this.level.visibleHeight-a,Crafty.e("2D, Canvas, Edge, Color").color("#404040").attr({w:100,h:a})),a=25,this.add(450,this.level.visibleHeight-a,Crafty.e("2D, Canvas, Edge, Color").color("#404040").attr({w:550,h:a})),this.add(0,0,Crafty.e("2D, Canvas, Color").color("#202020").attr({z:-1,w:this.delta.x,h:this.level.visibleHeight}))},b.prototype.enter=function(){var a;return a=this.settings.only||[],-1===a.indexOf("cleared")?(this.add(1e3+50*Math.random(),200+75*Math.random(),Crafty.e("Enemy").enemy()),this.add(1200+50*Math.random(),150+125*Math.random(),Crafty.e("Enemy").enemy()),this.add(1200+250*Math.random(),100+50*Math.random(),Crafty.e("Enemy").enemy())):void 0},b}(this.Game.LevelBlock)),i.defineBlock(h=function(a){function b(){return b.__super__.constructor.apply(this,arguments)}return j(b,a),b.prototype.name="TunnelTwist",b.prototype.delta={x:1e3,y:0},b.prototype.next=["TunnelTwist","Tunnel"],b.prototype.supports=["cleared"],b.prototype.generate=function(){var a;return this.add(0,0,Crafty.e("2D, Canvas, Edge, Color").color("#404040").attr({w:250,h:15})),this.add(250,0,Crafty.e("2D, Canvas, Edge, Color").color("#404040").attr({w:100,h:220})),this.add(350,0,Crafty.e("2D, Canvas, Edge, Color").color("#404040").attr({w:650,h:25})),a=15,this.add(0,this.level.visibleHeight-a,Crafty.e("2D, Canvas, Edge, Color").color("#404040").attr({w:650,h:a})),a=220,this.add(650,this.level.visibleHeight-a,Crafty.e("2D, Canvas, Edge, Color").color("#404040").attr({w:100,h:a})),a=25,this.add(750,this.level.visibleHeight-a,Crafty.e("2D, Canvas, Edge, Color").color("#404040").attr({w:250,h:a})),this.add(0,0,Crafty.e("2D, Canvas, Color").color("#202020").attr({z:-1,w:this.delta.x,h:this.level.visibleHeight}))},b}(this.Game.LevelBlock)),i.defineBlock(b=function(a){function b(){return b.__super__.constructor.apply(this,arguments)}return j(b,a),b.prototype.name="Dialog",b.prototype.delta={x:0,y:0},b.prototype.next=[],b.prototype.inScreen=function(){return b.__super__.inScreen.apply(this,arguments),this.showDialog()},b.prototype.showDialog=function(a){var b,c,d,e,f,g,h,i,j,k,l;if(null==a&&(a=0),Crafty("Dialog").each(function(){return this.destroy()}),c=this.determineDialog(a),null!=c){for(b=this.settings.dialog[c],l=60,Crafty.e("2D, DOM, Text, Tween, HUD, Dialog").attr({w:550}).text(b.name).positionHud({x:l,y:this.level.visibleHeight-20*(b.lines.length+2),z:2}).textColor("#909090").textFont({size:"16px",weight:"bold",family:"Courier new"}),j=b.lines,d=e=0,g=j.length;g>e;d=++e)i=j[d],Crafty.e("2D, DOM, Text, Tween, HUD, Dialog").attr({w:550}).text(i).positionHud({x:l,y:this.level.visibleHeight-20*(b.lines.length+1-d),z:2}).textColor("#909090").textFont({size:"16px",weight:"bold",family:"Courier new"});for(console.log(b.name),k=b.lines,f=0,h=k.length;h>f;f++)i=k[f],console.log("  "+i);return Crafty.e("Dialog, Delay").delay(function(b){return function(){return b.showDialog(a+1)}}(this),3e3,0)}},b.prototype.determineDialog=function(a){var b,c,d,e,f,g,h,i,j,k,l,m,n;for(null==a&&(a=0),l=[],Crafty("Player ControlScheme").each(function(){return this.lives>0?l.push(this.name):void 0}),m=this.settings.dialog,d=e=0,h=m.length;h>e;d=++e)if(c=m[d],d>=a){if(b=!0,null!=c.has)for(n=c.has,f=0,i=n.length;i>f;f++)k=n[f],-1===l.indexOf(k)&&(b=!1);if(null!=c.only)for(g=0,j=l.length;j>g;g++)k=l[g],-1===c.only.indexOf(k)&&(b=!1);if(b)return d}return null},b}(this.Game.LevelBlock))}).call(this)}(),function(){window.Game.start(),$(document).on("click","button",function(){screenfull.enabled&&(screenfull.request($("#cr-stage")[0]),$(this).blur(),document.addEventListener(screenfull.raw.fullscreenchange,function(){!screenfull.isFullscreen}))}),Crafty.debugBar.show()}();