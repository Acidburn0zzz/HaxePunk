package haxepunk.scene;

import haxepunk.HXP;
import lime.gl.GL;
import lime.utils.Vector3D;
import lime.utils.Matrix3D;

class Camera
{

	public var matrix:Matrix3D;
	public var position:Vector3D;

	public function new()
	{
	}

	public function make2D()
	{
		matrix = Matrix3D.createOrtho(0, HXP.windowWidth, HXP.windowHeight, 0, 500, -500);
	}

	public function setup()
	{
		make2D();
		GL.viewport(0, 0, HXP.windowWidth, HXP.windowHeight);
		GL.enable(GL.DEPTH_TEST);

		// TODO: set option for clear color per camera?
		GL.clearColor(0.117, 0.117, 0.117, 1.0);
		GL.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);
	}

	public function lookAt(target:Vector3D):Void
	{

	}

}
