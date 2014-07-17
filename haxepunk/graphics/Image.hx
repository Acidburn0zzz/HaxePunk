package haxepunk.graphics;

import haxepunk.math.Vector3;
import haxepunk.math.Matrix4;
import haxepunk.scene.Camera;
import haxepunk.renderers.Renderer;
import lime.utils.Float32Array;
import lime.utils.Int16Array;
import haxepunk.graphics.SpriteBatch;

class Image implements Graphic
{

	public var material:Material;

	/**
	 * Rotation of the image, in degrees.
	 */
	public var angle:Float = 0;

	/**
	 * Scale of the image.
	 */
	public var scale:Vector3;

	/**
	 * Origin of the image.
	 */
	public var origin:Vector3;

	/**
	 * Flip image on the x-axis
	 * NOTE: This changes the image's scale value. By modifying scale.x you may unintentionally update flippedX.
	 */
	public var flippedX(get, set):Bool;
	private inline function get_flippedX():Bool { return scale.x < 0; }
	private function set_flippedX(value:Bool):Bool {
		scale.x = Math.abs(scale.x) * (value ? -1 : 1);
		return value;
	}

	/**
	 * Flip image on the y-axis
	 * NOTE: This changes the image's scale value. By modifying scale.y you may unintentionally update flippedY.
	 */
	public var flippedY(get, set):Bool;
	private inline function get_flippedY():Bool { return scale.y < 0; }
	private function set_flippedY(value:Bool):Bool {
		scale.y = Math.abs(scale.y) * (value ? -1 : 1);
		return value;
	}

	/**
	 * Width of the image.
	 */
	public var width(get, never):Float;
	private function get_width():Float { return _texture.width; }

	/**
	 * Height of the image.
	 */
	public var height(get, never):Float;
	private function get_height():Float { return _texture.height; }

	/**
	 * Change the opacity of the Image, a value from 0 to 1.
	 */
	public var alpha(default, set):Float;
	private function set_alpha(value:Float):Float
	{
		value = value < 0 ? 0 : (value > 1 ? 1 : value);
		return (alpha == value) ? value : alpha = value;
	}

	public function new(?id:String)
	{
		scale = new Vector3(1, 1, 1);
		origin = new Vector3();
		_matrix = new Matrix4();

#if !unit_test
		_texture = Texture.create(id);
		material = new Material();
		material.addTexture(_texture);

		createBuffer();

		_vertexAttribute = material.shader.attribute("aVertexPosition");
		_texCoordAttribute = material.shader.attribute("aTexCoord");
		_modelViewMatrixUniform = material.shader.uniform("uMatrix");
#end
	}

	public function update(elapsed:Float) {}

	/** @private Creates the buffer. */
	private function createBuffer():Void
	{
		if (_defaultVertexBuffer == null)
		{
			var data:Array<Float> = [
				/* vertex | tex coord | normal */
				0, 0, 0, 0.00, 0.00,
				0, 1, 0, 0.00, 1.00,
				1, 0, 0, 1.00, 0.00,
				1, 1, 0, 1.00, 1.00
			];
			_defaultVertexBuffer = Renderer.createBuffer(5);
			Renderer.bindBuffer(_defaultVertexBuffer);
			Renderer.updateBuffer(new Float32Array(cast data));
		}
		_vertexBuffer = _defaultVertexBuffer;

		if (_defaultIndexBuffer == null)
		{
			var data = [0, 1, 2, 1, 2, 3];
			_defaultIndexBuffer = Renderer.updateIndexBuffer(new Int16Array(cast data));
		}
		_indexBuffer = _defaultIndexBuffer;
	}

	public function centerOrigin():Void
	{
		origin.x = -(width / 2);
		origin.y = -(height / 2);
	}

	private inline function drawBuffer(camera:Camera, offset:Vector3, tileOffset:Int=0):Void
	{
		if (_vertexBuffer == null || _indexBuffer == null) return;

		origin *= scale;
		origin += offset;

		_matrix.identity();
		_matrix.scale(width, height, 1);
		_matrix.translateVector3(origin);
		_matrix.scaleVector3(scale);
		if (angle != 0) _matrix.rotateZ(angle);

		origin -= offset;
		origin /= scale;

		material.use();

		_matrix.multiply(camera.transform);
		Renderer.setMatrix(_modelViewMatrixUniform, _matrix);

		Renderer.bindBuffer(_vertexBuffer);
		Renderer.setAttribute(_vertexAttribute, 0, 3);
		Renderer.setAttribute(_texCoordAttribute, 3, 2);

		Renderer.draw(_indexBuffer, 2, tileOffset * 3);
	}

	public function draw(camera:Camera, offset:Vector3):Void
	{
		drawBuffer(camera, offset);
	}

	private var _texCoordAttribute:Int;
	private var _vertexAttribute:Int;
	private var _modelViewMatrixUniform:Location;

	private var _matrix:Matrix4;
	private var _texture:Texture;
	private var _vertexBuffer:VertexBuffer;
	private var _indexBuffer:IndexBuffer;
	private static var _defaultVertexBuffer:VertexBuffer;
	private static var _defaultIndexBuffer:IndexBuffer;

}
