package mf2c.helloworld;

import integratedtoolkit.types.annotations.Constraints;
import integratedtoolkit.types.annotations.Parameter;
import integratedtoolkit.types.annotations.Parameter.Direction;
import integratedtoolkit.types.annotations.Parameter.Type;
import integratedtoolkit.types.annotations.task.Method;
import mf2c.helloworld.model.Point;

/**
 * @author Paolo Cocco
 * 
 * COMPSs task implementation
 */
public interface IntersectionPointItf {
	
	@Constraints(computingUnits = "1")
	@Method(declaringClass = "mf2c.helloworld.IntersectionImpl")	
	void calculate(
			@Parameter(type = Type.OBJECT, direction = Direction.IN) Double x1, 
			@Parameter(type = Type.OBJECT, direction = Direction.IN) Double y1,
			@Parameter(type = Type.OBJECT, direction = Direction.IN) Double x2, 
			@Parameter(type = Type.OBJECT, direction = Direction.IN) Double y2,
			@Parameter(type = Type.OBJECT, direction = Direction.IN) Double radius,
			@Parameter(type = Type.OBJECT, direction = Direction.INOUT) int[] points,
			@Parameter(type = Type.INT, direction = Direction.IN) int idx
			);

}
