package mf2c.helloworld.dataclay;

import dataclay.api.DataClay;
import dataclay.api.DataClayException;

import mf2c.helloworld.model.PointCollection;
import mf2c.helloworld.model.Point;

/**
 * @author Paolo Cocco
 *
 */
public class IntersectionResult {
	public static String DATACLAY_ALIAS = "nearby-points";
	
	private static void usage() {
		System.out.println("Usage: mf2c.helloworld.dataclay.IntersectionResult");
		System.exit(-1);
	}

	public static void main(String[] args) {
		
		if (args.length != 0) {
			usage();
		}
		
		try {
			// Init dataClay session
			DataClay.init();

			PointCollection pc  = PointCollection.getByAlias(DATACLAY_ALIAS);
			
			System.out.println(pc);
			
			// Finish dataClay session
			DataClay.finish();
		} catch (DataClayException e) {
			e.printStackTrace();
		}

	}

}
