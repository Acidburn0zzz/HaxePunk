package haxepunk.graphics.importer;

import haxe.ds.StringMap;
import lime.Assets;
import haxepunk.graphics.Mesh;
import haxepunk.renderers.Renderer;

using StringTools;

class Wavefront
{

	public static function load(path:String, ?material:Material):List<Mesh>
	{
		var vertices = new FloatArray();
		var texCoords = new FloatArray();
		var normals = new FloatArray();

		var faces = new Array<Int>();

		var indices = new Array<Array<Int>>();
		var indexMap = new StringMap<Int>();

		var meshList = new List<Mesh>();

		var lines = Assets.getText(path).split("\n");
		var v = 0, t = 0, n = 0;
		var groupName:String = null;
		for (line in lines)
		{
			line = line.trim();
			if (line.startsWith("#") || line == "") continue;

			var parts = line.split(" ");
			for (part in parts) if (part.trim() == "") parts.remove(part);
			if (parts.length == 0) continue;

			switch (parts.shift())
			{
				case "v": // vertex
					vertices[v++] = Std.parseFloat(parts[0]);
					vertices[v++] = Std.parseFloat(parts[1]);
					vertices[v++] = Std.parseFloat(parts[2]);
				case "vt": // vertex tex coord
					texCoords[t++] = Std.parseFloat(parts[0]);
					texCoords[t++] = Std.parseFloat(parts[1]);
				case "vn": // vertex normal
					normals[n++] = Std.parseFloat(parts[0]);
					normals[n++] = Std.parseFloat(parts[1]);
					normals[n++] = Std.parseFloat(parts[2]);
				case "s": // smooth shading
				case "g": // group
					if (groupName != null)
					{
						var data = createMeshData(vertices, texCoords, normals, indices);
						if (data.length > 0)
						{
							var mesh = new Mesh(material);
							mesh.createBuffer(data);
							mesh.createIndexBuffer(faces);
							meshList.push(mesh);
						}
						// t = n = v = 0;
						groupName = null;
					}
					if (parts.length > 0)
						groupName = parts[0];
				case "f": // face
					// convert triangle fan to individual triangles
					var i = 3;
					while (i < parts.length)
					{
						parts.insert(i, parts[0]);
						parts.insert(i+1, parts[i-1]);
						i += 3;
					}
					// parse indices
					for (part in parts)
					{
						if (indexMap.exists(part))
						{
							faces.push(indexMap.get(part));
						}
						else
						{
							var i = indices.length;
							faces.push(i);
							indexMap.set(part, i);

							var p = part.split("/");
							var vv = parseInt(p[0]),
								vt = vv,
								vn = vv;
							if (p.length > 1)
							{
								vt = parseInt(p[1]);
								if (p.length > 2)
								{
									vn = parseInt(p[2]);
								}
							}
							indices.push([vv, vt, vn]);
						}
					}
				case "mtllib":
				case "usemtl":
			}
		}

		var data = createMeshData(vertices, texCoords, normals, indices);
		if (data.length > 0)
		{
			var mesh = new Mesh(material);
			mesh.createBuffer(data);
			mesh.createIndexBuffer(faces);
			meshList.push(mesh);
		}

		return meshList;
	}

	private static function createMeshData(vertices:FloatArray, texCoords:FloatArray, normals:FloatArray, indices:Array<Array<Int>>):FloatArray
	{
		var data = new FloatArray();
		data[indices.length * 8 - 1] = 0.0;
		var d = 0;
		for (index in indices)
		{
			var i = index[0] * 3;
			data[d++] = vertices[i];
			data[d++] = vertices[i + 1];
			data[d++] = vertices[i + 2];

			i = index[1] * 2;
			if (i < texCoords.length)
			{
				data[d++] = texCoords[i];
				data[d++] = texCoords[i + 1];
			}
			else
			{
				data[d++] = data[d++] = 0;
			}

			i = index[2] * 3;
			if (i < normals.length)
			{
				data[d++] = normals[i];
				data[d++] = normals[i + 1];
				data[d++] = normals[i + 2];
			}
			else
			{
				data[d++] = data[d++] = data[d++] = 0;
			}
		}
		return data;
	}

	private static inline function parseInt(str:String):Int
	{
		return (str.trim() == "" ? 0 : Std.parseInt(str) - 1);
	}

}
