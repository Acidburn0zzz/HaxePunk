package haxepunk.renderers;

#if !flash

import haxepunk.graphics.Color;
import haxepunk.math.Matrix4;
import haxepunk.renderers.Renderer;
import lime.graphics.Image;
import lime.graphics.GL;
import lime.graphics.GLShader;
import lime.graphics.GLProgram;
import lime.graphics.GLBuffer;
import lime.graphics.GLRenderContext;
import lime.utils.Float32Array;
import lime.utils.Int16Array;

class GLRenderer implements Renderer
{

	public function new(gl:GLRenderContext)
	{
		this.gl = gl;
	}

	public function clear(color:Color):Void
	{
		gl.clearColor(color.r, color.g, color.b, color.a);
		gl.clear(gl.COLOR_BUFFER_BIT);
	}

	public function setViewport(x:Int, y:Int, width:Int, height:Int):Void
	{
#if !neko
		GL.viewport(x, y, HXP.window.width, HXP.window.height);
#end
	}

	public function present():Void { }

	private inline function getBlendFactor(factor:BlendFactor):Int
	{
		return switch (factor) {
			case ONE: gl.ONE;
			case ZERO: gl.ZERO;
			case SOURCE_ALPHA: gl.SRC_ALPHA;
			case DESTINATION_COLOR: gl.DST_COLOR;
			case ONE_MINUS_SOURCE_ALPHA: gl.ONE_MINUS_SRC_ALPHA;
			case ONE_MINUS_SOURCE_COLOR: gl.ONE_MINUS_SRC_COLOR;
		};
	}

	public function setBlendMode(source:BlendFactor, destination:BlendFactor):Void
	{
		if (source == ONE && destination == ZERO)
		{
			gl.disable(gl.BLEND);
		}
		else
		{
			gl.blendFunc(getBlendFactor(source), getBlendFactor(destination));
			gl.enable(gl.BLEND);
		}
	}

	public function createTexture(image:Image):NativeTexture
	{
		image.forcePowerOfTwo();

		var texture = gl.createTexture();
		gl.bindTexture(gl.TEXTURE_2D, texture);
		gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, image.width, image.height, 0, gl.RGBA, gl.UNSIGNED_BYTE, image.data);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);

		return texture;
	}

	public function bindTexture(texture:NativeTexture, sampler:Int):Void
	{
		if (_activeTexture != texture)
		{
			gl.activeTexture(gl.TEXTURE0 + sampler);
			gl.bindTexture(gl.TEXTURE_2D, texture);
			_activeTexture = texture;
		}
	}

	public function compileShaderProgram(vertex:String, fragment:String):ShaderProgram
	{
		var program:GLProgram = gl.createProgram();

		var shader = compileShader(vertex, gl.VERTEX_SHADER);
		if (shader == null) return null;
		gl.attachShader(program, shader);
		gl.deleteShader(shader);

		var shader = compileShader(fragment, gl.FRAGMENT_SHADER);
		if (shader == null) return null;
		gl.attachShader(program, shader);
		gl.deleteShader(shader);

		gl.linkProgram(program);

		if (gl.getProgramParameter(program, gl.LINK_STATUS) == 0)
		{
			trace(gl.getProgramInfoLog(program));
			trace("VALIDATE_STATUS: " + gl.getProgramParameter(program, gl.VALIDATE_STATUS));
			trace("ERROR: " + gl.getError());
			return null;
		}

		return program;
	}

	public function bindProgram(program:ShaderProgram):Void
	{
		if (_activeProgram != program)
		{
			gl.useProgram(program);
			_activeProgram = program;
		}
	}

	public function setMatrix(loc:Location, matrix:Matrix4):Void
	{
		gl.uniformMatrix4fv(loc, false, matrix.native);
	}

	public function setAttribute(a:Int, offset:Int, num:Int, stride:Int):Void
	{
		gl.vertexAttribPointer(a, num, gl.FLOAT, false, stride*4, offset*4);
		gl.enableVertexAttribArray(a);
	}

	public function bindBuffer(v:VertexBuffer):Void
	{
		gl.bindBuffer(GL.ARRAY_BUFFER, v);
	}

	public function createBuffer(data:Float32Array, ?usage:BufferUsage):VertexBuffer
	{
		var buffer = gl.createBuffer();
		gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
		gl.bufferData(gl.ARRAY_BUFFER, data, usage == DYNAMIC_DRAW ? gl.DYNAMIC_DRAW : gl.STATIC_DRAW);
		return buffer;
	}

	public function createIndexBuffer(data:Int16Array, ?usage:BufferUsage):IndexBuffer
	{
		var buffer = gl.createBuffer();
		gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, buffer);
		gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, data, usage == DYNAMIC_DRAW ? gl.DYNAMIC_DRAW : gl.STATIC_DRAW);
		return buffer;
	}

	public function draw(i:IndexBuffer, numTriangles:Int, offset:Int=0):Void
	{
		gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, i);
		gl.drawElements(GL.TRIANGLES, numTriangles * 3, GL.UNSIGNED_SHORT, offset * 3);
	}

	/**
	 * Compiles the shader source into a GlShader object and prints any errors
	 * @param source  The shader source code
	 * @param type    The type of shader to compile (fragment, vertex)
	 */
	private inline function compileShader(source:String, type:Int):GLShader
	{
		var shader = gl.createShader(type);
		gl.shaderSource(shader, source);
		gl.compileShader(shader);

		if (gl.getShaderParameter(shader, gl.COMPILE_STATUS) == 0)
		{
			trace(gl.getShaderInfoLog(shader));
			shader = null;
		}

		return shader;
	}

	public function setDepthTest(depthMask:Bool, ?test:DepthTestCompare):Void
	{
		if (depthMask)
		{
			gl.enable(gl.DEPTH_TEST);
			switch (test)
			{
				case NEVER: gl.depthFunc(gl.NEVER);
				case ALWAYS: gl.depthFunc(gl.ALWAYS);
				case GREATER: gl.depthFunc(gl.GREATER);
				case GREATER_EQUAL: gl.depthFunc(gl.GEQUAL);
				case LESS: gl.depthFunc(gl.LESS);
				case LESS_EQUAL: gl.depthFunc(gl.LEQUAL);
				case EQUAL: gl.depthFunc(gl.EQUAL);
				case NOT_EQUAL: gl.depthFunc(gl.NOTEQUAL);
			}
		}
		else
		{
			gl.disable(gl.DEPTH_TEST);
		}
	}


	private var gl:GLRenderContext;
	private static var _activeProgram:ShaderProgram;
	private static var _activeTexture:NativeTexture;

	// var width = 512, height = 512;
	// _framebuffer = gl.createFramebuffer();
	// gl.bindFramebuffer(gl.FRAMEBUFFER, _framebuffer);

	// _renderbuffer = gl.createRenderbuffer();
	// gl.bindRenderbuffer(gl.RENDERBUFFER, _renderbuffer);
	// gl.renderbufferStorage(gl.RENDERBUFFER, gl.RGBA, width, height);
	// gl.framebufferRenderbuffer(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.RENDERBUFFER, _renderbuffer);

	// var texture = gl.createTexture();
	// gl.bindTexture(gl.TEXTURE_2D, texture);
	// gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
	// gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA,  width, height, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);
	// gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, texture, 0);


	// var extensions = gl.getSupportedExtensions();
	// var pvrtc = false, atc = false, dxtc = false;
	// for (extension in extensions)
	// {
	// 	switch (extension)
	// 	{
	// 		case "GL_AMD_compressed_ATC_texture":
	// 			atc = true;
	// 		case "GL_ATI_texture_compression_atitc":
	// 			atc = true;
	// 		case "GL_IMG_texture_compression_pvrtc":
	// 			pvrtc = true;
	// 		case "WEBGL_compressed_texture_s3tc":
	// 			dxtc = true;
	// 		case "WEBKIT_WEBGL_compressed_texture_s3tc":
	// 			dxtc = true;
	// 		case "GL_OES_texture_compression_S3TC":
	// 			dxtc = true;
	// 		case "GL_EXT_texture_compression_s3tc":
	// 			dxtc = true;
	// 		case "GL_EXT_texture_compression_dxt1":
	// 			dxtc = true;
	// 		case "GL_EXT_texture_compression_dxt3":
	// 			dxtc = true;
	// 		case "GL_EXT_texture_compression_dxt5":
	// 			dxtc = true;
	// 		default:
	// 			trace(extension);
	// 	}
	// }
	// trace(pvrtc, atc, dxtc);

}

#end
