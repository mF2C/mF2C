package mf2c.helloworld.model;

import java.util.ArrayList;

/**
 * @author Paolo Cocco
 * 
 * dataclay model for a list of points
 * 
 */
public class PointCollection {
	protected ArrayList<Point> points;

	public PointCollection() {
		points = new ArrayList<>();
	}

	public void add(Point point) {
		points.add(point);
	}

	public String toString() {
		String result = "Point: \n";

		for (Point p : points) {
			result += " x: " + p.getX();
			result += " y: " + p.getY();
			result += "\n";
		}
		return result;
	}
	
	public ArrayList<Point> getPoints()
	{
		return points;
	}
	
	public void setPoints(ArrayList<Point> points)
	{
		this.points = points;
	}

}
