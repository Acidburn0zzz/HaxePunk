import haxepunk.Engine;
import haxepunk.HXP;
import haxepunk.graphics.Image;
import haxepunk.graphics.Text;
import haxepunk.math.Math;

class Main extends Engine
{
	override public function ready()
	{
		super.ready();

		// var image = new Image("assets/lime.jpg");
		// image.centerOrigin();
		// scene.addGraphic(image);

		// scene.camera.clearColor.r = scene.camera.clearColor.g = scene.camera.clearColor.b = 0.6;

		// var text = new haxepunk.graphics.Text("The quick brown fox jumps over the lazy dog.", 16);
		// text.color.r = 0.997;
		// text.color.g = 0.868;
		// text.color.b = 0.462;
		// scene.addGraphic(text, 50, 200);

		fps = new Text("", 24);
		scene.addGraphic(fps);

		scene.add(new Player());
	}

	override public function update(deltaTime:Int)
	{
		super.update(deltaTime);
		fps.text = "" + Std.int(HXP.frameRate);
	}

	private var fps:Text;
}
