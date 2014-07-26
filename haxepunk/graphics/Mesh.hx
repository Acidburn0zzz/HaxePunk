package haxepunk.graphics;

import lime.utils.Int16Array;
import lime.utils.Float32Array;
import haxepunk.math.Vector3;
import haxepunk.math.Matrix4;
import haxepunk.scene.Camera;
import haxepunk.renderers.Renderer;

class Mesh implements Graphic
{

	/**
	 * The mesh's material
	 */
	public var material:Material;

	public var transform:Matrix4;
	public var lightPos:Vector3;

	/**
	 * Create a new mesh
	 * @param data An array of data containing the following for each index <vertex x, y, z> <texCoord u, v> <normal x, y, z>
	 * @param indices An array referencing the vertex, textCoord, and normal
	 * @param material The material to apply to this mesh
	 */
	public function new(?material:Material)
	{
		transform = new Matrix4();
		this.material = (material == null ? new Material() : material);

		var shader = this.material.firstPass.shader;
		_modelViewMatrixUniform = shader.uniform("uMatrix");
		_lightUniform = shader.uniform("uLightPos");
		_vertexAttribute = shader.attribute("aVertexPosition");
		_texCoordAttribute = shader.attribute("aTexCoord");
		_normalAttribute = shader.attribute("aNormal");

		lightPos = new Vector3(1, 1, 1);
	}

	public function update(elapsed:Float):Void {}

	/**
	 * Draw the mesh
	 * @param projectionMatrix The projection matrix to apply
	 * @param modelViewMatrix The model view matrix to apply
	 */
	public function draw(camera:Camera, offset:Vector3):Void
	{
		Renderer.setDepthTest(true);
		transform.translateVector3(offset);

		Renderer.bindBuffer(_vertexBuffer);
		Renderer.setAttribute(_vertexAttribute, 0, 3);
		Renderer.setAttribute(_texCoordAttribute, 3, 2);
		Renderer.setAttribute(_normalAttribute, 5, 3);

		Renderer.setVector3(_lightUniform, lightPos);

		material.use();
		transform.identity();
		transform.translateVector3(offset);
		transform.multiply(camera.transform);
		Renderer.setMatrix(_modelViewMatrixUniform, transform);

		Renderer.draw(_indexBuffer, _numTriangles);

		// Renderer.bindIndexBuffer(null);
		// material.disable();
		// Renderer.bindBuffer(null);
	}

	public function createBuffer(data:Array<Float>):VertexBuffer
	{
		if (data == null) throw "Vertex data buffer must not be null";
		_vertexBuffer = Renderer.createBuffer(8);
		Renderer.bindBuffer(_vertexBuffer);
		Renderer.updateBuffer(new Float32Array(cast data));
		return _vertexBuffer;
	}

	public function createIndexBuffer(data:Array<Int>):IndexBuffer
	{
		if (data == null) throw "Index buffer must not be null";
		_numTriangles = Std.int(data.length / 3);
		return _indexBuffer = Renderer.updateIndexBuffer(new Int16Array(cast data));
	}

	private var _indexBuffer:IndexBuffer;
	private var _vertexBuffer:VertexBuffer;
	private var _numTriangles:Int = 0;

	private var _modelViewMatrixUniform:Location;
	private var _lightUniform:Location;
	private var _texCoordAttribute:Int;
	private var _vertexAttribute:Int;
	private var _normalAttribute:Int;

}
