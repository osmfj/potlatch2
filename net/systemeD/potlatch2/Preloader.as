package net.systemeD.potlatch2 {
    import flash.display.DisplayObject;
    import flash.display.GradientType;
    import flash.display.Sprite;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.filters.DropShadowFilter;
    import flash.geom.Matrix;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    import net.systemeD.halcyon.FileBank;

    public class Preloader extends net.systemeD.potlatch2.PreloaderDisplayBase {

        [Embed("../../../embedded/potlatch2logo.png") ] [Bindable] public var Logo:Class;
        [Embed("../../../embedded/zebra.png") ] private var Zebra:Class;

        private var t:TextField;
        private var f:DropShadowFilter=new DropShadowFilter(2,45,0x000000,0.5)
        private var p2Logo:DisplayObject;
        private var bar:Sprite=new Sprite();
        private var barFrame:Sprite;
        private var mainColor:uint=0x045966;
        private var zebra:BitmapData;
        private var zebraTimer:Timer;
        private var offset:uint=0;

        public function Preloader()
        {
            super();
        }

        // This is called when the preloader has been created as a child on the stage.
        //  Put all real initialization here.
        override public function initialize():void
        {
            super.initialize();

            clear();  // clear here, rather than in draw(), to speed up the drawing

            var b:Bitmap=new Zebra();
            zebra=new BitmapData(b.width,b.height); zebra.draw(b);

            var indent:int = 20;
            var height:int = 20;

            //creates all visual elements
            createAssets();

			// request .zip files
			if (loaderInfo.parameters['assets']) {
				for each (var file:String in loaderInfo.parameters['assets'].split(';')) {
					var asset:Array=file.split('=');
                    if (asset.length == 1) {
                        FileBank.getInstance().addFromZip(asset[0]);
                    } else {
                        FileBank.getInstance().addFromZip(asset[0], asset[1]);
                    }
				}
			}
        }
		
        //this is our "animation" bit
		override protected function draw():void {
			if (_fractionLoaded==1) {
				if (zebraTimer) { return; }
				zebraTimer = new Timer(20);
				zebraTimer.addEventListener(TimerEvent.TIMER, zebraHandler);
				zebraTimer.start();
				t.text="Preparing...";
			} else {
				//make objects below follow loading progress
				//positions are completely arbitrary
				//d tells us the x value of where the loading bar is at
				bar.graphics.beginFill(0xffffff,1)
				bar.graphics.drawRoundRectComplex(0,0,bar.width * _fractionLoaded,15,12,0,0,12);
				bar.graphics.endFill();
				t.text = int(_fractionLoaded*100).toString()+"%";
			}
			var d:Number=barFrame.x + barFrame.width * _fractionLoaded;
			t.x = d - t.width - 5;
		}

		private function zebraHandler(e:Event):void {
			if (_IsInitComplete) {
				zebraTimer.stop();
			} else {
				var matrix:Matrix=new Matrix();
				matrix.translate(offset,0);
				bar.graphics.beginBitmapFill(zebra,matrix);
				bar.graphics.drawRoundRectComplex(0,0,bar.width,15,12,0,0,12);
				bar.graphics.endFill();
				offset=(offset+1) % 25;
			}
		}

        protected function createAssets():void
        {
            //create the logo
            p2Logo = new Logo();
            p2Logo.y = stageHeight/2 - p2Logo.height/2;
            p2Logo.x = stageWidth/2 - p2Logo.width/2;
            //p2Logo.filters = [f];
            addChild(p2Logo);

            //create bar
            bar = new Sprite();
             bar.graphics.drawRoundRectComplex(0,0,400,15,12,0,0,12);
            bar.x = stageWidth/2 - bar.width/2;
            bar.y = stageHeight/1.2 - bar.height/2;
            bar.filters = [f];
            addChild(bar);

            //create bar frame
            barFrame = new Sprite();
            barFrame.graphics.lineStyle(2,0xFFFFFF,1)
            barFrame.graphics.drawRoundRectComplex(0,0,400,15,12,0,0,12);
            barFrame.graphics.endFill();
            barFrame.x = stageWidth/2 - barFrame.width/2;
            barFrame.y = stageHeight/1.2 - barFrame.height/2;
            barFrame.filters = [f];
            addChild(barFrame);

            //create text field to show percentage of loading
            t = new TextField()
            t.y = barFrame.y-27;
            t.filters=[f];
            addChild(t);
            //we can format our text
            var s:TextFormat=new TextFormat("Verdana",null,0xFFFFFF,null,null,null,null,null,"right");
            t.defaultTextFormat=s;
        }

        protected function clear():void
        {
            // Draw gradient background
            var b:Sprite = new Sprite;
             var matrix:Matrix =  new Matrix();
            matrix.createGradientBox(stageWidth, stageHeight, Math.PI/2);
            b.graphics.beginGradientFill(GradientType.LINEAR,
                                        [mainColor, mainColor],
                                        [1,1],
                                        [0,255],
                                        matrix
                                        );
            b.graphics.drawRect(0, 0, stageWidth, stageHeight);
            b.graphics.endFill();
            addChild(b);
        }
    }

}

