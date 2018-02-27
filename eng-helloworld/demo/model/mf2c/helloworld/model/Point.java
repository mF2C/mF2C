package mf2c.helloworld.model;

/**
 * @author Paolo Cocco
 * 
 * dataclay model for a point in a plane
 * 
 */
public class Point {

	protected double x;
	protected double y;

	public Point( double x, double y)
	{
		this.x = x;
		this.y = y;
	}
	
	public double getX() {
		return x;
	}

	public void setX(double x) {
		this.x = x;
	}

	public double getY() {
		return y;
	}

	public void setY(double y) {
		this.y = y;
	}

	public String toString()
	{
		String result = "Point: ";
		
		result += " x: "+ getX();
		result += " y: "+ getY();
		result += "\n";
		
		return result;
	}

}
