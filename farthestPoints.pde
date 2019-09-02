/*
This program finds the diameter of a set of randomly generated points in 2D. 
The convex hull is found using Andrew's Monotone Chain algorithm, and the diameter is found from the hull using rotating calipers, adapted for Monotone Chain. 
Monotone Chain was used instead of Graham's Scan because Graham's Scan requires sorting points by cosine or by slope, both of which become subject to round-off error 
as the density of points increase. This caused many errors in the convex hull for large sets of points (e.g. 1 million)

Monotone Chain generates the upper and lower portions of the hull separately, which can be used rotating calipers directly, therefore the 
full, combined convex hull is not necessary for the program. However, feel free to uncomment ArrayList<PVector> convHull below, as well the as other commented pieces of code
to draw the convex hull from the full arraylist.
*/

import java.util.*; //for ArrayList slicing in mergeSort
import g4p_controls.*;

int numPoints = 500;
boolean noise = false;
//ArrayList<PVector> convHull;

PVector[] points;
PVector farthest1, farthest2;
ArrayList<PVector> U, L;
float t, maxD;

void setup() {
  size(800, 800);
  createGUI();
  fill(255);
  textAlign(RIGHT);
  newPlot();
}

void draw() { // here for GUI
}

void newPlot() {  
  //POINT GENERATION
  points = new PVector[numPoints];
  if (noise) {
    for (int i = 0; i < numPoints; i++) {
      points[i] = new PVector(noise(random(50, width-50))*width, noise(random(50, height-100))*height); //generates points based on Perlin noise
    }
  } else {
    for (int i = 0; i < numPoints; i++) {
      points[i] = new PVector(random(50, width-50), random(50, height-100)); //normal Gaussian 
    }
  }
  
  t = millis(); //and so it begins
  
  //SORT POINTS FROM LOW TO HIGH X-COORDINATE (if tie, point with lower y-coordinate is first)
  points = mergeSort(points);

  //ANDREW'S MONOTONE CHAIN ALGORITHM (en.wikibooks.org/wiki/Algorithm_Implementation/Geometry/Convex_hull/Monotone_chain)
  U = new ArrayList(); //upper portion of hull (goes from leftmost point in set to rightmost point in set
  L = new ArrayList(); //lower portion of hull (goes from rightmost point in set to leftmost point in set
  
  for (int i = 0; i < points.length; i++) { //by going from left to right and not allowing left turns, generate top half of hull
    while (U.size() > 1 && crossP(points[i], U.get(U.size()-1), U.get(U.size()-2)) <= 0) { //if the points make a left turn
      U.remove(U.size()-1); //remove the last point in the hull
    }
    U.add(points[i]); //add current point
  }
  
  for (int i = points.length-1; i > -1; i--) { //by going from right to left and not allowing left turns, generate bottom half of hull
    while (L.size() > 1 && crossP(points[i], L.get(L.size()-1), L.get(L.size()-2)) <= 0) { //if the points make a left turn
      L.remove(L.size()-1); //remove the last point in the hull
    }
    L.add(points[i]); //add current point
  }

  //ROTATING CALIPERS (en.wikipedia.org/wiki/Rotating_calipers#Using_monotone_chain_algorithm)
  maxD = 0;
  farthest1 = new PVector();
  farthest2 = new PVector();
  int i = 0; //start from the 1st point in U (leftmost point in set)
  int j = 0; //start from the 1st point in L (rightmost point in set)
  
  while (i < U.size()-1 || j < L.size()-1) { //while we're not through all the points
    //find distance between the points; if bigger than current max, change farthest points
    float d = pow(U.get(i).x-L.get(j).x, 2)+pow(U.get(i).y-L.get(j).y, 2); //didn't bother sqrt here because it's not necessary for comparison
    if (d > maxD) {
      farthest1 = U.get(i);
      farthest2 = L.get(j);
      maxD = d;
    }
    
    //advance indices based on conditions
    if (i == U.size()-1) { //if either i or j is at the end of its list, advance other indice
      j = j + 1;
    } else if (j == L.size()-1) {
      i = i + 1;
    } else if ((U.get(i+1).y - U.get(i).y)/(U.get(i+1).x - U.get(i).x) < (L.get(j+1).y - L.get(j).y)/(L.get(j+1).x - L.get(j).x)) { //the slope of the segment to the next point
    //list with smaller slope to the next point gets its indice advanced
      i = i + 1;
    } else {
      j = j + 1;
    }
  }
  
  t = millis()-t; //algorithm is over; we have found the two points
  
  /*
  convHull = new ArrayList();
  U.remove(0);
  L.remove(0);
  convHull.addAll(U);
  convHull.addAll(L);
  */
  
  drawPoints();
}

void drawPoints(){ //gets called once per plot; not in draw loop to save the CPU
  background(0);
  
  //DRAW POINTS
  stroke(255);
  for (PVector p : points) {
    ellipse(p.x, p.y, 1, 1);
  }

  //DRAW CONVEX HULL
  stroke(255, 0, 0);
  /*
  int s = convHull.size()-1;
  for (int i = 0; i < s; i++) {
    line(convHull.get(i).x, convHull.get(i).y, convHull.get(i+1).x, convHull.get(i+1).y);
  }
  line(convHull.get(0).x, convHull.get(0).y, convHull.get(s).x, convHull.get(s).y);
  */
  
  //if you decide to uncomment above, please comment out code from here
  for (int i = 0; i < U.size()-1; i++) {
    line(U.get(i).x, U.get(i).y, U.get(i+1).x, U.get(i+1).y);
  }
  for (int i = 0; i < L.size()-1; i++) {
    line(L.get(i).x, L.get(i).y, L.get(i+1).x, L.get(i+1).y);
  }
  //to here
  
  //DRAW DIAMETER AND TEXT
  stroke(0, 255, 0);
  line(farthest1.x, farthest1.y, farthest2.x, farthest2.y);
  text("The algorithm took " + t + " milliseconds", 745, 760);
  text("The diameter is " + sqrt(maxD) + " between points (" + farthest1.x + ", " + farthest1.y + ") and ("+ farthest2.x + ", " + farthest2.y + ")", 745, 30);

}

float crossP(PVector p, PVector prev1, PVector prev2) {
  return (prev1.x-prev2.x)*(p.y-prev1.y)-(p.x-prev1.x)*(prev1.y-prev2.y);
}
