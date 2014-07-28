package haxepunk.graphics;

import haxe.ds.StringMap;
import haxepunk.scene.Camera;
import haxepunk.math.Vector3;
import haxepunk.math.Matrix4;
import haxepunk.renderers.Renderer;
import lime.graphics.Font;
import lime.Assets;

using StringTools;

class Text implements Graphic
{

	public var material:Material;
	public var color:Color;
	public var size(default, null):Int;
	public var lineHeight:Int;
	public var tabWidth:Int = 4;
	public var angle:Float = 0;
	public var width(default, null):Float;
	public var height(default, null):Float;

	public function new(text:String, size:Int=16)
	{
		_vertices = new FloatArray();
		_indices = new IntArray();
		_matrix = new Matrix4();
		color = new Color();

		#if (cpp || neko)
		var font = new Font(#if mac "../Resources/" + #end "font/SourceCodePro-Regular.otf");
		#else
		var font = new Font("Georgia");
		#end

		this.size = size;
		this.lineHeight = Std.int(size * 1.4);

		var data = font.createImage(size);
		_glyphs = data.glyphs;

		_texture = new Texture();
		_texture.loadFromImage(data.image);
		#if flash
		var vert = "m44 op, va0, vc0\nmov v0, va1";
		var frag = "tex ft0, v0, fs0 <linear nomip 2d wrap>\nmov ft0.xyz, fc1.xyz\nmov oc, ft0";
		#else
		var vert = Assets.getText("shaders/default.vert");
		var frag = Assets.getText("shaders/text.frag");
		#end
		var shader = new Shader(vert, frag);
		material = Material.fromAsset("materials/text.material");
		material.firstPass.addTexture(_texture);

		_vertexAttribute = shader.attribute("aVertexPosition");
		_texCoordAttribute = shader.attribute("aTexCoord");

		_modelViewMatrixUniform = shader.uniform("uMatrix");
		_colorUniform = shader.uniform("uColor");
		_vertexBuffer = Renderer.createBuffer(5);

		this.text = text;
	}

	public var text(default, set):String;
	private function set_text(value:String):String {
		if (text != value && value.trim() != "")
		{
			var spaceAdvance = _glyphs.get(" ").advance;
			var x = 0.0, y = 0.0;
			var index = 0;
			for (i in 0...value.length)
			{
				var c = value.charAt(i);
				switch (c)
				{
					case "\r": // does nothing
					case "\n":
						x = 0;
						y += lineHeight;
					case "\t":
						x += spaceAdvance * tabWidth;
					case " ":
						x += spaceAdvance;
					default:
						x += writeChar(index++, c, x, y);
				}
			}
			width = x;
			height = y + lineHeight;
			Renderer.bindBuffer(_vertexBuffer);
			Renderer.updateBuffer(_vertices, STATIC_DRAW);
			_indexBuffer = Renderer.updateIndexBuffer(_indices, STATIC_DRAW, _indexBuffer);
		}
		return text = value;
	}

	private inline function writeChar(i:Int, c:String, x:Float = 0, y:Float = 0):Int
	{
		var rect = _glyphs.get(c);

		x += rect.xOffset;
		y += size - rect.yOffset;

		var left   = rect.x / _texture.width;
		var top    = rect.y / _texture.height;
		var right  = left + rect.width / _texture.width;
		var bottom = top + rect.height / _texture.height;

		var index = i * 20;
		_vertices[index++] = x;
		_vertices[index++] = y;
		_vertices[index++] = 0;
		_vertices[index++] = left;
		_vertices[index++] = top;

		_vertices[index++] = x;
		_vertices[index++] = y + rect.height;
		_vertices[index++] = 0;
		_vertices[index++] = left;
		_vertices[index++] = bottom;

		_vertices[index++] = x + rect.width;
		_vertices[index++] = y;
		_vertices[index++] = 0;
		_vertices[index++] = right;
		_vertices[index++] = top;

		_vertices[index++] = x + rect.width;
		_vertices[index++] = y + rect.height;
		_vertices[index++] = 0;
		_vertices[index++] = right;
		_vertices[index++] = bottom;

		index = i * 6;
		_indices[index++] = i*4;
		_indices[index++] = i*4+1;
		_indices[index++] = i*4+2;

		_indices[index++] = i*4+1;
		_indices[index++] = i*4+2;
		_indices[index++] = i*4+3;

		return rect.advance;
	}

	public function update(elapsed:Float) {}

	public function draw(camera:Camera, offset:Vector3):Void
	{
		if (_indexBuffer == null || _vertexBuffer == null) return;

		material.use();

		_matrix.identity();
		_matrix.translateVector3(offset);
		if (angle != 0) _matrix.rotateZ(angle);
		_matrix.multiply(camera.transform);

		Renderer.setMatrix(_modelViewMatrixUniform, _matrix);
		Renderer.setColor(_colorUniform, color);

		Renderer.bindBuffer(_vertexBuffer);
		Renderer.setAttribute(_vertexAttribute, 0, 3);
		Renderer.setAttribute(_texCoordAttribute, 3, 2);

		Renderer.draw(_indexBuffer, text.length * 2, 0);
	}

	private var _glyphs:StringMap<GlyphRect>;
	private var _texture:Texture;
	private var _matrix:Matrix4;

	private var _texCoordAttribute:Int;
	private var _vertexAttribute:Int;
	private var _modelViewMatrixUniform:Location;
	private var _colorUniform:Location;
	private var _widthUniform:Location;
	private var _heightUniform:Location;

	private var _vertices:FloatArray;
	private var _indices:IntArray;
	private var _vertexBuffer:VertexBuffer;
	private var _indexBuffer:IndexBuffer;

}
