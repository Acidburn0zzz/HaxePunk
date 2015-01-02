package haxepunk2d.masks;

/**
 *
 */
class Grid extends Mask
{
	/** The tile width. */
	public var tileWidth:Int;

	/** The tile height. */
	public var tileHeight:Int;

	/** The number of columns the grid has. */
	public var columns:Int;

	/** The number of rows the grid has. */
	public var rows:Int;

	/** The grid data. */
	public var data : Array<Array<Tile>>;

	/** The width of the grid mask. */
	var width : Float;

	/** The height of the grid mask. */
	var height : Float;

	/** Half the width of the grid mask. */
	var halfWidth(default, never) : Float;

	/** Half the height of the grid mask. */
	var halfHeight(default, never) : Float;

	/**
	 * Create a new grid mask [width] by [height] with tiles [tileWidth] by [tileHeight].
	 * Ommited config values will use the default values: { offset: (0,0), anchor: (0,0), angle: 0, active: true }.
	 */
	public function new(width:Int, height:Int, tileWidth:Int, tileHeight:Int, ?config:{ offset:Point, anchor:Point, angle:Angle, active:Bool });

	/**
	 * Return the tile located at [column]-[row].
	 */
	public function getTile(column:Int, row:Int) : Tile;

	/**
	 * Sets the value of the tile located at [column]-[row].
	 * Omitted config values will use the following defaults:
	 * { yOffset: 0, slope: 0, group: [] }.
	 */
	public function setTile(column:Int, row:Int, tileType:TileType, ?config:{ yOffset: Float, slope: Float, groups:Either<String, Array<String>> }) : Void;

	/**
	 * Clear the tile located a [column]-[row], making it empty.
	 */
	public function clearTile(column:Int, row:Int) : Void;

	/**
	 * Return the collection of tiles located in the rectangle starting
	 * at [column]-[row] of size [width] by [height].
	 */
	public function getRectangle(column:Int, row:Int, width:Int, height:Int) : Array<Array<Tile>>;

	/**
	 * Sets the value of a collection of tiles located in the rectangle starting
	 * at [column]-[row] of size [width] by [height].
	 * Omitted config values will use the following defaults:
	 * { yOffset: 0, slope: 0, group: [] }.
	 */
	public function setRectangle(column:Int, row:Int, width:Int, height:Int, tileType:TileType, ?config:{ yOffset: Float, slope: Float, groups:Either<String, Array<String>> }) : Void;

	/**
	 * Clear the collection of tiles located in the rectangle starting
	 * at [column]-[row] of size [width] by [height], making them empty.
	 */
	public function clearRectangle(column:Int, row:Int, width:Int, height:Int) : Void;

	/**
	 * Return the collection of tiles located in the outline of
	 * thickness [outlineThickness] of the rectangle starting
	 * at [column]-[row] of size [width] by [height].
	 */
	public function getRectangleOutline(column:Int, row:Int, width:Int, height:Int, outlineThickness:Int) : Array<Array<Tile>>;

	/**
	 * Sets the value of a collection of tiles located in the outline of
	 * thickness [outlineThickness] of the rectangle starting
	 * at [column]-[row] of size [width] by [height].
	 * Omitted config values will use the following defaults:
	 * { yOffset: 0, slope: 0, group: [] }.
	 */
	public function setRectangleOutline(column:Int, row:Int, width:Int, height:Int, outlineThickness:Int, tileType:TileType, ?config:{ yOffset: Float, slope: Float, groups:Either<String, Array<String>> }) : Void;

	/**
	 * Clear the collection of tiles located in the outline of
	 * thickness [outlineThickness] of the rectangle starting
	 * at [column]-[row] of size [width] by [height], making them empty.
	 */
	public function clearRectangleOutline(column:Int, row:Int, width:Int, height:Int, outlineThickness:Int) : Void;

	/**
	 * Shift all the tiles in the grid by [columns] columns
	 * and [rows] rows. Will wrap if [wrap] otherwise the new
	 * tiles will be empty.
	 */
	public function shift(columns:Int, rows:Int, wrap:Bool);
}

/**
 *
 */
class Tile
{
	/**  */
	public var yOffset : Float;

	/**  */
	public var slope : Float;

	/**  */
	public var type : TileType;

	/**  */
	public var groups : Array<String>;

	/**
	 *
	 */
	public inline function new (yOffset:Float, slope:Float, type:TileType, groups:Array<String>)
	{
		this.yOffset = yOffset;
		this.slope = slope;
		this.type = type;
		this.groups = groups;
	}
}

/**
 *
 */
enum TileType
{
	/**  */
	Empty;

	/**  */
	Solid;

	/**  */
	AboveSlope;

	/**  */
	BelowSlope;

	/**  */
	TopLeft;

	/**  */
	TopRight;

	/**  */
	BottomLeft;

	/**  */
	BottomRight;
}
