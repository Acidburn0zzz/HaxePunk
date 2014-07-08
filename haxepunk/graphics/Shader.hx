package haxepunk.graphics;

import haxepunk.renderers.Renderer;
import haxepunk.math.Matrix3D;
import lime.graphics.GL;

typedef ShaderSource = {
	var src:String;
	var fragment:Bool;
}

/**
 * GLSL Shader object
 */
class Shader
{

	/**
	 * Creates a new Shader
	 * @param sources  A list of glsl shader sources to compile and link into a program
	 */
	public function new(vertex:String, fragment:String)
	{
		_program = HXP.renderer.compileShaderProgram(vertex, fragment);
	}

	/**
	 * Return the attribute location in this shader
	 * @param a  The attribute name to find
	 */
	public inline function attribute(a:String):Int
	{
		#if flash
		return switch (a)
		{
			case "aVertexPosition": 0;
			case "aTexCoord": 1;
			case "aNormal": 2;
			default: -1;
		}
		#else
		return GL.getAttribLocation(_program, a);
		#end
	}

	/**
	 * Return the uniform location in this shader
	 * @param a  The uniform name to find
	 */
	public inline function uniform(u:String):Location
	{
		#if flash
		return switch (u)
		{
			case "uProjectionMatrix": 0;
			case "uModelViewMatrix": 1;
			default: -1;
		}
		#else
		return GL.getUniformLocation(_program, u);
		#end
	}

	public inline function setMatrix(u:Location, m:Matrix3D):Void
	{
		HXP.renderer.setMatrix(u, m);
	}

	/**
	 * Bind the program for rendering
	 */
	public inline function use()
	{
		HXP.renderer.bindProgram(_program);
	}

	public static function clear()
	{
		HXP.renderer.bindProgram(null);
	}

	private var _program:ShaderProgram;

}
