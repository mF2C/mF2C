package mf2c.helloworld;


import dataclay.api.DataClay;
import dataclay.api.DataClayException;
import dataclay.exceptions.metadataservice.ObjectNotRegisteredException;
import integratedtoolkit.api.COMPSs;
import mf2c.helloworld.model.PointCollection;
import mf2c.helloworld.dataclay.IntersectionResult;
import mf2c.helloworld.dataclay.ReferencePointsMap;
import mf2c.helloworld.dataclay.SavePoint;
import mf2c.helloworld.model.Point;

/**
 * @author Paolo Cocco
 *
 */
public class IntersectionPoint {

	private static void usage() {
		System.out.println("Usage: mf2c.helloworld.IntersectionPoint <radius>");
		System.exit(-1);
	}
	
	
	public static void main(String[] args) {
		if (args.length != 1) {
			usage();
		}
		
		try
		{
			double radius = Double.parseDouble(args[0]);

			// Init dataClay session
			DataClay.init();
		
			// load reference points map from dataclay
			PointCollection pcref = PointCollection.getByAlias(ReferencePointsMap.DATACLAY_ALIAS);
			System.out.println("Reference points map:\n" + pcref );

			// load known point
			Point px = Point.getByAlias(SavePoint.DATACLAY_ALIAS);
			System.out.println("Point to be evaluated:" + px );
			
			// Create an empty collection on dataclay to store result
			PointCollection pcTemp = new PointCollection();
			pcTemp.makePersistent(IntersectionResult.DATACLAY_ALIAS);
			
			calculateDistance(px, pcref, radius );
			
			// only for COMPSs v1.4
			COMPSs.waitForAllTasks();
			
			PointCollection pcres = PointCollection.getByAlias(IntersectionResult.DATACLAY_ALIAS);
			System.out.println(pcres);
			
			// Finish dataClay session
			DataClay.finish();
			
		}
		catch(ObjectNotRegisteredException onre)
		{
			System.out.println("Object with alias " + SavePoint.DATACLAY_ALIAS + " not found on dataclay");
		} catch (DataClayException e) {
			System.out.println("Unhandled exception on dataClay :" + e.getMessage());
			e.printStackTrace();
		}
		catch (NumberFormatException e) {
			e.printStackTrace();
		}
	}
	
	public static void calculateDistance(Point px, PointCollection pc, double radius)
	{
		int[] points = new int[pc.getPoints().size()];

		for( int idx = 0; idx < pc.getPoints().size(); idx++ )
		{
			Point p = pc.getPoints().get(idx);
			IntersectionImpl.calculate(px.getX(), px.getY(), p.getX(), p.getY(), radius, points, idx );
		}
		
		PointCollection pcRes = PointCollection.getByAlias(IntersectionResult.DATACLAY_ALIAS);
		System.out.println(pcRes);
		
		for( int idx = 0; idx < points.length; idx++ )
		{
			// System.out.println(points[idx]);
			if( points[idx] == 1)
			{
				Point p = pc.getPoints().get(idx);
				pcRes.add(p);
			}
		}
	}

}
