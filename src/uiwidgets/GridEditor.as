/**
 * Created by Mallory on 3/31/16.
 */
package uiwidgets {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;

import util.Color;

public class GridEditor extends Sprite{
    private const gridX:int = 4
    private const gridY:int = 4
    private const squareDimension:int = 25;
    private const padding:int = 5;
    private var squares:Array = new Array();
    private var colorPicker:Sprite;
    private var wheelSelector:Shape;
    private var callback:Function;

    public var color:uint = 0xFF0000;

    public function GridEditor(callback:Function, state:String = null) {
        this.callback = callback;
        var bg:Shape = new Shape();
        bg.graphics.beginFill(0x808080);
        bg.graphics.lineStyle(0, 0x666666);
        bg.graphics.drawRect(0, 0, 125, 155);
        bg.graphics.endFill();
        this.addChild(bg);
        this.height = bg.height;
        this.width = bg.width;
        if(state){
            squares = util.JSON.parse(state) as Array;
        }
        else{
            squares = [[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0]];
        }
        for (var i:int=0; i < gridX; i++){
            for(var j:int=0; j < gridY; j++){
                var sx:int = (padding * (j + 1)) + (squareDimension * j);
                var sy:int = (padding * (i + 1)) + (squareDimension * i);
                var square:Square = new Square(this, squareDimension, squareDimension, i, j, squares[i][j]);
                square.x = sx;
                square.y = sy;
                this.addChild(square);
            }
        }
        makeHsvColorPicker();
        wheelSelector = new Shape();
        wheelSelector.graphics.beginFill(0x0);
		wheelSelector.graphics.lineStyle(0);
        wheelSelector.graphics.moveTo(0,0);
        wheelSelector.graphics.lineTo(2,5);
        wheelSelector.graphics.lineTo(4,0);
        wheelSelector.graphics.lineTo(0,0);
        wheelSelector.graphics.endFill();
        wheelSelector.graphics.beginFill(0x0);
        wheelSelector.graphics.moveTo(0,colorPicker.height);
        wheelSelector.graphics.lineTo(2,colorPicker.height - 5);
        wheelSelector.graphics.lineTo(4,colorPicker.height);
        wheelSelector.graphics.lineTo(0,colorPicker.height);
        wheelSelector.graphics.endFill();
		wheelSelector.x = colorPicker.width/2;
		wheelSelector.y = 0;
		colorPicker.addChild(wheelSelector);
        colorPicker.addEventListener(MouseEvent.MOUSE_DOWN, sliderClicked);
        colorPicker.addEventListener(MouseEvent.MOUSE_MOVE, sliderClicked);
        setColorByHSVPos(new Point(wheelSelector.x - wheelSelector.width/2, colorPicker.height/2));
    }

    private function sliderClicked(evt:MouseEvent):void{
        if(evt.buttonDown && evt.localX > 0 && evt.localX < colorPicker.width){
            wheelSelector.x = evt.localX - wheelSelector.width/2;
            var baseX:int = Math.max(0, Math.min(evt.localX, colorPicker.width));
            setColorByHSVPos(new Point(baseX - wheelSelector.width/2, colorPicker.height/2));
        }
    }

    private function makeHsvColorPicker():void{
        colorPicker = new Sprite();
        var w:int = this.width - 2 * padding;
        var h:int = 20;
		var hueFactor:Number = 360 / w;
		var bmd:BitmapData = new BitmapData(w, h, false);
		for (var i:uint = 0; i < w; i++)
			for (var j:uint = 0; j < h; j++)
				bmd.setPixel(i, j, Color.fromHSV(i * hueFactor, 1, 1));
		colorPicker.addChild(new Bitmap(bmd));
        colorPicker.y = 130;
        colorPicker.x = padding;
        this.addChild(colorPicker);
    }

    private function setColorByHSVPos(pos:Point, updateColor:Boolean = true):void {
		var inBounds:Boolean = colorPicker.getChildAt(0).getBounds(colorPicker).contains(pos.x, pos.y);
		if (inBounds) {
			if (updateColor) {
				var b:BitmapData = new BitmapData(1, 1, true, 0);
				var m:Matrix = new Matrix();
				m.translate(-(pos.x + wheelSelector.width/2), -pos.y);
				b.draw(colorPicker, m);
				color = b.getPixel32(0, 0);
			}
		}
	}


    public function showOnStage(s:Stage, x:Number = NaN, y:Number = NaN):void {
        this.x = int(x === x ? x : s.mouseX);
		this.y = int(y === y ? y : s.mouseY);
		s.addChild(this);

		addStageEventListeners();
	}

    private function addStageEventListeners():void {
		stage.addEventListener(MouseEvent.MOUSE_DOWN, stageMouseDown, true);
	}

    private function stageMouseDown(e:MouseEvent):void {
		var t:DisplayObject = e.target as DisplayObject;
		while (t) {
			if (t is GridEditor) return;
			t = t.parent;
		}
        hide();
	}

    private function hide():void{
        if(!stage) return;
        stage.removeEventListener(MouseEvent.MOUSE_DOWN, stageMouseDown, true);
        stage.removeChild(this);

    }

    public function setSquare(on:Boolean, row:int, col:int):void{
        squares[row][col] = on ?  color : 0;
        callback(util.JSON.stringify(squares));
    }

}

}

import flash.display.Sprite;
import flash.events.MouseEvent;

import uiwidgets.GridEditor;

class Square extends Sprite{

    private var editor:GridEditor;
    private var on:Boolean;
    private var row:int;
    private var col:int;

    public function Square(g:GridEditor, width:int, height:int, row:int, col:int, color:uint){
        editor = g;
        on = color > 0;
        this.addEventListener(MouseEvent.CLICK, onClick);
        this.graphics.beginFill(on ? color : 0xF0F0F0);
        this.graphics.lineStyle(0, 0x666666);
        this.graphics.drawRect(0, 0, width, height);
        this.graphics.endFill();
        this.width = width;
        this.height = height;
        this.row = row;
        this.col = col;
    }

    private function onClick(evt:MouseEvent):void{
        on = !on;
        this.graphics.beginFill(on ? editor.color : 0xF0F0F0);
        this.graphics.lineStyle(0, 0x666666);
        this.graphics.drawRect(0, 0, width, height);
        this.graphics.endFill();
        editor.setSquare(on, row, col);
    }

}
