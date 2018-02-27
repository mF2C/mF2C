package mf2c.helloworld;

/**
 * @author Paolo Cocco
 * 
 * calculates the distance between two points Pn (reference point) and Px (point to be evaluated), 
 * if the distance is less than a given radius then add the point Pn in a list stored on dataclay
 * the method calculate is a COMPSs task (see class IntersectionPointItf)
 */

import mf2c.helloworld.model.PointCollection;
import mf2c.helloworld.dataclay.IntersectionResult;
import mf2c.helloworld.model.Point;

public class IntersectionImpl {

	public static void calculate( Double x1, Double y1, Double x2, Double y2, Double radius, int[] points, int idx) {
		System.out.print("Calculate x1:"+x1+" y1:"+y1+" x2:"+x2+" y2:"+y2+" radius:"+radius);

		double distance = Math.sqrt(
				(x1 - x2) * (x1 - x2) +  
				(y1 - y2) * (y1 - y2)
				);
		
		if (distance <= radius) {
			points[idx] = 1;
			System.out.println(" IntersectionPoint found");
		}
		else {
			points[idx] = 0;
			System.out.println(" IntersectionPoint not found");
		}
	}


}
