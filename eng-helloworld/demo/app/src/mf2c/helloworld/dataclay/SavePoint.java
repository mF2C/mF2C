package mf2c.helloworld.dataclay;

import dataclay.api.DataClay;
import dataclay.api.DataClayException;
import mf2c.helloworld.model.Point;

/**
 * @author Paolo Cocco
 *
 */
public class SavePoint {
	public static String DATACLAY_ALIAS = "point";
	
	private static void usage() {
		System.out.println("Usage: mf2c.helloworld.dataclay.SavePoint x y");
		System.exit(-1);
	}

	public static void main(String[] args) {
		if (args.length != 2) {
			usage();
		}
		double x = Double.parseDouble(args[0]);
		double y = Double.parseDouble(args[1]);
		
		try {
			// Init dataClay session
			DataClay.init();
			
			// store Point(x,y) on dataclay
			Point p = new Point(x, y);
			p.makePersistent(DATACLAY_ALIAS);
			
			// Finish dataClay session
			DataClay.finish();
		} catch (DataClayException e) {
			e.printStackTrace();
		}

	}

}
