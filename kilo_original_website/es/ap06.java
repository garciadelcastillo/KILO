import processing.core.*; 
import processing.xml.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class ap06 extends PApplet {

// KILO v2.0 - INTERACTIVE STRUCTURAL ANALYSIS TOOL
//
// Project developed by Enrique de Justo Moscard\u00f3 and Jose Luis Garc\u00eda del Castillo y L\u00f3pez (Universidad de Sevilla)
// This work is licensed under a Creative Commons Attribution-ShareAlike 3.0 Unported License
// Inquiries and feedback: info@garciadelcastillo.es

// Libraries
PFont txt10, txt13, txt16;
PImage imgIntro, imgLogoUS;
// import processing.pdf.*;

// Declare objects
Node[] node;
Beam b1;
Load[] load;

// Declare sketch vars
Highlight highlight;
boolean helpToggle=false; boolean welcomeToggle=false;
boolean showAllLoads=true; boolean showValues=true; 
boolean activateDiagramAxial=true; boolean activateDiagramShear=true; boolean activateDiagramBending=true; boolean activateDiagramDeformed=true;
boolean cursorModeLoad=true; boolean beamModeRotation=false; float beamModeRotationAngleTemp;
boolean savePDF=false;
int numberOfNodes, numberOfBeams, numberOfLoads, activeLoads=1;
int currentNode=1; int currentLoad=0; 
int redDark=color(100, 0, 0); int redLight=color(200, 0, 0, 100); int redBright=color(255, 0, 0);
int greenDark=color(0, 100, 0); int greenLight=color(0, 200, 0, 100);
int blueDark=color(0, 0, 100); int blueLight=color(0, 0, 200, 100);
float EI, EIScale;

public void setup() {
  size(1000, 600);
  smooth(); stroke(0); strokeWeight(1); noFill(); ellipseMode(CENTER); imageMode(CENTER);
  // WARNING: remember to optimize createFont to loadFont functions when preparing applet for WEB
//  txt16=createFont("Arial", 16); txt13=createFont("Arial", 13); txt10=createFont("Arial", 10);
  txt16=loadFont("ArialMT-16.vlw"); txt13=loadFont("ArialMT-13.vlw"); txt10=loadFont("ArialMT-10.vlw");
  imgIntro=loadImage("intro.png"); imgLogoUS=loadImage("logous.png");
  
  // NUMBER OF OBJECTS IN SKETCH
  numberOfNodes=2; // applet only works for 2
  numberOfBeams=1; // still useless
  numberOfLoads=5;
  EI=4080.0f;  // EI in kN\u00b7m2. Ex: EI(for a steel IPE-200)=4080
  EIScale=1000.0f;  // Representation scale for deformed beams
  
  // Construct objects
  node=new Node[numberOfNodes];
  load=new Load[numberOfLoads];
  
  // ASSIGN INITIAL STRUCTURAL VARS
  b1=new Beam(0, 0, 400, 0);
  node[0]=new Node('F', 0.00f);  // created with relative position to the beam
  node[1]=new Node('N', 1.00f);  // id.
  load[0]=new Load('U', 0.00f, 1.00f, 20);
  load[1]=new Load('P', 0.75f, 1.00f, 50);
  load[2]=new Load('P', 0.25f, 0.50f, 50);
  load[3]=new Load('M', 0.00f, 0.80f, 50);
  load[4]=new Load('M', 1.00f, 0.80f, -50);

  // Initial sketch setup
  highlight=new Highlight();
  b1.update();
  b1.calcNodeReactionSetup();
  for (int i=0; i<activeLoads; i++) {load[i].update();}
  for (int i=0; i<numberOfNodes; i++) {node[i].update();}
  b1.calcNodesReactions();
  b1.calcBeamDiagramSetup();
  b1.calcBeamDiagramAxial();
  b1.calcBeamDiagramShear();
  b1.calcBeamDiagramBending();
  b1.calcBeamDiagramDeformed();
  updateAllCalculation();
}

public void draw() {
//  if (savePDF==true) {beginRecord(PDF, "screenshot.pdf");}
  background(235);
  fill(255); rect(210, 10, 780, 580);
  textFont(txt13);
  keyboardInteraction();  // Calls the listen to keyboard function
  
  // Call to classes
  pushMatrix();
  translate(100+width/2-(b1.xf-b1.xi)/2, height/2-(b1.yf-b1.yi)/2); 
  b1.display();
  for (int i=0; i<numberOfNodes; i++) {node[i].display();}
  if (activateDiagramAxial==true) {b1.displayBeamDiagramAxial();}
  if (activateDiagramShear==true) {b1.displayBeamDiagramShear();}
  if (activateDiagramBending==true) {b1.displayBeamDiagramBending();}
  if (activateDiagramDeformed==true) {b1.displayBeamDiagramDeformed();}
  if (showAllLoads==false) {load[currentLoad].display();} 
  else {for (int i=0; i<activeLoads; i++) {load[i].display();}}
  b1.displayNodesReactions();
  highlight.display();
  popMatrix();

  displayDataText();  // Displays the left column data text
  if (welcomeToggle==true) {displayWelcomeScreen();}
  if (helpToggle==true) {displayHelp();}
  noFill();
  
//  if (savePDF==true) {endRecord(); savePDF=false;}  // PDF exit route
}
class Beam extends Calculation {
  float xi, yi, xf, yf, slope, L, Lm;  // with L=length, Lm=length in meters
  int nodeCombCase;
  
  Beam (float xi_, float yi_, float xf_, float yf_) {
    xi=xi_; yi=yi_; xf=xf_; yf=yf_;
  }
  
  public void update() {  // Update geometry conditions
    slope=atan((yf-yi)/(xf-xi));
    L=dist(xi, yi, xf, yf); Lm=L/100;
    nodeCombCase=node[0].kindN+node[1].kindN;
  }
  
  public void display() {
    strokeWeight(2.5f);
    line(xi, yi, xf, yf);
    strokeWeight(1);
  }
  
}


class Calculation {
  float[][][] nodeReactionLoad;
  float[][] nodeReactionTotal;
  float[][][] beamDiagramLoad;
  float[][] beamDiagramTotal;  
  int beamRange;
  float[][][] topValueLoad; int[][][] topIndexLoad;  // [numberOfLoads] [0=min, 1=max] [0-4]
  float[][] topValueTotal; int[][] topIndexTotal;  // [numberOfLoads] [0-4]

  public void calcNodeReactionSetup() {
    // To be run only once within the void setup() main function
    // Third column tag: 0 is global Y, 1 is local Y direction, 2 is local X, 3 is bending
    // (global Y (0 column) is not going to be implemented at the moment, less computing)
    nodeReactionLoad=new float[numberOfNodes] [numberOfLoads] [4]; 
    nodeReactionTotal=new float[numberOfNodes] [4];
  }   
  
  public void calcNodesReactions() {  // This will STILL only work for 2-noded beams
    for (int i=0; i<numberOfNodes; i++) {
      for (int k=0; k<4; k++) {nodeReactionTotal[i][k]=0;}  // Resets reaction totals
      for (int j=0; j<activeLoads; j++) {
        for (int k=0; k<4; k++) {nodeReactionLoad[i][j][k]=0;}  // Resets reactions for single loads (helps on beam nodes changes)
        switch(load[j].kindN) {  // Calculation of single load reactions
          case 0:  // Case for PUNTUAL LOADS
            switch(b1.nodeCombCase) {
              case 2: break;  // rod+rod
              case 4:  // rod+sli - Rod is always in the left side (node[0])
                nodeReactionLoad [i] [j] [1] = -load[j].magnitudeY*(((node[1-i].x-node[i].x)-(load[j].xi-node[i].x))/(node[1-i].x-node[i].x));
                nodeReactionLoad [0] [j] [2] = -load[j].magnitudeX;
                break;
              case 7:  // fix+no - Fix is always in the left side (node[0])
                nodeReactionLoad [0] [j] [1] = -load[j].magnitudeY;
                nodeReactionLoad [0] [j] [2] = -load[j].magnitudeX;
                nodeReactionLoad [0] [j] [3] = load[j].magnitudeY*(load[j].ri*b1.L)/100;
                break;              
              case 8: break;  // fix+rod
              case 10: break;  // fix+sli
              case 14: break;  // fix+fix           
            } break;
          case 1:  // Case for MOMENT LOADS
            switch(b1.nodeCombCase) {
              case 2: break;  // rod+rod
              case 4:  // rod+sli - Rod is always in the left side (node[0])
                nodeReactionLoad [i] [j] [1] = -100*load[j].magnitude/b1.L+200*i*load[j].magnitude/b1.L;
                break;
              case 7:  // fix+no - Fix is always in the left side (node[0])
                nodeReactionLoad [0] [j] [3] = -load[j].magnitude;
                break;              
              case 8: break;  // fix+rod
              case 10: break;  // fix+sli
              case 14: break;  // fix+fix
            } break;
          case 2:  // Case for UNIFORM LOAD
            switch(b1.nodeCombCase) {
              case 2: break;  // rod+rod
              case 4:  // rod+sli - Rod is always in the left side (node[0])
                nodeReactionLoad [i] [j] [1] = -b1.L/100*load[j].magnitudeY*(load[j].rf-load[j].ri)*abs(load[j].ri+(load[j].rf-load[j].ri)/2-(1-i));
                nodeReactionLoad [0] [j] [2] = -load[j].magnitudeX*b1.L/100*(load[j].rf-load[j].ri);
                break;
              case 7:  // fix+no - Fix is always in the left side (node[0])
                nodeReactionLoad [0] [j] [1] = -load[j].magnitudeY*(load[j].rf-load[j].ri)*b1.L/100;
                nodeReactionLoad [0] [j] [2] = -load[j].magnitudeX*(load[j].rf-load[j].ri)*b1.L/100;
                nodeReactionLoad [0] [j] [3] = load[j].magnitudeY*(load[j].rf-load[j].ri)*sq(b1.L/100)*(load[j].ri+(load[j].rf-load[j].ri)/2);
                break;              
              case 8: break;  // fix+rod
              case 10: break;  // fix+sli
              case 14: break;  // fix+fix           
            } break;
        }
        for (int k=0; k<4; k++) {nodeReactionTotal[i][k]+=nodeReactionLoad[i][j][k];}  // Calculation of total reactions     
      }
    }
  }
  
  public void displayNodesReactions() {
    for (int i=0; i<numberOfNodes; i++) {
      drawReactionArrows(i); if (showValues==true) {drawReactionText(i);}
    }
  }
  
  public void calcBeamDiagramSetup() {
    // To be run only once within the void setup() main function
    // Third column tag: 0 is axial, 1 is shear, 2 is bending and 3 is deformed
    beamRange=PApplet.parseInt(b1.L);
    beamDiagramLoad=new float[beamRange] [numberOfLoads] [4]; 
    beamDiagramTotal=new float[beamRange] [4];    
    topValueLoad=new float [numberOfLoads] [2] [4]; topIndexLoad=new int [numberOfLoads] [2] [4];
    topValueTotal=new float [2] [4]; topIndexTotal=new int [2] [4]; 
  }
  
  public void calcBeamDiagramAxial() {
    for (int i=0; i<beamRange; i++) {
      beamDiagramTotal[i][0]=0;  // Resets axial totals
      for (int j=0; j<activeLoads; j++) { // Calculates each load's axial forces
        switch(load[j].kindN) {  
          case 0:  // Case for PUNTUAL LOADS
            if (i<load[j].ri*beamRange) {beamDiagramLoad[i][j][0]=nodeReactionLoad[0][j][2];}
            else {beamDiagramLoad[i][j][0]=nodeReactionLoad[0][j][2]+load[j].magnitudeX;}
            break;
          case 1:  // Case for MOMENT LOAD
            beamDiagramLoad[i][j][0]=0;
            break; 
          case 2:  // Case for UNIFORM LOAD
            if (i<load[j].ri*beamRange) {beamDiagramLoad[i][j][0]=nodeReactionLoad[0][j][2];}
            else if (load[j].ri*beamRange<=i && i<=load[j].rf*beamRange) 
              {beamDiagramLoad[i][j][0]=nodeReactionLoad[0][j][2]+(i-load[j].ri*b1.L)*load[j].magnitudeX/100;}
            else if (i>load[j].rf) {beamDiagramLoad[i][j][0]=0;}
            break;
        }
        beamDiagramTotal[i][0]+=beamDiagramLoad[i][j][0];  // Adds to total axial forces per range point
        // Calculates min and max values per load
        if (beamDiagramLoad[i][j][0] < topValueLoad[j][0][0]) {topValueLoad[j][0][0] = beamDiagramLoad[i][j][0]; topIndexLoad[j][0][0] = i;} // min value
        if (beamDiagramLoad[i][j][0] > topValueLoad[j][1][0]) {topValueLoad[j][1][0] = beamDiagramLoad[i][j][0]; topIndexLoad[j][1][0] = i;} // max value
      }   
      // Calculates total min and max values
      if (beamDiagramTotal[i][0] < topValueTotal[0][0]) {topValueTotal[0][0] = beamDiagramTotal[i][0]; topIndexTotal[0][0] = i;}
      if (beamDiagramTotal[i][0] > topValueTotal[1][0]) {topValueTotal[1][0] = beamDiagramTotal[i][0]; topIndexTotal[1][0] = i;}
    }
  }
  
  public void calcBeamDiagramShear() {
    for (int i=0; i<beamRange; i++) {
      beamDiagramTotal[i][1]=0;  // Resets shear totals
      for (int j=0; j<activeLoads; j++) {  // Calculates each load's shear forces
        switch(load[j].kindN) {
          case 0:  // Case for PUNTUAL LOADS
            if (i<load[j].ri*beamRange) {beamDiagramLoad[i][j][1]=nodeReactionLoad[0][j][1];}
            else {beamDiagramLoad[i][j][1]=nodeReactionLoad[0][j][1]+load[j].magnitudeY;}
            break;
          case 1:  // Case for MOMENT LOADS
            beamDiagramLoad[i][j][1]=nodeReactionLoad[0][j][1];
            break;
          case 2:  // Case for LINEAL LOADS
            if (i<load[j].ri*beamRange) {beamDiagramLoad[i][j][1]=nodeReactionLoad[0][j][1];}
            else if (load[j].ri*beamRange<=i && i<=load[j].rf*beamRange)
              {beamDiagramLoad[i][j][1]=nodeReactionLoad[0][j][1]+(i-load[j].ri*b1.L)*load[j].magnitudeY/100;}
            else if (i>load[j].rf) {beamDiagramLoad[i][j][1]=nodeReactionLoad[0][j][1]+(load[j].rf-load[j].ri)*b1.L*load[j].magnitudeY/100;}
            break;
        }
        beamDiagramTotal[i][1]+=beamDiagramLoad[i][j][1];  // Adds to total axial forces per range point
        // Calculates min and max values per load
        if (beamDiagramLoad[i][j][1] < topValueLoad[j][0][1]) {topValueLoad[j][0][1] = beamDiagramLoad[i][j][1]; topIndexLoad[j][0][1] = i;} // min value
        if (beamDiagramLoad[i][j][1] > topValueLoad[j][1][1]) {topValueLoad[j][1][1] = beamDiagramLoad[i][j][1]; topIndexLoad[j][1][1] = i;} // max value
      }   
      // Calculates total min and max values
      if (beamDiagramTotal[i][1] < topValueTotal[0][1]) {topValueTotal[0][1] = beamDiagramTotal[i][1]; topIndexTotal[0][1] = i;}
      if (beamDiagramTotal[i][1] > topValueTotal[1][1]) {topValueTotal[1][1] = beamDiagramTotal[i][1]; topIndexTotal[1][1] = i;}
    }
  }

  public void calcBeamDiagramBending() {
    for (int i=0; i<beamRange; i++) {
      beamDiagramTotal[i][2]=0;  // Resets bending totals
      for (int j=0; j<activeLoads; j++) {  // Calculates each load's bending forces
        switch(load[j].kindN) {
          case 0:  // Case for PUNTUAL LOADS  
            if (i<load[j].ri*beamRange) {beamDiagramLoad[i][j][2]=-nodeReactionLoad[0][j][3]-nodeReactionLoad[0][j][1]*i/100;}
            else {beamDiagramLoad[i][j][2]=-nodeReactionLoad[0][j][3]-nodeReactionLoad[0][j][1]*i/100-load[j].magnitudeY*(i-load[j].ri*b1.L)/100;}
            break;
          case 1:  // Case for MOMENT LOADS
            if (i<load[j].ri*beamRange) {beamDiagramLoad[i][j][2]=-nodeReactionLoad[0][j][3]-nodeReactionLoad[0][j][1]*i/100;}
            else {beamDiagramLoad[i][j][2]=-nodeReactionLoad[0][j][3]-nodeReactionLoad[0][j][1]*i/100-load[j].magnitude;}
            break;
          case 2:  // Case for UNIFORM LOADS
            if (i<load[j].ri*beamRange) {beamDiagramLoad[i][j][2]=-nodeReactionLoad[0][j][3]-nodeReactionLoad[0][j][1]*i/100;}
            else if (load[j].ri*beamRange<=i && i<=load[j].rf*beamRange)
              {beamDiagramLoad[i][j][2]=-nodeReactionLoad[0][j][3]-nodeReactionLoad[0][j][1]*i/100-sq(i-load[j].ri*b1.L)*load[j].magnitudeY/2/10000;}
            else if (i>load[j].rf*beamRange) 
              {beamDiagramLoad[i][j][2]=-nodeReactionLoad[0][j][3]-nodeReactionLoad[0][j][1]*i/100-(load[j].rf-load[j].ri)*(b1.L)*load[j].magnitudeY/100*
              (i-load[j].ri*b1.L-(load[j].rf-load[j].ri)*b1.L/2)/100;}
            break;
        }
        beamDiagramTotal[i][2]+=beamDiagramLoad[i][j][2];  // Adds to total axial forces per range point
        // Calculates min and max values per load
        if (beamDiagramLoad[i][j][2] < topValueLoad[j][0][2]) {topValueLoad[j][0][2] = beamDiagramLoad[i][j][2]; topIndexLoad[j][0][2] = i;} // min value
        if (beamDiagramLoad[i][j][2] > topValueLoad[j][1][2]) {topValueLoad[j][1][2] = beamDiagramLoad[i][j][2]; topIndexLoad[j][1][2] = i;} // max value
      }   
      // Calculates total min and max values
      if (beamDiagramTotal[i][2] < topValueTotal[0][2]) {topValueTotal[0][2] = beamDiagramTotal[i][2]; topIndexTotal[0][2] = i;}
      if (beamDiagramTotal[i][2] > topValueTotal[1][2]) {topValueTotal[1][2] = beamDiagramTotal[i][2]; topIndexTotal[1][2] = i;}
    }
  }
  
  public void calcBeamDiagramDeformed() {
    float I=0;
    for (int i=0; i<beamRange; i++) {
      I=i/100.0f;
      beamDiagramTotal[i][3]=0;  // Resets deformed totals
      for (int j=0; j<activeLoads; j++) {  // Calculates each load's deformed shape
        switch(load[j].kindN) {
          case 0:  // Case for PUNTUAL LOADS
            float a0=load[j].ri*b1.Lm; float b0=b1.Lm-a0;
            switch(b1.nodeCombCase) {
              case 4:  // rod+sli
                if (i<load[j].ri*beamRange) {beamDiagramLoad[i][j][3]=load[j].magnitudeY*b1.Lm*b0*I*
                  (1-sq(b0)/sq(b1.Lm)-sq(I)/sq(b1.Lm))/(6*EI);
                } else {beamDiagramLoad[i][j][3]=load[j].magnitudeY*b1.L/100*a0*(b1.L/100-I)*
                  (1-sq(a0)/sq(b1.Lm)-sq((b1.Lm-I)/b1.Lm))/(6*EI);
                } break;
              case 7:  // fix+no
                if (i<load[j].ri*beamRange) {beamDiagramLoad[i][j][3]=load[j].magnitudeY*sq(I)*(2*a0-b0+b1.Lm-I)/(6*EI);}
                else {beamDiagramLoad[i][j][3]=load[j].magnitudeY*sq(a0)*(3*I-a0)/(6*EI);} break; 
            }
          break;
          case 1:  // Case for MOMENT LOADS
            float a1=load[j].ri*b1.Lm; float b11=b1.Lm-a1;
            switch(b1.nodeCombCase) {
              case 4:  // rod+sli
                if (i<load[j].ri*beamRange) {beamDiagramLoad[i][j][3]=load[j].magnitude*b1.Lm*I*
                  (1-3*sq(b11)/sq(b1.Lm)-sq(I)/sq(b1.Lm))/(6*EI);
                } else {beamDiagramLoad[i][j][3]=-load[j].magnitude*b1.Lm*(b1.Lm-I)*
                  (1-3*sq(a1)/sq(b1.Lm)-sq((b1.Lm-I)/b1.Lm))/(6*EI);
                } break;
              case 7:  // fix+no
                if (i<load[j].ri*beamRange) {beamDiagramLoad[i][j][3]=-load[j].magnitude*sq(I)/(2*EI);}
                else {beamDiagramLoad[i][j][3]=-load[j].magnitude*a1*(2*b1.Lm-2*(b1.Lm-I)-a1)/(2*EI);} break; 
            }
          break;
          case 2:  // Case for UNIFORM LOADS
            float a2=load[j].ri*b1.Lm+(load[j].rf-load[j].ri)*b1.Lm/2;
            float b2=b1.Lm-(load[j].ri*b1.Lm+(load[j].rf-load[j].ri)*b1.Lm/2);
            float c2=(load[j].rf-load[j].ri)*b1.Lm;
            switch(b1.nodeCombCase) {
              case 4:  // rod+sli
                if (i<load[j].ri*beamRange) {beamDiagramLoad[i][j][3]=load[j].magnitudeY*b2*c2*I*(-sq(I)+a2*(b1.Lm+b2-sq(c2)/(4*a2)))/(6*b1.Lm*EI);} 
                else if (load[j].ri*beamRange<=i && i<=load[j].rf*beamRange) {beamDiagramLoad[i][j][3]=
                  load[j].magnitudeY*(b1.Lm*pow((I-(a2-c2/2)), 4)-4*b2*c2*pow(I, 3)+4*a2*b2*c2*I*(b1.Lm+b2-sq(c2)/(4*a2)))/(24*b1.Lm*EI);} 
                else {beamDiagramLoad[i][j][3]=load[j].magnitudeY*a2*c2*(b1.Lm-I)*(-sq(b1.Lm-I)+b2*(b1.Lm+a2-sq(c2)/(4*b2)))/(6*b1.Lm*EI);}       
              break;
              case 7:  // fix+no
                if (i<load[j].ri*beamRange) {beamDiagramLoad[i][j][3]=load[j].magnitudeY*c2*sq(I)*(2*a2-b2+b1.Lm-I)/(6*EI);}
                else if (load[j].ri*beamRange<=i && i<=load[j].rf*beamRange) {beamDiagramLoad[i][j][3]=
                  load[j].magnitudeY*(pow(b1.Lm-I-b2+c2/2, 4)+4*c2*(b2-b1.Lm+I)*(3*sq(a2)+sq(c2)/4)+8*pow(a2, 3)*c2)/(24*EI);}
                else {beamDiagramLoad[i][j][3]=load[j].magnitudeY*c2*((b2-b1.Lm+I)*(3*sq(a2)+sq(c2)/4)+2*pow(a2, 3))/(6*EI);}
              break;
            }          
          break;
        }
        beamDiagramTotal[i][3]+=beamDiagramLoad[i][j][3];  // Adds to total axial forces per range point
        // Calculates min and max values per load
        if (beamDiagramLoad[i][j][3] < topValueLoad[j][0][3]) {topValueLoad[j][0][3] = beamDiagramLoad[i][j][3]; topIndexLoad[j][0][3] = i;} // min value
        if (beamDiagramLoad[i][j][3] > topValueLoad[j][1][3]) {topValueLoad[j][1][3] = beamDiagramLoad[i][j][3]; topIndexLoad[j][1][3] = i;} // max value
      }   
      // Calculates total min and max values
      if (beamDiagramTotal[i][3] < topValueTotal[0][3]) {topValueTotal[0][3] = beamDiagramTotal[i][3]; topIndexTotal[0][3] = i;}
      if (beamDiagramTotal[i][3] > topValueTotal[1][3]) {topValueTotal[1][3] = beamDiagramTotal[i][3]; topIndexTotal[1][3] = i;}
    }
  }

  public void displayBeamDiagramAxial() {drawBeamDiagram(0); if (showValues==true) {drawBeamDiagramValues(0);}}
  public void displayBeamDiagramShear() {drawBeamDiagram(1); if (showValues==true) {drawBeamDiagramValues(1);}}
  public void displayBeamDiagramBending() {drawBeamDiagram(2); if (showValues==true) {drawBeamDiagramValues(2);}}
  public void displayBeamDiagramDeformed() {drawBeamDiagram(3); if (showValues==true) {drawBeamDiagramValues(3);}}
  
}
class Load extends Calculation {
  char kind;  // char-coded load kind: P (puntual, M (moment), U (uniform)
  float ri, rf, xi, yi, xf, yf, magnitude, magnitudeX, magnitudeY;
  int kindN;  // Number-coded load kind: 0=Puntual, 1=Moment, 2=Uniform
  
  Load(char kind_, float ri_, float rf_, float magnitude_) {
    kind=kind_;
    ri=ri_; rf=rf_;
    magnitude=magnitude_;
    magnitudeX=magnitude*sin(b1.slope); magnitudeY=magnitude*cos(b1.slope);
  }
  
  // Updates loads relative positions
  public void update() {
    if (rf<ri || ri>rf) {rf=ri;}
    // Translates relative positions to absolute coordinates
    xi=ri*(b1.xf-b1.xi); yi=ri*(b1.yf-b1.yi);
    xf=rf*(b1.xf-b1.xi); yf=rf*(b1.yf-b1.yi);
    magnitudeX=magnitude*sin(b1.slope); magnitudeY=magnitude*cos(b1.slope); 
    if (kind=='P') {kindN=0;}
    else if (kind=='M') {kindN=1;}
    else if (kind=='U') {kindN=2;}
  }
  
  public void display() {
    stroke(greenDark);
    pushMatrix();
    translate(xi, yi);
    if (kind=='P') {drawLoadPuntual(magnitude);}
    else if (kind=='M') {drawLoadMoment(magnitude);}
    else if (kind=='U') {drawLoadLineal(ri, rf, magnitude);}
    popMatrix();
    stroke(0);
  }
  
}
class Node extends Calculation {
  char kind;  // char-coded node id.: N, R, S, F, G (None, Rod, Slider, Fix-left, Fix-right, implemented to be used with switch command)
  float x, y, r;  // absolute x, y positions, relative beam r position
  float size_=9;  // node icon drawing size
  int kindN;  // Number-coded node id.: 0=No node, 1=Rod, 3=Slider, 7=Fix
  int kindD;  // Number-coded drawing node id.: N=0, R=1, S=2, F=3, G=4
  
  Node(char kind_, float r_) {
    kind=kind_;
    r=r_;
  }
  
  public void update() {
    if (r>1) {r=1;} else if (r<0) {r=0;}
    x=r*(b1.xf-b1.xi); y=r*(b1.yf-b1.yi);
    switch (kind) {
      case 'N': kindN=0; kindD=0; break;
      case 'R': kindN=1; kindD=1; break; 
      case 'S': kindN=3; kindD=2; break;
      case 'F': kindN=7; kindD=3; break;
      case 'G': kindN=7; kindD=4; break;
    }
  }
  
  public void display() {
    pushMatrix(); 
    translate (x, y); rotate(b1.slope); scale(size_/9);
    drawNode(kindD);
    popMatrix();
  }
 
}


public void drawAxisCoordinate(int linescolour) {
  stroke(linescolour);
  line(0, 0, 25, 0); line(0, 0, 0, 25);
  ellipse(25, 0, 5, 5); ellipse(0, 25, 5, 5);
  stroke(0);
}

public void drawNode(int kind) {
  switch(kind) {
    case 0: break; // No node
    case 1:  // Rod
      beginShape();
      vertex (0, 0); vertex (6, 9); vertex (-6, 9);
      endShape (CLOSE);
      for (int i=0; i<4; i++) {line(-6+3*(i+1), 9, -6+3*i, 12);}
      fill(255); ellipse(0, 0, 4, 4); noFill(); break;
    case 2:  // Slider
      beginShape(); 
      vertex (0, 0); vertex (6, 9); vertex (-6, 9);
      endShape (CLOSE);
      fill(255); ellipse(-3, 11, 4, 4); ellipse(3, 11, 4, 4);
      ellipse(0, 0, 4, 4); noFill(); break;
    case 3:  // Left fix
      line(0, -9, 0, 9); for (int i=0; i<6; i++) {line(0, -9+3*i, -3, -9+3*(i+1));} break;
    case 4:  // Right fix
      line(0, -9, 0, 9); for (int i=0; i<6; i++) {line(0, -9+3*(i+1), 3, -9+3*i);} break;
    }
}

public void drawLoadPuntual(float magnitude) {
  strokeWeight(1.5f);
  line(0, 0, 0, -magnitude);
  if (magnitude>=0) {line(0, 0, 3, -3); line(0, 0, -3, -3);}
  else {line(0, 0, 3, 3); line(0, 0, -3, 3);}  
  if (showValues==true) {
    textFont(txt10); textAlign(CENTER); fill(greenDark);
    if (magnitude>=0) {text(PApplet.parseInt(magnitude)+" kN", 0, -magnitude-2);}
    else {text(PApplet.parseInt(magnitude)+" kN", 0, -magnitude+10);}
    textFont(txt13); textAlign(LEFT); noFill();
  }
  strokeWeight(1);
}

public void drawLoadMoment(float magnitude) {
  strokeWeight(1.5f);
  line(0, -3, 0, 3);
  if (magnitude>0) {
    arc(0, 0, 2*magnitude, 2*magnitude, HALF_PI, TWO_PI);
    line(0, magnitude, -3, magnitude-3); line(0, magnitude, -3, magnitude+3);
  } else {
    arc(0, 0, -2*magnitude, -2*magnitude, -PI, HALF_PI);
    line(0, -magnitude, 3, -magnitude-3); line(0, -magnitude, 3, -magnitude+3);
  }
  if (showValues==true) {
    textFont(txt10); fill(greenDark); textAlign(CENTER);
    if (magnitude>0) {text(PApplet.parseInt(magnitude)+" kN\u00b7m", 0, magnitude+18);}
    if (magnitude<0) {text(PApplet.parseInt(magnitude)+" kN\u00b7m", 0, -magnitude+18);}
    textFont(txt13); textAlign(LEFT); noFill();
  }
  strokeWeight(1);
}

public void drawLoadLineal(float ri, float rf, float magnitude) {
  strokeWeight(1.5f);
  float intMax=15.0f;
  float longitude=(rf-ri)*(b1.xf-b1.xi);
  float divisions=ceil(abs(longitude)/intMax);
  float interval=longitude/divisions;
  float lengthIncrement, heightIncrement;
  for (int i=0; i<=divisions; i++) {
    lengthIncrement=i*interval; heightIncrement=(longitude*b1.yf/b1.xf)*i/divisions;
    line(lengthIncrement, heightIncrement, lengthIncrement, heightIncrement-magnitude);
    if (magnitude==0) {/*Do nothing*/} 
    else if (magnitude>0) {
      line(lengthIncrement, heightIncrement, lengthIncrement-3, heightIncrement-3);
      line(lengthIncrement, heightIncrement, lengthIncrement+3, heightIncrement-3);
    } else if (magnitude<0) {
      line(lengthIncrement, heightIncrement, lengthIncrement-3, heightIncrement+3);
      line(lengthIncrement, heightIncrement, lengthIncrement+3, heightIncrement+3);
    }
  }
  line(0, -magnitude, longitude, (longitude*b1.yf/b1.xf)-magnitude);
  if (showValues==true) {
    textFont(txt10); textAlign(CENTER); fill(greenDark);
    if (magnitude>=0) {text(PApplet.parseInt(magnitude)+" kN/m", longitude/2, (rf-ri)*(b1.yf-b1.yi)/2-magnitude-2);}
    else {text(PApplet.parseInt(magnitude)+" kN/m", longitude/2, (rf-ri)*(b1.yf-b1.yi)/2-magnitude+10);}
    textFont(txt13); textAlign(LEFT); noFill();
  }
  strokeWeight(1);
}

public void drawReactionArrows(int i) {
  stroke(greenDark); strokeWeight(1.5f);
  pushMatrix(); 
  translate(node[i].x, node[i].y); rotate(b1.slope);
  if (showAllLoads==true) {  // Drawing of total-load reaction arrows 
    // Draw horizontal reactions arrows
    if (b1.nodeReactionTotal[i][2]==0) {/* Do nothing */}
    else if (b1.nodeReactionTotal[i][2]>0) {
      line(0, 20, b1.nodeReactionTotal[i][2], 20);
      line(b1.nodeReactionTotal[i][2], 20, b1.nodeReactionTotal[i][2]-3, 20-3);
      line(b1.nodeReactionTotal[i][2], 20, b1.nodeReactionTotal[i][2]-3, 20+3);
    } else if (b1.nodeReactionTotal[i][2]<0) {
      line(0, 20, b1.nodeReactionTotal[i][2], 20);
      line(b1.nodeReactionTotal[i][2], 20, b1.nodeReactionTotal[i][2]+3, 20-3);
      line(b1.nodeReactionTotal[i][2], 20, b1.nodeReactionTotal[i][2]+3, 20+3);
    }
    // Draws vertical reactions arrows
    if (b1.nodeReactionTotal[i][1]==0) {/* Do nothing */}
    else if (b1.nodeReactionTotal[i][1]>0) {
      line(0, 20, 0, 20+b1.nodeReactionTotal[i][1]);
      line(0, 20+b1.nodeReactionTotal[i][1], -3, 20+b1.nodeReactionTotal[i][1]-3);
      line(0, 20+b1.nodeReactionTotal[i][1], +3, 20+b1.nodeReactionTotal[i][1]-3);
    } else if (b1.nodeReactionTotal[i][1]<0) {
      line(0, 20, 0, 20-b1.nodeReactionTotal[i][1]);
      line(0, 20, -3, 20+3);
      line(0, 20, +3, 20+3);      
    }
    // Draws moment reaction arrows - i is used as a 0-1 switch
    if (b1.nodeReactionTotal[i][3]==0) {/* Do nothing */}
    else if (b1.nodeReactionTotal[i][3]>0) {
      arc(-20+40*i, 0, 2*b1.nodeReactionTotal[i][3], 2*b1.nodeReactionTotal[i][3], HALF_PI+2*HALF_PI*i, 3*HALF_PI+2*HALF_PI*i);
      line(-20+40*i, b1.nodeReactionTotal[i][3]-2*b1.nodeReactionTotal[i][3]*i, -23+46*i, b1.nodeReactionTotal[i][3]-3-(2*b1.nodeReactionTotal[i][3])*i);
      line(-20+40*i, b1.nodeReactionTotal[i][3]-2*b1.nodeReactionTotal[i][3]*i, -23+46*i, b1.nodeReactionTotal[i][3]+3-(2*b1.nodeReactionTotal[i][3])*i);
    } else if (b1.nodeReactionTotal[i][3]<0) {
      arc(-20+40*i, 0, -2*b1.nodeReactionTotal[i][3], -2*b1.nodeReactionTotal[i][3], HALF_PI+2*HALF_PI*i, 3*HALF_PI+2*HALF_PI*i);
      line(-20+40*i, b1.nodeReactionTotal[i][3]-2*b1.nodeReactionTotal[i][3]*i, -23+46*i, b1.nodeReactionTotal[i][3]-3-(2*b1.nodeReactionTotal[i][3])*i);
      line(-20+40*i, b1.nodeReactionTotal[i][3]-2*b1.nodeReactionTotal[i][3]*i, -23+46*i, b1.nodeReactionTotal[i][3]+3-(2*b1.nodeReactionTotal[i][3])*i);
    }
  } else {  // Drawing of single-load reaction arrows
    // Draws horizontal reactions arrows
    if (b1.nodeReactionLoad[i][currentLoad][2]==0) {/* Do nothing */}
    else if (b1.nodeReactionLoad[i][currentLoad][2]>0) {
      line(0, 20, b1.nodeReactionLoad[i][currentLoad][2], 20);
      line(b1.nodeReactionLoad[i][currentLoad][2], 20, b1.nodeReactionLoad[i][currentLoad][2]-3, 20-3);
      line(b1.nodeReactionLoad[i][currentLoad][2], 20, b1.nodeReactionLoad[i][currentLoad][2]-3, 20+3);
    } else if (b1.nodeReactionLoad[i][currentLoad][2]<0) {
      line(0, 20, b1.nodeReactionLoad[i][currentLoad][2], 20);
      line(b1.nodeReactionLoad[i][currentLoad][2], 20, b1.nodeReactionLoad[i][currentLoad][2]+3, 20-3);
      line(b1.nodeReactionLoad[i][currentLoad][2], 20, b1.nodeReactionLoad[i][currentLoad][2]+3, 20+3);
    }
    // Draws vertical reactions arrows
    if (b1.nodeReactionLoad[i][currentLoad][1]==0) {/* Do nothing */}
    else if (b1.nodeReactionLoad[i][currentLoad][1]>0) {
      line(0, 20, 0, 20+b1.nodeReactionLoad[i][currentLoad][1]);
      line(0, 20+b1.nodeReactionLoad[i][currentLoad][1], -3, 20+b1.nodeReactionLoad[i][currentLoad][1]-3);
      line(0, 20+b1.nodeReactionLoad[i][currentLoad][1], +3, 20+b1.nodeReactionLoad[i][currentLoad][1]-3);
    } else if (b1.nodeReactionLoad[i][currentLoad][1]<0) {
      line(0, 20, 0, 20-b1.nodeReactionLoad[i][currentLoad][1]);
      line(0, 20, -3, 20+3); line(0, 20, +3, 20+3);
    }
    // Draws moment reaction arrows, i is used as a 0-1 switch
    if (b1.nodeReactionLoad[i][currentLoad][3]==0) {/* Do nothing */}
    else if (b1.nodeReactionLoad[i][currentLoad][3]>0) {
      arc(-20+40*i, 0, 2*b1.nodeReactionLoad[i][currentLoad][3], 2*b1.nodeReactionLoad[i][currentLoad][3], HALF_PI+2*HALF_PI*i, 3*HALF_PI+2*HALF_PI*i);
      line(-20+40*i, b1.nodeReactionLoad[i][currentLoad][3]-2*b1.nodeReactionLoad[i][currentLoad][3]*i, -23+46*i, b1.nodeReactionLoad[i][currentLoad][3]-3-(2*b1.nodeReactionLoad[i][currentLoad][3])*i);
      line(-20+40*i, b1.nodeReactionLoad[i][currentLoad][3]-2*b1.nodeReactionLoad[i][currentLoad][3]*i, -23+46*i, b1.nodeReactionLoad[i][currentLoad][3]+3-(2*b1.nodeReactionLoad[i][currentLoad][3])*i);
    } else if (b1.nodeReactionLoad[i][currentLoad][3]<0) {
      arc(-20+40*i, 0, -2*b1.nodeReactionLoad[i][currentLoad][3], -2*b1.nodeReactionLoad[i][currentLoad][3], HALF_PI+2*HALF_PI*i, 3*HALF_PI+2*HALF_PI*i);
      line(-20+40*i, b1.nodeReactionLoad[i][currentLoad][3]-2*b1.nodeReactionLoad[i][currentLoad][3]*i, -23+46*i, b1.nodeReactionLoad[i][currentLoad][3]-3-(2*b1.nodeReactionLoad[i][currentLoad][3])*i);
      line(-20+40*i, b1.nodeReactionLoad[i][currentLoad][3]-2*b1.nodeReactionLoad[i][currentLoad][3]*i, -23+46*i, b1.nodeReactionLoad[i][currentLoad][3]+3-(2*b1.nodeReactionLoad[i][currentLoad][3])*i);
    }
  }
  popMatrix(); stroke(0); strokeWeight(1);
}

public void drawReactionText(int i) {
  textFont(txt10); fill(greenDark);
  pushMatrix(); 
  translate(node[i].x, node[i].y); rotate(b1.slope);
  if (showAllLoads==true) {  // Drawing of total-load reaction arrow text
    // Draws horizontal reaction values
    if (b1.nodeReactionTotal[i][2]==0) {/* Do nothing */}
    else if (b1.nodeReactionTotal[i][2]>0) {
      pushMatrix(); 
      translate(b1.nodeReactionTotal[i][2]+10, 25); rotate(-b1.slope);
      text(PApplet.parseInt(b1.nodeReactionTotal[i][2])+" kN", 0, 0);
      popMatrix();
    } else if (b1.nodeReactionTotal[i][2]<0) {
      textAlign(RIGHT);
      pushMatrix();
      translate(b1.nodeReactionTotal[i][2]-10, 25); rotate(-b1.slope);
      text(PApplet.parseInt(b1.nodeReactionTotal[i][2])+" kN", 0, 0);
      popMatrix();
    }
    // Draws vertical reaction values
    if (b1.nodeReactionTotal[i][1]==0) {/* Do nothing */}
    else {
      textAlign(CENTER);
      pushMatrix(); 
      translate(0, 20+abs(b1.nodeReactionTotal[i][1])+10); rotate(-b1.slope);
      text(PApplet.parseInt(b1.nodeReactionTotal[i][1])+" kN", 0, 0);
      popMatrix();
    }    
    // Draws moment reactions values, i is used as a 0-1 switch
    if (b1.nodeReactionTotal[i][3]==0) {/* Do nothing */}
    else if (b1.nodeReactionTotal[i][3]>0) {
      textAlign(CENTER);
      pushMatrix(); 
      translate(-20+40*i, b1.nodeReactionTotal[i][3]+18+(-2*b1.nodeReactionTotal[i][3]-28)*i); rotate(-b1.slope);
      text(PApplet.parseInt(b1.nodeReactionTotal[i][3])+" kN\u00b7m", 0, 0);
      popMatrix();
    } else if (b1.nodeReactionTotal[i][3]<0) {
      textAlign(CENTER);
      pushMatrix();
      translate(-20+40*i, b1.nodeReactionTotal[i][3]-10+(-2*b1.nodeReactionTotal[i][3]+28)*i); rotate(-b1.slope);
      text(PApplet.parseInt(b1.nodeReactionTotal[i][3])+" kN\u00b7m", 0, 0);
      popMatrix();
    }
  } else {  // Drawing of single-load reaction arrow text
    // Draws horizontal reactions values
    if (b1.nodeReactionLoad[i][currentLoad][2]==0) {/* Do nothing */}
    else if (b1.nodeReactionLoad[i][currentLoad][2]>0) {
      pushMatrix();
      translate(b1.nodeReactionLoad[i][currentLoad][2]+10, 25); rotate(-b1.slope);
      text(PApplet.parseInt(b1.nodeReactionLoad[i][currentLoad][2])+" kN", 0, 0);
      popMatrix();
    } else if (b1.nodeReactionLoad[i][currentLoad][2]<0) {
      textAlign(RIGHT);
      pushMatrix();
      translate(b1.nodeReactionLoad[i][currentLoad][2]-10, 25); rotate(-b1.slope);
      text(PApplet.parseInt(b1.nodeReactionLoad[i][currentLoad][2])+" kN", 0, 0);
      popMatrix();
    }
    // Draws vertical reactions values
    if (b1.nodeReactionLoad[i][currentLoad][1]==0) {/* Do nothing */}
    else {
      textAlign(CENTER);
      pushMatrix();
      translate(0, 20+abs(b1.nodeReactionLoad[i][currentLoad][1])+10); rotate(-b1.slope);
      text(PApplet.parseInt(b1.nodeReactionLoad[i][currentLoad][1])+" kN", 0, 0);
      popMatrix();
    }
    // Draws moment reactions values, i is used as a 0-1 switch
    if (b1.nodeReactionLoad[i][currentLoad][3]==0) {/* Do nothing */}
    else if (b1.nodeReactionLoad[i][currentLoad][3]>0) {
      textAlign(CENTER);
      pushMatrix(); 
      translate(-20+40*i, b1.nodeReactionLoad[i][currentLoad][3]+18+(-2*b1.nodeReactionLoad[i][currentLoad][3]-28)*i); rotate(-b1.slope);
      text(PApplet.parseInt(b1.nodeReactionLoad[i][currentLoad][3])+" kN\u00b7m", 0, 0);
      popMatrix();
    } else if (b1.nodeReactionLoad[i][currentLoad][3]<0) {
      textAlign(CENTER);
      pushMatrix();
      translate(-20+40*i, b1.nodeReactionLoad[i][currentLoad][3]-10+(-2*b1.nodeReactionLoad[i][currentLoad][3]+28)*i); rotate(-b1.slope);
      text(PApplet.parseInt(b1.nodeReactionLoad[i][currentLoad][3])+" kN\u00b7m", 0, 0);
      popMatrix();
    }
  }    
  popMatrix();
  textFont(txt13); textAlign(LEFT); noFill(); stroke(0);
}

public void drawBeamDiagram(int kind) {  // Kind means: 0=Axial, 1=Shear, 2=Bending, 3=Deformed shape
  float dScale=1;
  switch(kind){
    case 0: stroke(greenDark); fill(greenLight); break;
    case 1: stroke(blueDark); fill(blueLight); break;
    case 2: stroke(redDark); fill(redLight); break;
    case 3: stroke(redBright); strokeWeight(2.5f); dScale=EIScale; break;
  }  
  pushMatrix();
  rotate(b1.slope);
  if (showAllLoads==true) {
    beginShape(); vertex(0, 0);
    for (int i=0; i<b1.beamRange; i++) {vertex(i, dScale*b1.beamDiagramTotal[i][kind]);}
    if (kind!=3) {vertex(b1.beamRange, 0);}
    endShape();
  } else {
    beginShape(); vertex(0, 0);
    for (int i=0; i<b1.beamRange; i++) {vertex(i, dScale*b1.beamDiagramLoad[i][currentLoad][kind]);}
    if (kind!=3) {vertex(b1.beamRange, 0);}
    endShape();    
  }
  popMatrix();
  strokeWeight(1); stroke(0); noFill();
}

public void drawBeamDiagramValues(int kind) {  // Kind means: 0=Axial, 1=Shear, 2=Bending, 3=Deformed shape
  String units=""; int textOffset; float dScale=1;
  switch(kind){
    case 0: fill(greenDark); units=" kN"; break;
    case 1: fill(blueDark); units=" kN"; break;
    case 2: fill(redDark); units=" kN\u00b7m"; break;
    case 3: fill(redBright); units=" mm"; dScale=EIScale; break;
  }  
  textFont(txt10); textAlign(CENTER);
  pushMatrix(); 
  rotate(b1.slope);
  if (showAllLoads==true) {
    for (int i=0; i<2; i++) {
      if (b1.topValueTotal[i][kind]<=0) {textOffset=-2;} else {textOffset=10;}
      pushMatrix();
      translate(b1.topIndexTotal[i][kind], dScale*b1.topValueTotal[i][kind]+textOffset);
      if (kind!=3) {if (PApplet.parseInt(b1.topValueTotal[i][kind])!=0) {text(PApplet.parseInt(b1.topValueTotal[i][kind])+units, 0, 0);}}
      else {if (b1.topValueTotal[i][kind]!=0) {text(nf(1000*b1.topValueTotal[i][kind], 0, 2)+units, 0, 0);}}
      popMatrix();
    }
  } else {
    for (int i=0; i<2; i++) {
      if (b1.topValueLoad[currentLoad][i][kind]<=0) {textOffset=-2;} else {textOffset=10;}
      pushMatrix();
      translate(b1.topIndexLoad[currentLoad][i][kind], dScale*b1.topValueLoad[currentLoad][i][kind]+textOffset);
      if (kind!=3) {if (PApplet.parseInt(b1.topValueLoad[currentLoad][i][kind])!=0) {text(PApplet.parseInt(b1.topValueLoad[currentLoad][i][kind])+units, 0, 0);}}
      else {if (b1.topValueLoad[currentLoad][i][kind]!=0) {text(nf(1000*b1.topValueLoad[currentLoad][i][kind], 0, 2)+units, 0, 0);}}
      popMatrix();
    }
  }
  popMatrix();
  textFont(txt13); textAlign(LEFT);
  strokeWeight(1); stroke(0); noFill();
}
  
class Highlight {  // A class to highlight active load or node
  float x, y, diameter;
  boolean on=false;
  
  public void start(float x_, float y_) {
    x=x_; y=y_; on=true; diameter=1;
  }
  
  public void display() {
    if (on==true) {
      diameter+=2;
      strokeWeight(2); stroke(150, 0, 0, map(diameter, 0, 50, 255, 100));
      ellipse (x, y, diameter, diameter);
      stroke(0); strokeWeight(1);
      if (diameter>50) {on=false;}
    }
  }
  
}
// Keyboard action functions
// (they are moved to a different tab to be sepparated from their action key
// and be easily translated by substituting the _f_keyb_letters_ES.pde)

// CURSOR BEHAVIOUR - Is made a special function as it is the feature that is more customized
public void kbCursorModeLoadUp() {
  kbChangeLoadMagnitude(+1);
}
public void kbCursorModeLoadDown() {
  kbChangeLoadMagnitude(-1);
}
public void kbCursorModeLoadLeft() {
  kbChangeLoadRIPosition(-1); kbChangeLoadRFPosition(-1);
}
public void kbCursorModeLoadRight() {
  kbChangeLoadRIPosition(+1); kbChangeLoadRFPosition(+1);
}
public void kbCursorModeRotationUp() {
//  beamModeRotationAngleTemp=b1.slope-.01; b1.xf=b1.L*cos(beamModeRotationAngleTemp); b1.yf=b1.L*sin(beamModeRotationAngleTemp);
}
public void kbCursorModeRotationDown() {
//  beamModeRotationAngleTemp=b1.slope+.01; b1.xf=b1.L*cos(beamModeRotationAngleTemp); b1.yf=b1.L*sin(beamModeRotationAngleTemp);
}
public void kbCursorModeNodeUp() {
//  b1.yf-=2;
}
public void kbCursorModeNodeDown() {
//  b1.yf+=2;
}
public void kbCursorModeNodeLeft() {
//  if (b1.xf>b1.xi) {b1.xf-=2;}
}
public void kbCursorModeNodeRight() {
//  b1.xf+=2;
}
  
// ACTION FUNCTIONS - Are called for specific tasks
public void kbChangeLoadKind(char kind) {
//  load[currentLoad].kind=kind;
}
public void kbChangeLoadWidth(int sign) {
  if (cursorModeLoad==true) {load[currentLoad].rf+=sign*0.01f; load[currentLoad].ri-=sign*0.01f;}
}
public void kbChangeLoadMagnitude(int sign) {
  load[currentLoad].magnitude+=sign*1;
}
public void kbChangeLoadRIPosition(int sign) {
  load[currentLoad].ri+=sign*0.01f;
}
public void kbChangeLoadRFPosition(int sign) {
  load[currentLoad].rf+=sign*0.01f;
}
public void kbChangeEI(int sign) {
  EI+=sign*10;
}
public void kbChangeModeLoad(int toggle) {
//  if (toggle==0) { cursorModeLoad=false; highlight.start(node[currentNode].x, node[currentNode].y);
//  } else {
//    if (cursorModeLoad==false) {cursorModeLoad=true;} else {currentLoad+=1; if (currentLoad==activeLoads) {currentLoad=0;}}
//    highlight.start(load[currentLoad].xi, load[currentLoad].yi);
//  }
}
public void kbChangeDisplayDiagram(int kindN) {
  switch(kindN) {
    case 0: activateDiagramAxial=!activateDiagramAxial; break;
    case 1: activateDiagramShear=!activateDiagramShear; break;
    case 2: activateDiagramBending=!activateDiagramBending; break;
    case 3: activateDiagramDeformed=!activateDiagramDeformed; break;
  }
}
public void kbChangeDisplayLoads() {
  showAllLoads=!showAllLoads;
}
public void kbChangeDisplayValues() {
  showValues=!showValues;
}
public void kbChangeModeRotation() {
//  beamModeRotation=!beamModeRotation;
}
public void kbChangeBeam() {
//  if (node[0].kind=='R') {node[0].kind='F';} else {node[0].kind='R';}
//  if (node[1].kind=='N') {node[1].kind='S';} else {node[1].kind='N';}
}
public void kbPrint(int toggle) {
//  if (toggle==0) {save("screenshot.png");}
//  else {savePDF=true;}
}
public void kbChangeActiveLoads(int numb) {
//  activeLoads=numb; if (currentLoad>=activeLoads) {currentLoad=activeLoads-1;}
}

// Keyboard interaction functions

// Action keys
public void keyboardInteraction() {
  if (keyPressed==true) {
    switch(key) {
      case 'P': case 'p': kbChangeLoadKind('P'); break;
      case 'U': case 'u': kbChangeLoadKind('U'); break;
      case 'M': case 'm': kbChangeLoadKind('M'); break;
      case 'W': case 'w': kbChangeLoadWidth(+1); break;
      case 'S': case 's': kbChangeLoadWidth(-1); break; 
      case 'G': case 'g': kbChangeEI(+1); break;
      case 'B': case 'b': kbChangeEI(-1); break;
      case CODED:
        if (cursorModeLoad==true) {
          switch(keyCode) {
            case UP: kbCursorModeLoadUp(); break;
            case DOWN: kbCursorModeLoadDown(); break;
            case LEFT: kbCursorModeLoadLeft(); break;
            case RIGHT: kbCursorModeLoadRight(); break;
          }
        } else if (beamModeRotation==true) {
            switch(keyCode) {
              case UP: kbCursorModeRotationUp(); break;
              case DOWN: kbCursorModeRotationDown(); break;
            } 
        } else {
          switch(keyCode) {
            case UP: kbCursorModeNodeUp(); break;
            case DOWN: kbCursorModeNodeDown(); break;
            case LEFT: kbCursorModeNodeLeft(); break;
            case RIGHT: kbCursorModeNodeRight(); break;
          }
        }
      }
    // Contraints of relative position values for active loads (can't use a if.else structure because on uniform)
    for (int i=0; i<activeLoads; i++) { 
      if (load[i].ri>1) {load[i].ri=1;} else if (load[i].ri<0) {load[i].ri=0;}
      if (load[i].rf>1) {load[i].rf=1;} else if (load[i].rf<0) {load[i].rf=0;}
    }
    // All updating has been put together here to any keyStroke. Could be optimised... 
    updateAllCalculation();
  }
}

// Display keys
public void keyPressed() {    
  switch(key) {
    case 'Q': case 'q': kbChangeModeLoad(1); break;
    case 'N': case 'n': kbChangeModeLoad(0); break; 
    case 'A': case 'a': kbChangeDisplayDiagram(0); break;
    case 'C': case 'c': kbChangeDisplayDiagram(1); break;
    case 'F': case 'f': kbChangeDisplayDiagram(2); break;
    case 'D': case 'd': kbChangeDisplayDiagram(3); break;
    case 'T': case 't': kbChangeDisplayLoads(); break;
    case 'X': case 'x': kbChangeDisplayValues(); break;
    case 'R': case 'r': kbChangeModeRotation(); break;
    case 'V': case 'v': kbChangeBeam(); break;
    case 'I': case 'i': kbPrint(0); break;  // Save to PNG
    case 'K': case 'k': kbPrint(1); break;  // Save to PDF
    case '1': case '2': case '3': case '4': case '5': 
      String temp=Character.toString(key); kbChangeActiveLoads(PApplet.parseInt(temp)); break;
    case 'Z': case 'z': welcomeToggle=true; break;
    case CODED:
      switch(keyCode) {
        case KeyEvent.VK_F1: helpToggle=!helpToggle; break;
        case KeyEvent.VK_SHIFT: welcomeToggle=false; break;
      }        
  }
}
// Help text lines
String ha="TECLADO PARA EL MANEJO DE LA APLICACI\u00d3N\n\n";
String hb="              Q __ Selecciona la carga activa\n";
String hc="              CURSORES __ Desplaza y cambia la magnitud de la carga activa\n";
String hd="              W-S __ Aumenta/disminuye el ancho de la carga activa (para cargas uniformes)\n";  
String he="              P-U-M __ Cambia la carga activa a Puntual, Uniforme o Momento\n";
String hf="              T __ Activa/desactiva la visualizaci\u00f3n de todas las cargas\n";
String hg="              X __ Activa/desactiva la visualizaci\u00f3n de valores\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
String hh="              N __ Selecciona el nodo activo\n";
String hi="              CURSORES __ Desplaza el nodo activo\n";
String hj="              V __ Cambia los v\u00ednculos de la viga\n";
String hk="              R __ Activa/desactiva modo rotaci\u00f3n de la viga\n";
String hl="              A-C-F-D __ Activa/desactiva los diagramas de Axiles, Cortante, Flector y Deformada\n";
String hm="              G-B __ Aumenta/disminuye EI\n\n";
String hn="              F1 __  Activa/desactiva el menu de ayuda\n";
//String ho="              I __  Imprime pantalla a archivo PNG (desactivado en modo web)\n";
//String hp="              K __  Imprime pantalla a archivo PDF (desactivado en modo web)\n";
String hq="CARGAS:\n";
String hr="VIGA:\n";
String hs="              1/5 __ Selecciona n\u00famero de cargas\n";
String ht="              Z __  Pantalla de bienvenida\n";
String hu="Versi\u00f3n 2.0";

public void displayHelp() {
  fill(230, 100); noStroke(); rect(210, 10, 781, 581); stroke(0);
  pushMatrix();  // (it has to come from 0,0 reference)
  translate(220, 10);  // Help text anchor point
  fill(0); textFont(txt10); textLeading(11);
  text(hr+hh+hi+hk+hj+hl+hm+hq+hs+hb+hc+hd+he+hf+hg+hn+ht, 0, 20);
  textAlign(RIGHT); text(hu, 740, 550); textAlign(LEFT);
  noFill(); textFont(txt13);
  popMatrix();
}

public void displayWelcomeScreen() {
  fill(255); noStroke(); rect(0, 0, width, height);
  stroke(0); noFill();
  pushMatrix();
  translate(width/2, 80);
  fill(0); textAlign(CENTER); 
  image(imgIntro, 0, 140); image(imgLogoUS, 0, 430);
  textFont(txt16); text("KILO", 0, 0);
  fill(redDark); text("PRONTUARIO INTERACTIVO DE ESTRUCTURAS", 0, 20);
  fill(0); textFont(txt10);
  text("Escuela T\u00e9cnica Superior de Arquitectura, Universidad de Sevilla", 0, 300);
  text("Departamento de Mec\u00e1nica de Medio Continuos, Teor\u00eda de Estructuras e Ingenier\u00eda del Terreno", 0, 310);
  text("Estructuras 1", 0, 320);
  text("Direcci\u00f3n: Enrique de Justo Moscard\u00f3", 0, 340);
  text("Programaci\u00f3n: Jose Luis Garc\u00eda del Castillo y L\u00f3pez", 0, 350);
  text("Contacto: info@garciadelcastillo.es", 0, 370);
  textFont(txt13); fill(redDark); text("Presione MAY\u00daSCULAS para continuar", 0, 500);
  popMatrix();
  textAlign(LEFT); textFont(txt13);
  noFill();
}

public void displayDataText() {
  fill(0); textFont(txt16); 
  text("KILO", 10, 26); line(10, 29, 200, 29);
  textFont(txt10); 
  text("Utilice el teclado para modificar", 10, 560);
  text("los elementos de la estructura", 10, 570);
  text("Presione F1 para ayuda", 10, 585);
  text("VIGA", 10, 50);
  text("Longitud = "+nf(b1.L/100, 0, 2)+" m", 10, 60);
  text("Inclinaci\u00f3n = "+nf(degrees(b1.slope), 0, 2)+"\u00ba", 10, 70);
  text("EI = "+PApplet.parseInt(EI)+" kN\u00b7m2", 10, 80);
  text("CARGA ACTUAL", 10, 100);
  text("Posici\u00f3n = "+nf(load[currentLoad].ri*b1.Lm, 0, 2)+" m", 10, 110); 
  switch(load[currentLoad].kindN){
    case 0: text("Valor = "+PApplet.parseInt(load[currentLoad].magnitudeY)+" kN", 10, 120); break;
    case 1: text("Valor = "+PApplet.parseInt(load[currentLoad].magnitude)+" kN\u00b7m", 10, 120); break;
    case 2: text("Valor = "+PApplet.parseInt(load[currentLoad].magnitudeY)+" kN/m (ancho "+nf((load[currentLoad].rf-load[currentLoad].ri)*b1.Lm, 0, 2)+" m)", 10, 120); break;
  }
  text("REACCIONES", 10, 140);
  if (showAllLoads==true) {
    text("Rx1 = "+PApplet.parseInt(b1.nodeReactionTotal[0][2])+" kN", 10, 150); 
    text("Ry1 = "+PApplet.parseInt(b1.nodeReactionTotal[0][1])+" kN", 10, 160); 
    text("M1  = "+PApplet.parseInt(b1.nodeReactionTotal[0][3])+" kN\u00b7m", 10, 170);
    text("Rx2 = "+PApplet.parseInt(b1.nodeReactionTotal[1][2])+" kN", 100, 150); 
    text("Ry2 = "+PApplet.parseInt(b1.nodeReactionTotal[1][1])+" kN", 100, 160); 
    text("M2  = "+PApplet.parseInt(b1.nodeReactionTotal[1][3])+" kN\u00b7m", 100, 170); 
  } else {
    text("Rx1 = "+PApplet.parseInt(b1.nodeReactionLoad[0][currentLoad][2])+" kN", 10, 150); 
    text("Ry1 = "+PApplet.parseInt(b1.nodeReactionLoad[0][currentLoad][1])+" kN", 10, 160);
    text("M1  = "+PApplet.parseInt(b1.nodeReactionLoad[0][currentLoad][3])+" kN\u00b7m", 10, 170);
    text("Rx2 = "+PApplet.parseInt(b1.nodeReactionLoad[1][currentLoad][2])+" kN", 100, 150); 
    text("Ry2 = "+PApplet.parseInt(b1.nodeReactionLoad[1][currentLoad][1])+" kN", 100, 160);
    text("M2  = "+PApplet.parseInt(b1.nodeReactionLoad[1][currentLoad][3])+" kN\u00b7m", 100, 170);
  }
  fill(greenDark); text("LEY DE AXILES", 10, 190);
  if (showAllLoads==true) {
    text("Valor m\u00edn. = "+PApplet.parseInt(b1.topValueTotal[0][0])+" kN (en "+nf(b1.topIndexTotal[0][0]*0.01f, 0, 2)+" m)", 10, 200);
    text("Valor m\u00e1x. = "+PApplet.parseInt(b1.topValueTotal[1][0])+" kN (en "+nf(b1.topIndexTotal[1][0]*0.01f, 0, 2)+" m)", 10, 210);
  } else {
    text("Valor m\u00edn. = "+PApplet.parseInt(b1.topValueLoad[currentLoad][0][0])+" kN (en "+nf(b1.topIndexLoad[currentLoad][0][0]*0.01f, 0, 2)+" m)", 10, 200);
    text("Valor m\u00e1x. = "+PApplet.parseInt(b1.topValueLoad[currentLoad][1][0])+" kN (en "+nf(b1.topIndexLoad[currentLoad][1][0]*0.01f, 0, 2)+" m)", 10, 210);
  }
  fill(blueDark); text("LEY DE CORTANTES", 10, 230);
  if (showAllLoads==true) {
    text("Valor m\u00edn. = "+PApplet.parseInt(b1.topValueTotal[0][1])+" kN (en "+nf(b1.topIndexTotal[0][1]*0.01f, 0, 2)+" m)", 10, 240);
    text("Valor m\u00e1x. = "+PApplet.parseInt(b1.topValueTotal[1][1])+" kN (en "+nf(b1.topIndexTotal[1][1]*0.01f, 0, 2)+" m)", 10, 250);
  } else {
    text("Valor m\u00edn. = "+PApplet.parseInt(b1.topValueLoad[currentLoad][0][1])+" kN (en "+nf(b1.topIndexLoad[currentLoad][0][1]*0.01f, 0, 2)+" m)", 10, 240);
    text("Valor m\u00e1x. = "+PApplet.parseInt(b1.topValueLoad[currentLoad][1][1])+" kN (en "+nf(b1.topIndexLoad[currentLoad][1][1]*0.01f, 0, 2)+" m)", 10, 250);
  }
  fill(redDark); text("LEY DE FLECTORES", 10, 270);
  if (showAllLoads==true) {
    text("Valor m\u00edn. = "+PApplet.parseInt(b1.topValueTotal[0][2])+" kN\u00b7m (en "+nf(b1.topIndexTotal[0][2]*0.01f, 0, 2)+" m)", 10, 280);
    text("Valor m\u00e1x. = "+PApplet.parseInt(b1.topValueTotal[1][2])+" kN\u00b7m (en "+nf(b1.topIndexTotal[1][2]*0.01f, 0, 2)+" m)", 10, 290);
  } else {
    text("Valor m\u00edn. = "+PApplet.parseInt(b1.topValueLoad[currentLoad][0][2])+" kN\u00b7m (en "+nf(b1.topIndexLoad[currentLoad][0][2]*0.01f, 0, 2)+" m)", 10, 280);
    text("Valor m\u00e1x. = "+PApplet.parseInt(b1.topValueLoad[currentLoad][1][2])+" kN\u00b7m (en "+nf(b1.topIndexLoad[currentLoad][1][2]*0.01f, 0, 2)+" m)", 10, 290);
  }
  fill(redBright); text("DEFORMADA", 10, 310);
  if (showAllLoads==true) {
    text("Valor m\u00edn. = "+nf(1000*b1.topValueTotal[0][3], 0, 2)+" mm (en "+nf(b1.topIndexTotal[0][3]*0.01f, 0, 2)+" m)", 10, 320);
    text("Valor m\u00e1x. = "+nf(1000*b1.topValueTotal[1][3], 0, 2)+" mm (en "+nf(b1.topIndexTotal[1][3]*0.01f, 0, 2)+" m)", 10, 330);
  } else {
    text("Valor m\u00edn. = "+nf(1000*b1.topValueLoad[currentLoad][0][3], 0, 2)+" mm (en "+nf(b1.topIndexLoad[currentLoad][0][3]*0.01f, 0, 2)+" m)", 10, 320);
    text("Valor m\u00e1x. = "+nf(1000*b1.topValueLoad[currentLoad][1][3], 0, 2)+" mm (en "+nf(b1.topIndexLoad[currentLoad][1][3]*0.01f, 0, 2)+" m)", 10, 330);
  }
  noFill(); textFont(txt13);
}

public void updateAllCalculation() {
  // Remember to consider introducing calculation in the initial sketch setup
  b1.update();
  for (int i=0; i<activeLoads; i++) {load[i].update();}
  for (int i=0; i<numberOfNodes; i++) {node[i].update();}
  switch(b1.nodeCombCase) {
    case 0: case 1: case 3: case 6: 
      eraseAllCalculation();
      break;
    case 2: case 4: case 7: case 8: case 10: case 14:
      b1.calcNodesReactions(); 
      b1.calcBeamDiagramSetup();
      if (activateDiagramAxial==true) {b1.calcBeamDiagramAxial();}
      if (activateDiagramShear==true) {b1.calcBeamDiagramShear();}
      if (activateDiagramBending==true) {b1.calcBeamDiagramBending();}
      if (activateDiagramDeformed==true) {b1.calcBeamDiagramDeformed();}
      break;
  }
}

public void eraseAllCalculation() {
  // Erase node reactions
  for (int i=0; i<numberOfNodes; i++) {
    for (int k=0; k<4; k++) {b1.nodeReactionTotal[i][k]=0;}
    for (int j=0; j<numberOfLoads; j++) {
      for (int k=0; k<4; k++) {b1.nodeReactionLoad[i][j][k]=0;}
    }
  }
  // Erase beam forces
  b1.calcBeamDiagramSetup();  // To update beamRange
  for (int i=0; i<b1.beamRange; i++) {
    for (int k=0; k<4; k++) {b1.beamDiagramTotal[i][k]=0;}
    for (int j=0; j<numberOfLoads; j++) {
      for (int k=0; k<4; k++) {b1.beamDiagramLoad[i][j][k]=0;}
    }
  }   
    
}
  
  

  static public void main(String args[]) {
    PApplet.main(new String[] { "--present", "--bgcolor=#666666", "--stop-color=#cccccc", "ap06" });
  }
}
