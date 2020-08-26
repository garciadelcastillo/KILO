// KILO v2.0 - INTERACTIVE STRUCTURAL ANALYSIS TOOL
//
// Project developed by Enrique de Justo Moscardó and Jose Luis García del Castillo y López (Universidad de Sevilla)
// This work is licensed under a Creative Commons Attribution-ShareAlike 3.0 Unported License
// Inquiries and feedback: info@garciadelcastillo.es

// Libraries
PFont txt10, txt13, txt16;
PImage imgIntro, imgLogoUS;
//import processing.pdf.*;

// Declare objects
Node[] node;
Beam b1;
Load[] load;

// Declare sketch vars
Highlight highlight;
boolean helpToggle=false; 
boolean welcomeToggle=true;
boolean showAllLoads=true; 
boolean showValues=true; 
boolean activateDiagramAxial=true; 
boolean activateDiagramShear=true; 
boolean activateDiagramBending=true; 
boolean activateDiagramDeformed=true;
boolean activateDiagramLoads=true;
boolean flipDiagramBending = false;
boolean cursorModeLoad=true; 
boolean beamModeRotation=false; 
float beamModeRotationAngleTemp;
boolean savePDF=false;
int numberOfNodes, numberOfBeams, numberOfLoads, activeLoads=1;
int currentNode=1; 
int currentLoad=0; 
color redDark=color(100, 0, 0); 
color redLight=color(200, 0, 0, 100); 
color redBright=color(255, 0, 0);
color greenDark=color(0, 100, 0); 
color greenLight=color(0, 200, 0, 100);
color blueDark=color(0, 0, 100); 
color blueLight=color(0, 0, 200, 100);
float EI, EIScale;

void setup() {
  size(1000, 600);
  smooth(); 
  stroke(0); 
  strokeWeight(1); 
  noFill(); 
  ellipseMode(CENTER); 
  imageMode(CENTER);
  // WARNING: remember to optimize createFont to loadFont functions when preparing applet for WEB
  //  txt16=createFont("Arial", 16); txt13=createFont("Arial", 13); txt10=createFont("Arial", 10);
  txt16=loadFont("ArialMT-16.vlw"); 
  txt13=loadFont("ArialMT-13.vlw"); 
  txt10=loadFont("ArialMT-10.vlw");
  imgIntro=loadImage("intro.png"); 
  //imgLogoUS=loadImage("logous.png");

  // NUMBER OF OBJECTS IN SKETCH
  numberOfNodes=2; // applet only works for 2
  numberOfBeams=1; // still useless
  numberOfLoads=5;
  EI=4080.0;  // EI in kN·m2. Ex: EI(for a steel IPE-200)=4080
  EIScale=1000.0;  // Representation scale for deformed beams

  // Construct objects
  node=new Node[numberOfNodes];
  load=new Load[numberOfLoads];

  // ASSIGN INITIAL STRUCTURAL VARS
  b1=new Beam(0, 0, 400, 0);
  node[0]=new Node('R', 0.00);  // created with relative position to the beam
  node[1]=new Node('S', 1.00);  // id.
  load[0]=new Load('P', 0.50, 0.75, 100);
  load[1]=new Load('P', 0.75, 1.00, 50);
  load[2]=new Load('P', 0.25, 0.50, 50);
  load[3]=new Load('M', 0.00, 0.80, 50);
  load[4]=new Load('M', 1.00, 0.80, -50);

  // Initial sketch setup
  highlight=new Highlight();
  b1.update();
  b1.calcNodeReactionSetup();
  for (int i=0; i<activeLoads; i++) {
    load[i].update();
  }
  for (int i=0; i<numberOfNodes; i++) {
    node[i].update();
  }
  b1.calcNodesReactions();
  b1.calcBeamDiagramSetup();
  b1.calcBeamDiagramAxial();
  b1.calcBeamDiagramShear();
  b1.calcBeamDiagramBending();
  b1.calcBeamDiagramDeformed();
  updateAllCalculation();
}

void draw() {
  //  if (savePDF==true) {beginRecord(PDF, "screenshot.pdf");}
  background(235);
  fill(255); 
  rect(210, 10, 780, 580);
  textFont(txt13);
  keyboardInteraction();  // Calls the listen to keyboard function

  // Call to classes
  pushMatrix();
  translate(100+width/2-(b1.xf-b1.xi)/2, height/2-(b1.yf-b1.yi)/2); 
  b1.display();
  for (int i=0; i<numberOfNodes; i++) {
    node[i].display();
  }
  if (activateDiagramAxial==true) {
    b1.displayBeamDiagramAxial();
  }
  if (activateDiagramShear==true) {
    b1.displayBeamDiagramShear();
  }
  if (activateDiagramBending==true) {
    b1.displayBeamDiagramBending();
  }
  if (activateDiagramDeformed==true) {
    b1.displayBeamDiagramDeformed();
  }
  if (activateDiagramLoads) {
    if (showAllLoads==false) {
      load[currentLoad].display();
    } else {
      for (int i=0; i<activeLoads; i++) {
        load[i].display();
      }
    }
    b1.displayNodesReactions();
  }
  highlight.display();
  popMatrix();

  displayDataText();  // Displays the left column data text
  if (welcomeToggle==true) {
    displayWelcomeScreen();
  }
  if (helpToggle==true) {
    displayHelp();
  }
  noFill();

  if (savePDF==true) {
    endRecord(); 
    savePDF=false;
  }  
}
