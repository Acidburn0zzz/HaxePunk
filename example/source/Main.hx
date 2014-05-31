import haxepunk.Engine;
import haxepunk.HXP;
import haxepunk.scene.Entity;
import haxepunk.graphics.*;
import haxepunk.graphics.shapes.Cube;
import haxepunk.graphics.importer.Wavefront;

class CubeEntity extends Entity
{
	public function new()
	{
		super();

		// var cube = new Cube();
		// cube.material.addTexture(new Texture("assets/lime.png"));

		image = new Image("assets/lime.png");
		image.centerOrigin();
		graphic = image;
	}

	override public function update()
	{
		x = HXP.windowWidth / 2;
		y = HXP.windowHeight / 2;
		image.angle += 1;
		super.update();
	}

	private var image:Image;
}

class Main extends Engine
{
	override public function init()
	{
		scene.add(new CubeEntity());
	}
}
