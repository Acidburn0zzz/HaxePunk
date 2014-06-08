package haxepunk.scene;

import haxepunk.graphics.Graphic;
import haxepunk.math.Matrix3D;

class Scene
{

	public var camera:Camera;

	public function new()
	{
		camera = new Camera();
		entities = new List<Entity>();
	}

	public function add(e:Entity)
	{
		entities.add(e);
	}

	public function remove(e:Entity)
	{
		entities.remove(e);
	}

	public function addGraphic(graphic:Graphic, layer:Int=0, x:Float=0, y:Float=0)
	{
		var e = new Entity(x, y, layer);
		e.addGraphic(graphic);
		add(e);
	}

	public function draw()
	{
		camera.setup();
		var matrix = camera.matrix.rawData;
		for (entity in entities)
		{
			entity.draw(matrix);
		}
	}

	public function update()
	{
		for (entity in entities)
		{
			entity.update();
		}
	}

	private var entities:List<Entity>;

}
