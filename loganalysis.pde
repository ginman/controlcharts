// ******************************************************************************************
// Loganalysis Control Chart Software
// Designed by Peter Perreault
//
// The basic functionality of this code is to crawl through a directory structure of logs 
// and import data from text files. Control charts are then generated based on this data, 
// with upper and lower warning limits that are based on the standard deviation of the 
// entire data set.
//
// Things to change:
//  * Make timing constant a variable
// ******************************************************************************************


// ******************************************************************************************
// Global Variables
// ******************************************************************************************
int windowsize = 500;
int fontsize = 14;
int drawtag = 1;    
float yaxislocation = 0.05*windowsize;
float xaxislocation = 0.05*windowsize+25;
float axisscale = windowsize - 2*0.05*windowsize;
int sidebarMargin;
int buttony;
float[] inputArray;
int numPoints = 10;
int maxPoints = 5000;

//String currentTab = "peak";
String movementtype = "normal";

String[] logfile;
String[] logwaveform;
String[] logfiletemp;
String[] timestamp;
String[] datestamp;
String directory;
String filename = "/N48AC.TXT";
String url = "http://172.28.64.54/";  

// variables for point highlighting
int pointhighlight = -1; // index to be highlighted
float[] xpoints = new float[maxPoints]; // pixel location of each plotted point on the current chart
float[] ypoints = new float[maxPoints]; //


boolean updatebuttonpressed = false;
boolean locked = false;
RectButton updateButton; 
RectButton peakTab;
RectButton avgTab;
RectButton platlenTab;
RectButton platavgTab;
RectButton currentView;
RectButton view5;
RectButton view10;
RectButton view20;
RectButton view50;
RectButton viewAll;
RectButton direction;

class Button{
  int q,r;
  int buttonHeight;
  int buttonWidth;
  String buttonText;
  color basecolor, highlightcolor, alarmcolor;
  color currentcolor;
  boolean over = false;
  boolean pressed = false;
  boolean alarm = false;
  boolean focus = false;
  int lastViewNumber;
  
  void update(){
    
    if(alarm){
      currentcolor = alarmcolor;
      if(overRect(q,r,buttonWidth, buttonHeight)){
      currentcolor = highlightcolor;
      }
    }
    else if(overRect(q,r,buttonWidth, buttonHeight)){
      currentcolor = highlightcolor;
    } 
    
    else{
    currentcolor = basecolor;
    }
    if(focus){
      currentcolor = highlightcolor;
    }
  }
  
  boolean pressed(){
    if(overRect(q,r,buttonWidth, buttonHeight)){
      locked = true;
      return true;
    }
    else{
      locked = false;
      return false;
    }
  }
  
  boolean over(){
    return true;
  }
  
  boolean overRect(int q, int r, int buttonWidth, int buttonHeight){
    if(mouseX >= q && mouseX <= q + buttonWidth && mouseY >= r && mouseY <= r+buttonHeight){
      return true;
    }
    else{
      return false;
    }
  }
}
class RectButton extends Button
{
  RectButton(int ix, int iy, int iwidth, int iheight, color icolor, color ihighlight, color ialarm, String ibuttonText) 
  {
    q = ix; // q and r are the top left corner of the button
    r = iy;
    buttonText = ibuttonText;
    buttonWidth = iwidth;
    buttonHeight = iheight;
    basecolor = icolor;
    alarmcolor = ialarm;
    highlightcolor = ihighlight;
    currentcolor = basecolor;
  }

  boolean over() 
  {
    if( overRect(q, r, buttonWidth, buttonHeight) ) {
      over = true;
      return true;
    } 
    else {
      over = false;
      return false;
    }
  }

  void display() 
  {
    stroke(0);
    fill(currentcolor);
    rect(q, r, buttonWidth, buttonHeight);
    fill(255);
    text(buttonText, q + 5, r + .75*buttonHeight);
  }
}      


// ******************************************************************************************
// Global Functions
// ******************************************************************************************
      
void update(int q, int r, float[] ixpoints, float[] iypoints) // takes in mouse inputs
{
  
  
  if(locked == false) {
    waveform.update();
    direction.update();
    updateButton.update();
    peakTab.update();
    avgTab.update();
    platlenTab.update();
    platavgTab.update();
    view5.update();
    view10.update();
    view20.update();
    view50.update();
    viewAll.update();
  } 
  else {
    locked = false;
  }

  if(mousePressed) { 
      if(ixpoints[0] != 0.0){
        
      // change the focus to the correct tab, turn off the alarm for that tab
      // and redraw the chart. Or change the number of points being plotted
      float[] xdiff = new float[numPoints]; // difference between mouseX and xpoints
      float[] ydiff = new float[numPoints];
      float[] mindist = new float[numPoints];
      float[] xpoints = new float[numPoints];
      xpoints = ixpoints;
      
      for(int index = 0; index < numPoints; index++){
        //println(xpoints[index]);
        xdiff[index] = abs(q - xpoints[index]);  
        ydiff[index] = abs(r - iypoints[index]); 
        mindist[index] = xdiff[index] + ydiff[index];
      }
      //println(xdiff);
      if(minVal(mindist) <= 5){
        pointhighlight = minIndex(mindist);
        //drawtag = 1;
        plot();
      }
    }
    
    if(updateButton.pressed()) {
      updatebuttonpressed = true;
      peakTab.alarm = false;
      avgTab.alarm = false;
      platlenTab.alarm = false;
      platavgTab.alarm = false;
      //drawtag = 1;
      println("Reloading log files");
      importData();
      plot();
      //pointhighlight = -1;
    } 
    if(direction.pressed()) {
      //drawtag = 1;
      if(direction.buttonText == "Normal"){
        direction.buttonText = "Reverse";
        filename = "/R48AC.TXT";
      }
      else{
        direction.buttonText = "Normal";
        filename = "/N48AC.TXT";
      }
      println("Now displaying " + direction.buttonText + " movements.");
      direction.display();
      importData();
      plot();
    } 
    if(waveform.pressed()){
      println(trim(datestamp[pointhighlight]));
      println(trim(timestamp[pointhighlight]));
      timestamptemp = trim(timestamp[pointhighlight]);
      timestamptemp = timestamptemp.substring(0,2) + timestamptemp.substring(3,5) + timestamptemp.substring(6,8);
      logwaveform = loadStrings("logs/perry/" + trim(datestamp[pointhighlight]) + "/SW48A/" + timestamptemp + "N.TXT"); 
      plot();
    }
    if(peakTab.pressed()){
      peakTab.focus = true;
      avgTab.focus = false;
      platlenTab.focus = false;
      platavgTab.focus = false;
      currentView = peakTab;
      //drawtag = 1;
      plot();
      peakTab.alarm = false;
    }
    if(avgTab.pressed()){
      peakTab.focus = false;
      avgTab.focus = true;
      platlenTab.focus = false;
      platavgTab.focus = false;
      currentView = avgTab;
      //drawtag = 1;
      plot();
      avgTab.alarm = false;
    }
    if(platlenTab.pressed()){
      peakTab.focus = false;
      avgTab.focus = false;
      platlenTab.focus = true;
      platavgTab.focus = false;
      currentView = platlenTab;
      //drawtag = 1;
      plot();
      platlenTab.alarm = false;
    }
    if(platavgTab.pressed()){
      platavgTab.focus = true;
      peakTab.focus = false;
      avgTab.focus = false;
      platlenTab.focus = false;
      
      currentView = platavgTab;
      //drawtag = 1;
      plot();
      platavgTab.alarm = false;
    }
    if(view5.pressed()){
      numPoints = 5;
      //drawtag = 1;
      plot();
      view5.alarm = true;
      view10.alarm = false;
      view20.alarm = false;
      view50.alarm = false;
      viewAll.alarm = false;
    }
    if(view10.pressed()){
      numPoints = 10;
      //drawtag = 1;
      plot();
      view10.alarm = true;
      view5.alarm = false;
      view20.alarm = false;
      view50.alarm = false;
      viewAll.alarm = false;
    }
    if(view20.pressed()){
      numPoints = 20;
      //drawtag = 1;
      plot();
      view20.alarm = true;
      view5.alarm = false;
      view10.alarm = false;
      view50.alarm = false;
      viewAll.alarm = false;
    }
     if(view50.pressed()){
      numPoints = 50;
      //drawtag = 1;
      plot();
      view50.alarm = true;
      view5.alarm = false;
      view10.alarm = false;
      view20.alarm = false;
      viewAll.alarm = false;
    }
     if(viewAll.pressed()){
      numPoints = 2000;
      //drawtag = 1;
      plot();
      viewAll.alarm = true;
      view5.alarm = false;
      view10.alarm = false;
      view50.alarm = false;
      view20.alarm = false;
    }
  }
}      

void importData(){
    String[] foldernames = loadStrings("foldernames.txt");
//    directory = url + "logs/perry/" + foldernames[0] + "/SW48A" + filename;
    directory = "logs/perry/" + foldernames[0] + "/SW48A" + filename;
    logfile = loadStrings(directory);
    
    for (int j = 0; j < logfile.length; j++){
      logfile[j] = concat(foldernames[0] + ", ", logfile[j]);
    }
    
    for (int index = 1; index < foldernames.length; index++){
      
      directory = "logs/perry/" + foldernames[index] + "/SW48A" + filename;

      logfiletemp = loadStrings(directory);
      //println(logfiletemp[0]);
      
      
      for (int j = 0; j < logfiletemp.length; j++){
        logfiletemp[j] = concat(foldernames[index] + ", ", logfiletemp[j]);
      }
      
      if (logfiletemp==null){
        println("No templog file found");
      }
      else{
        //splice(logfile,logfiletemp, 0);
        
        logfile = concat(logfile,logfiletemp);
        //println(logfile);
       
      }
    }
  
    println("Imported " + logfile.length + " switch movement data logs from " + foldernames[0] + " to " + foldernames[foldernames.length - 1]);
  
}



// ******************************************************************************************
// Setup
// ******************************************************************************************

void setup(){
  size(650, 500, JAVA2D);
  PFont f;
  f = loadFont("Dialog.plain-48.vlw");
  textFont(f,fontsize);
  
  // Set the colors for the tabs
  color buttoncolor = color(153);
  color highlight = color(100);
  color alarmcolor = color(185, 0, 0);
  
  sidebarMargin = (int)round(1.5*xaxislocation + axisscale); 
  buttony = (int)round(yaxislocation);
  int tabwidth = 3*buttony; // set the width of the top tabs

  
  // Create the buttons
  // RectButton(x, y, width, height, default c, highlight c, alarm c, text)
  updateButton = new RectButton(sidebarMargin, buttony, 3*buttony, buttony, buttoncolor, highlight, alarmcolor, "Update"); 
  peakTab = new RectButton(round(xaxislocation), 0, tabwidth, buttony, buttoncolor, highlight, alarmcolor, "Peak");
  avgTab = new RectButton(round(xaxislocation)+tabwidth, 0 , tabwidth, buttony, buttoncolor, highlight, alarmcolor, "Average");
  platlenTab = new RectButton(round(xaxislocation)+2*tabwidth, 0 , round(1.5*tabwidth), buttony, buttoncolor, highlight, alarmcolor, "Plateau Time");
  platavgTab = new RectButton(round(xaxislocation)+2*tabwidth+round(1.5*tabwidth), 0 , round(1.5*tabwidth), buttony, buttoncolor, highlight, alarmcolor, "Plateau Avg");
  view5 = new RectButton(sidebarMargin, height - buttony, buttony, buttony, buttoncolor, highlight, highlight, " 5");
  view10 = new RectButton(sidebarMargin + buttony, height - buttony, buttony, buttony, buttoncolor, highlight, highlight, "10");
  view20 = new RectButton(sidebarMargin + 2*buttony, height - buttony, buttony, buttony, buttoncolor, highlight, highlight, "20");
  view50 = new RectButton(sidebarMargin + 3*buttony, height - buttony, buttony, buttony, buttoncolor, highlight, highlight, "50");
  viewAll = new RectButton(sidebarMargin + 4*buttony, height - buttony, buttony, buttony, buttoncolor, highlight, highlight, "All");
  direction = new RectButton(round(xaxislocation), height-buttony, 3*buttony, buttony, buttoncolor, highlight, alarmcolor, "Normal");
  waveform = new RectButton(sidebarMargin, buttony*6.5, 3*buttony, buttony, buttoncolor, highlight, alarmcolor, "Waveform");
  numPoints = 5000;
  viewAll.alarm = true;
  if(currentView == null){
    currentView = peakTab;
  }
  importData();
  plot();
  // IMPORT DATA FROM THE LOG FILES
    
//    // import the data from the log file
//    String dirtest = dataPath("");
//    println(dirtest);
    
//    println(dataPath("/home/ginman/Processing/loganalysis/data/logs/perry"));
    
//    File dir = new File(dataPath("/home/ginman/Processing/loganalysis/data/logs/perry"));


//    File dir = new File("/var/www/logs/perry");
//    String[] foldernames = dir.list();
    
    /*
    String[] foldernames = loadStrings("foldernames.txt");
 
    //String[] foldernames = splitTokens(foldernames2);

//    directory = url + "logs/perry/" + foldernames[0] + "/SW48A" + filename;
    directory = "logs/perry/" + foldernames[0] + "/SW48A" + filename;
    logfile = loadStrings(directory);
    
    for (int j = 0; j < logfile.length; j++){
      logfile[j] = concat(foldernames[0] + ", ", logfile[j]);
    }
    
    for (int index = 1; index < foldernames.length -1; index++){
      
      directory = "logs/perry/" + foldernames[index] + "/SW48A" + filename;

      logfiletemp = loadStrings(directory);
      //println(logfiletemp[0]);
      
      
      for (int j = 0; j < logfiletemp.length; j++){
        logfiletemp[j] = concat(foldernames[index] + ", ", logfiletemp[j]);
      }
      
      if (logfiletemp==null){
        println("No templog file found");
      }
      else{
        //splice(logfile,logfiletemp, 0);
        
        logfile = concat(logfile,logfiletemp);
        //println(logfile);
       
      }
    }
  
    println("Imported " + logfile.length + " switch movement data logs from " + foldernames[0] + " to " + foldernames[foldernames.length -2]);
    println(currentView.buttonText);
    */
}


// ******************************************************************************************
// Draw
// ******************************************************************************************
void draw(){
  
//  float[] xpoints = new float[numPoints];
//  float[] ypoints = new float[numPoints];
  
//  update(mouseX, mouseY);
  updateButton.display(); // draw buttons and text
  peakTab.display();
  avgTab.display();
  platlenTab.display();
  platavgTab.display();
  
  view5.display();
  view10.display();
  view20.display();
  view50.display();
  viewAll.display();
  direction.display();
  
  if(pointhighlight != -1){
    waveform.display();
  }
  
  update(mouseX, mouseY, xpoints, ypoints);
  //plot();
} 

void plot(){
    //  if(drawtag == 1){
    
    //currentView.currentcolor = highlightcolor;
    
    //float[] xpoints = new float[numPoints];
    //float[] ypoints = new float[numPoints];
    
    fill(200);
    stroke(200);
    // color over the non-tab parts of the window
    rect(0,yaxislocation,width,height-yaxislocation);
    rect(0,0,xaxislocation-1,yaxislocation);
    
    int loglength = logfile.length;
    int[] data = new int[loglength];
    String[] timestamptemp = new String[loglength];
    String[] datestamptemp = new String[loglength];
    timestamp = timestamptemp;
    datestamp = datestamptemp;
    float[] platavg = new float[loglength];
    float[] peak = new float[loglength];
    float[] plattime = new float[loglength];
    float[] avg = new float[loglength];
    
    // split the logfile into separate arrays
    for (int index = 0; index < logfile.length; index++) {
      String[] currentlog = split(logfile[index],',');
      datestamp[index]= currentlog[0];
      timestamp[index] = currentlog[1];
      platavg[index] = float(currentlog[5]);
      peak[index] = float(currentlog[2]);
      plattime[index] = 0.02*float(currentlog[4]);
      avg[index] = float(currentlog[3]);
    }
      
  fill(255);
  stroke(0);
  // draw the graph outline
  rect(xaxislocation,yaxislocation,height - 2*0.05*height,height - 2*0.05*height);
  
  numPoints = min(numPoints, logfile.length);
  
  float[] inputArray = new float[numPoints];
  float[] graphArray = new float[numPoints];
  
  // find if an alarm must be set
  peakTab.alarm = alarmFunction(peak, peakTab.lastViewNumber);
  avgTab.alarm = alarmFunction(avg, avgTab.lastViewNumber);
  platlenTab.alarm = alarmFunction(plattime, platlenTab.lastViewNumber);
  platavgTab.alarm = alarmFunction(platavg, platavgTab.lastViewNumber);
  
  currentView.lastViewNumber = numPoints;
  
  // copy the correct array to be plotted
   if(currentView == peakTab ){
      arrayCopy(peak, peak.length - numPoints, graphArray, 0, numPoints);
      inputArray = peak;
    }
    
   if(currentView == avgTab){
      arrayCopy(avg, avg.length - numPoints, graphArray, 0, numPoints);
      inputArray = avg;
        
   }
   if(currentView == platlenTab){
     arrayCopy(plattime, plattime.length - numPoints, graphArray, 0, numPoints);
     inputArray = plattime;
    }
   if(currentView == platavgTab){
     arrayCopy(platavg, platavg.length - numPoints, graphArray, 0, numPoints);
     inputArray = platavg;
     platavgTab.alarm = false;
    }
  
  float average = findAvg(inputArray);
  float standardDeviation = findSD(inputArray, average);
  float upperWarnValue = average+2*standardDeviation;
  float lowerWarnValue = average-2*standardDeviation;
  
  // find the max value in the array to calibrate the axis
  float arrayMax = maxVal(graphArray);
  float arrayMin = minVal(graphArray);
  
  // if the warning lines are outside the range of the graph, rework the range to include the warning lines
  float yaxismin = min(arrayMin,lowerWarnValue);
  float yaxismax = max(arrayMax,upperWarnValue);
  float range = yaxismax - yaxismin;
  int divisions = 10;
  float divlen = axisscale/divisions; 
  float divlenValue = range/divisions;
  yaxismin = yaxismin - divlenValue;
  yaxismax = yaxismax + divlenValue; 
  range = yaxismax - yaxismin;
  float xaxisdiv = axisscale/graphArray.length;
  
  fill(0);
  int offset = 0;
  if (range < 3){ // for a smaller range do not find the integers
  
    // create and plot the yaxis divisions
    for(int index = 0; index <= divisions; index++){
      float divpoint = yaxislocation + index*divlen;
      line(xaxislocation - 4, divpoint, xaxislocation + axisscale, divpoint);
      
      //plot the y axis grid line
      stroke(200);
      line(xaxislocation + 4, divpoint, xaxislocation + axisscale, divpoint);
      stroke(0);
      /*
      // plot the 1/4 marks
      line(xaxislocation - 2, divpoint-divlen/4, xaxislocation + 2, divpoint-divlen/4);
      line(xaxislocation - 2, divpoint+divlen/4, xaxislocation + 2, divpoint+divlen/4);
      //plot the 1/2 mark
      line(xaxislocation - 3, divpoint+divlen/2, xaxislocation + 3, divpoint+divlen/2);
      */
     
      if( yaxismax - index > 10){
        offset = 32;
      }
      else{
        offset = 45;
      }
      text(yaxismax - index*range/divisions, xaxislocation - offset, yaxislocation + index*divlen + fontsize/2);
      
      //
    }
  }
  else{ // for large ranges only plot integer valued marks on the axis
    // create and plot the yaxis divisions
    int yaxisintmax = floor(yaxismax);
    int yaxisintmin = ceil(yaxismin);
    int rangeint = yaxisintmax - yaxisintmin;
    float divlenint = (axisscale-(yaxismax - yaxisintmax + yaxisintmin - yaxismin))/range;
    for(int index = 0; index <= rangeint; index++){
      float divpoint = yaxislocation + index*divlenint + (yaxismax - yaxisintmax)*(height-2*yaxislocation)/range;
      // plot the mark at integer
      line(xaxislocation - 4, divpoint, xaxislocation + 4, divpoint);
      //plot the y axis grid line
      stroke(200);
      line(xaxislocation + 4, divpoint, xaxislocation + axisscale, divpoint);
      stroke(0);
      // plot the 1/4 marks
      if(divpoint-divlenint/4 > yaxislocation && divpoint-divlenint/4 < height - yaxislocation){
      line(xaxislocation - 2, divpoint-divlenint/4, xaxislocation + 2, divpoint-divlenint/4);
      }
      if(divpoint+divlenint/4 > yaxislocation && divpoint+divlenint/4 < height - yaxislocation){
      line(xaxislocation - 2, divpoint+divlenint/4, xaxislocation + 2, divpoint+divlenint/4);
      }
      //plot the 1/2 mark
      if(divpoint+divlenint/2 > yaxislocation && divpoint+divlenint/2 < height - yaxislocation){
      line(xaxislocation - 3, divpoint+divlenint/2, xaxislocation + 3, divpoint+divlenint/2);
      }
      //plot the mark label
      
      if( yaxismax - index*range/divisions >= 10){
        offset = 25;
      }
      else{
        offset = 15;
      }
      text(yaxisintmax - index, xaxislocation - offset, divpoint + fontsize/2);
    }
  }
  
  
  // plot the running average line
  float averageYPoint = height - axisscale*(average - yaxismin)/range-yaxislocation;
  stroke(0,230,0);
  line(xaxislocation, averageYPoint, xaxislocation + axisscale, averageYPoint);
  
  // create warn lines at 2 SDs
  float upperWarnLine = height - axisscale*(upperWarnValue - yaxismin)/range-yaxislocation;
  float lowerWarnLine = height - axisscale*(lowerWarnValue - yaxismin)/range-yaxislocation;
  stroke(230,0,0);
  line(xaxislocation, upperWarnLine, xaxislocation + axisscale, upperWarnLine); 
  line(xaxislocation, lowerWarnLine, xaxislocation + axisscale, lowerWarnLine);
 
// ******************************************************************************************
// Plot the Points
// ******************************************************************************************

  fill(255);
  stroke(0);
  rectMode(CENTER);
  
  for(int index = 0; index < numPoints; index++){
   
    if(index == pointhighlight){
      stroke(185, 0, 0);
      fill(0);
      rect(xaxisdiv*index+xaxislocation, height - axisscale*(graphArray[index] - yaxismin)/range-yaxislocation,3,3);
      stroke(0);
      fill(255);
    }
    else{
      rect(xaxisdiv*index+xaxislocation, height - axisscale*(graphArray[index] - yaxismin)/range-yaxislocation,3,3);
    }
    
    xpoints[index] = xaxisdiv*index+xaxislocation;
    ypoints[index] = height - axisscale*(graphArray[index] - yaxismin)/range-yaxislocation; 
  }
  
  rectMode(CORNER);
// ******************************************************************************************
// Sidebar Output
// ******************************************************************************************
  fill(0);
  //text("SD = " + standardDeviation, sidebarMargin, buttony*2.5);
  //text("avg = " + average, sidebarMargin, buttony*3);
  //text("UWL = " + upperWarnValue, sidebarMargin, buttony*3.5);
  //text("LWL = " + lowerWarnValue, sidebarMargin, buttony*4);
  //text("# logs: " + inputArray.length, sidebarMargin, buttony*4.5);
  if(pointhighlight != -1){
  //text("Y Val: "+ ypoints[pointhighlight],sidebarMargin, buttony*2.5);
  text("Peak: "+peak[pointhighlight], sidebarMargin,buttony*3);
  text("Avg: "+avg[pointhighlight], sidebarMargin,buttony*3.5);
  text("Plattime: "+plattime[pointhighlight], sidebarMargin,buttony*4);
  text("Platavg: "+platavg[pointhighlight], sidebarMargin,buttony*4.5);
  text("Date: " +datestamp[pointhighlight],sidebarMargin, buttony*5);
  text("Time: " +timestamp[pointhighlight],sidebarMargin, buttony*5.5);

  }
  
  drawtag = 0;
}
/*
  if(updatebuttonpressed){
    //println(updatebuttonpressed);
    updatebuttonpressed = false;
    println(updateButton.over());
    setup();
    drawtag = 1;
  }
*/  
  
  //println(xpoints);


  

// ******************************************************************************************
// Other Functions
// ******************************************************************************************

float findSD(float[] testArray, float testAvg){
  float[] standardDeviationArray = new float[testArray.length];
  for(int index = 0; index < testArray.length; index++){
    standardDeviationArray[index] = sq((testArray[index]-testAvg));
  }
  float standardDeviation = findAvg(standardDeviationArray);
  return standardDeviation = sqrt(standardDeviation);
}

float findAvg(float[] testArray){
  float average = 0;
  for(int index = 0; index < testArray.length; index++){
    average += testArray[index];
  }
  return average /= (float)(testArray.length);
}

float minVal(float[] testArray){
  float minimum = testArray[0];
  for(int i = 1; i < testArray.length; i++){
    if (testArray[i] < minimum){
      minimum = testArray[i];
    }
    
  }
  return minimum; 
}

boolean alarmFunction(float[] testArray, int testlastviewnumber){
  float[] testInputArray = testArray;
  int viewNumber = testlastviewnumber;
  float average = findAvg(testInputArray);
  float standardDeviation = findSD(testInputArray, average);
  float upperWarnValue = average+2*standardDeviation;
  float lowerWarnValue = average-2*standardDeviation;
  
    // find points outside of the WL
  for(int index = 0; index < testInputArray.length- viewNumber; index++){
    if(testInputArray[index] > upperWarnValue || testInputArray[index] < lowerWarnValue){
     return true;
    } 
  }
  return false;
}
  

float maxVal(float[] testArray){
  float maximum = testArray[0];
  for(int i = 1; i < testArray.length; i++){
    if (testArray[i] > maximum){
      maximum = testArray[i];

    }
    
  }
  return maximum;
}

int minIndex(float[] testArray){
  float minimum = testArray[0];
  int minind = 0;
  for(int i = 1; i < testArray.length; i++){
    if (testArray[i] < minimum){
      minimum = testArray[i];
      minind = i;
    }
    
  }
  return minind;
}
