

DROP TABLE IF EXISTS dbo.LuxembourgGADM
CREATE TABLE dbo.LuxembourgGADM
(
	ObjectID int PRIMARY KEY,
	Commune nvarchar(300),
	ShapeName nvarchar(300),
	ADM_Level nvarchar(30),
	ShapeLength float(15),
	ShapeArea float(15),
	ShapeID nvarchar(300),
	ShapeGroup nvarchar(30),
	ShapeType nvarchar(30),
	GeoType nvarchar(30),
	ADM_Boundary GEOGRAPHY,
	Long varchar(100),
	Lat varchar(100)
)

CREATE SPATIAL INDEX IX_Boundary ON dbo.LuxembourgGADM(ADM_Boundary)


DECLARE @GEOJSON nvarchar(max)
SELECT @GEOJSON = BulkColumn
FROM OPENROWSET (BULK 'C:\Users\ADMIN\Downloads\geoBoundaries-LUX-ADM3-all\geoBoundaries-LUX-ADM3.geojson', SINGLE_CLOB) as JSON
 

INSERT INTO dbo.LuxembourgGADM (ObjectID, Commune, ShapeName, ADM_Level, ShapeLength, ShapeArea, ShapeID, ShapeGroup, ShapeType, GeoType, ADM_Boundary, Long, Lat)
SELECT
	ObjectID,
	Commune,
	ShapeName,
	ADM_Level,
	ShapeLength,
	ShapeArea,
	ShapeID,
	ShapeGroup,
	ShapeType,
	GeoType,
	geography::STPolyFromText('POLYGON ((' + STRING_AGG(CAST(Long + ' ' + Lat as varchar(max)), ',') + '))',4326).ReorientObject() AS GEOGRAPHY,
	Long,
	Lat
FROM
	OPENJSON(@GEOJSON, '$.features')
	WITH
		(
			ObjectID nvarchar(300) '$.properties.OBJECTID',
			Commune nvarchar(300) '$.properties.COMMUNE',
			ShapeName nvarchar(300) '$.properties.shapeName',
			ADM_Level nvarchar(300) '$.properties.Level',
			ShapeLength nvarchar(300) '$.properties.Shape_Leng',
			ShapeArea nvarchar(300) '$.properties.Shape_Area',
			ShapeID nvarchar(300) '$.properties.shapeID',
			ShapeGroup nvarchar(300) '$.properties.shapeGroup',
			ShapeType nvarchar(300) '$.properties.shapeType',
			GeoType nvarchar(300) '$.geometry.type',
			Long varchar(100) '$.geometry.coordinates[0][0]',
			Lat varchar(100) '$.geometry.coordinates[0][1]'
		)
GROUP BY ObjectID, ObjectID, Commune, ShapeName, ADM_Level, ShapeLength, ShapeArea, ShapeID, ShapeGroup, ShapeType, GeoType,Long, Lat