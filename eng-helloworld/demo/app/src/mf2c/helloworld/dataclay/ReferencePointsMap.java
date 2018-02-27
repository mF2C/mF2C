package mf2c.helloworld.dataclay;

import dataclay.api.DataClay;
import dataclay.api.DataClayException;
import mf2c.helloworld.model.PointCollection;
import mf2c.helloworld.model.Point;

/**
 * @author Paolo Cocco
 *
 */
public class ReferencePointsMap {
	public static String DATACLAY_ALIAS = "reference-points-map";

	private static void usage() {
		System.out.println("Usage: mf2c.helloworld.dataclay.ReferencePointsMap");
		System.exit(-1);
	}

	public static void main(String[] args) {

		if (args.length != 0) {
			usage();
		}

		try {
			// Init dataClay session
			DataClay.init();

			// load an example reference points map 
			savePointMap();
			
			System.out.println("Reference points map stored on dataclay");

			// Finish dataClay session
			DataClay.finish();
		} catch (DataClayException e) {
			e.printStackTrace();
		}

	}
	
	private static void savePointMap() {
		PointCollection pc = new PointCollection();
		pc.makePersistent(DATACLAY_ALIAS);

		// Point( x, y );
		// P1
		Point p = new Point(0, 0);
		p.makePersistent();
		pc.add(p);
		
		// P2
		p = new Point(500, 0);
		p.makePersistent();
		pc.add(p);
		
		// P3
		p = new Point(1000, 0);
		p.makePersistent();
		pc.add(p);

		// P4
		p = new Point(0, 250);
		p.makePersistent();
		pc.add(p);

		// P5
		p = new Point(500, 250);
		p.makePersistent();
		pc.add(p);

		// P6
		p = new Point(1000, 250);
		p.makePersistent();
		pc.add(p);

		// P7
		p = new Point(500, 500);
		p.makePersistent();
		pc.add(p);

		// P8
		p = new Point(0, 750);
		p.makePersistent();
		pc.add(p);

		// P9
		p = new Point(500, 750);
		p.makePersistent();
		pc.add(p);

		// P10
		p = new Point(1000, 750);
		p.makePersistent();
		pc.add(p);		
	}
}
