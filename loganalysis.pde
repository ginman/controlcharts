int windowsize = 500;
int fontsize = 14;
int drawtag = 1;    
float yaxislocation = 0.05*windowsize;
float xaxislocation = 0.05*windowsize+25;
float axisscale = windowsize - 2*0.05*windowsize;
int sidebarMargin;
int buttony;
float[] InputArray;
int numPoints = 10;
//String currentTab = "peak";


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

class Button{
  int x,y;
  int buttonHeight;
  int buttonWidth;
  String buttonText;
  color basecolor, highlightcolor, alertcolor;
  color currentcolor;
  boolean over = false;
  boolean pressed = false;
  boolean alert = false;
  boolean focus = false;
  int lastViewNumber;
  
  void update(){
    
    if(alert){
      currentcolor = alertcolor;
      if(over()){
      currentcolor = highlightcolor;
      }
    }
    else if(over()){
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
    if(over){
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
  
  boolean overRect(int x, int y, int buttonWidth, int buttonHeight){
    if(mouseX >= x && mouseX <= x + buttonWidth && mouseY >= y && mouseY <= y+buttonHeight){
      return true;
    }
    else{
      return false;
    }
  }
}
class RectButton extends Button
{
  RectButton(int ix, int iy, int iwidth, int iheight, color icolor, color ihighlight, color ialert, String ibuttonText) 
  {
    x = ix;
    y = iy;
    buttonText = ibuttonText;
    buttonWidth = iwidth;
    buttonHeight = iheight;
    basecolor = icolor;
    alertcolor = ialert;
    highlightcolor = ihighlight;
    currentcolor = basecolor;
  }

  boolean over() 
  {
    if( overRect(x, y, buttonWidth, buttonHeight) ) {
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
    rect(x, y, buttonWidth, buttonHeight);
    fill(255);
    text(buttonText, x + 5, y + .75*buttonHeight);
  }
}      
      
void update(int x, int y)
{
  if(locked == false) {
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
    if(updateButton.pressed()) {
      updatebuttonpressed = true;
      peakTab.alert = false;
      avgTab.alert = false;
      platlenTab.alert = false;
      platavgTab.alert = false;
      drawtag = 1;
    } 
    if(peakTab.pressed()){
      peakTab.focus = true;
      avgTab.focus = false;
      platlenTab.focus = false;
      platavgTab.focus = false;
      currentView = peakTab;
      drawtag = 1;
      peakTab.alert = false;
    }
    if(avgTab.pressed()){
      peakTab.focus = false;
      avgTab.focus = true;
      platlenTab.focus = false;
      platavgTab.focus = false;
      currentView = avgTab;
      drawtag = 1;
      avgTab.alert = false;
    }
    if(platlenTab.pressed()){
      peakTab.focus = false;
      avgTab.focus = false;
      platlenTab.focus = true;
      platavgTab.focus = false;
      currentView = platlenTab;
      drawtag = 1;
      platlenTab.alert = false;
    }
    if(platavgTab.pressed()){
      platavgTab.focus = true;
      peakTab.focus = false;
      avgTab.focus = false;
      platlenTab.focus = false;
      
      currentView = platavgTab;
      drawtag = 1;
      platavgTab.alert = false;
    }
    if(view5.pressed()){
      numPoints = 5;
      drawtag = 1;
      view5.alert = true;
      view10.alert = false;
      view20.alert = false;
      view50.alert = false;
      viewAll.alert = false;
    }
    if(view10.pressed()){
      numPoints = 10;
      drawtag = 1;
      view10.alert = true;
      view5.alert = false;
      view20.alert = false;
      view50.alert = false;
      viewAll.alert = false;
    }
    if(view20.pressed()){
      numPoints = 20;
      drawtag = 1;
      view20.alert = true;
      view5.alert = false;
      view10.alert = false;
      view50.alert = false;
      viewAll.alert = false;
    }
     if(view50.pressed()){
      numPoints = 50;
      drawtag = 1;
      view50.alert = true;
      view5.alert = false;
      view10.alert = false;
      view20.alert = false;
      viewAll.alert = false;
    }
     if(viewAll.pressed()){
      numPoints = 2000;
      drawtag = 1;
      viewAll.alert = true;
      view5.alert = false;
      view10.alert = false;
      view50.alert = false;
      view20.alert = false;
    }
  }
}      


void setup(){
  size(650, 500, JAVA2D);
  PFont f;
  f = loadFont("Dialog.plain-48.vlw");
  textFont(f,fontsize);
  
  
  color buttoncolor = color(153);
  color highlight = color(100);
  color alertcolor = color(185, 0, 0);
  //create update button
  sidebarMargin = (int)round(1.5*xaxislocation + axisscale); 
  buttony = (int)round(yaxislocation);
  int tabwidth = 3*buttony;
  // String updateButtonText = "Update";
  updateButton = new RectButton(sidebarMargin, buttony, 3*buttony, buttony, buttoncolor, highlight, alertcolor, "Update"); 
  peakTab = new RectButton(round(xaxislocation), 0, tabwidth, buttony, buttoncolor, highlight, alertcolor, "Peak");
  avgTab = new RectButton(round(xaxislocation)+tabwidth, 0 , tabwidth, buttony, buttoncolor, highlight, alertcolor, "Average");
  platlenTab = new RectButton(round(xaxislocation)+2*tabwidth, 0 , round(1.5*tabwidth), buttony, buttoncolor, highlight, alertcolor, "Plateau Time");
  platavgTab = new RectButton(round(xaxislocation)+2*tabwidth+round(1.5*tabwidth), 0 , round(1.5*tabwidth), buttony, buttoncolor, highlight, alertcolor, "Plateau Avg");
  view5 = new RectButton(sidebarMargin, height - buttony, buttony, buttony, buttoncolor, highlight, highlight, " 5");
  view10 = new RectButton(sidebarMargin + buttony, height - buttony, buttony, buttony, buttoncolor, highlight, highlight, "10");
  view20 = new RectButton(sidebarMargin + 2*buttony, height - buttony, buttony, buttony, buttoncolor, highlight, highlight, "20");
  view50 = new RectButton(sidebarMargin + 3*buttony, height - buttony, buttony, buttony, buttoncolor, highlight, highlight, "50");
  viewAll = new RectButton(sidebarMargin + 4*buttony, height - buttony, buttony, buttony, buttoncolor, highlight, highlight, "All");
  numPoints = 10;
  view10.alert = true;
  currentView = peakTab;
}

void draw(){
  update(mouseX, mouseY);
  updateButton.display();
  peakTab.display();
  avgTab.display();
  platlenTab.display();
  platavgTab.display();
  
  view5.display();
  view10.display();
  view20.display();
  view50.display();
  viewAll.display();
  
  if(drawtag == 1){
    
    
    
    fill(200);
    stroke(200);
    // color over the non-tab parts of the window
    rect(0,yaxislocation,width,height-yaxislocation);
    rect(0,0,xaxislocation-1,yaxislocation);
    String[] logfile;
    String[] logfiletemp;
    String directory;
    String filename = "/N48AC.TXT";
    
    println("You've made it to 1");
    
//    // import the data from the log file
//    String dirtest = dataPath("");
//    println(dirtest);
    
//    println(dataPath("/home/ginman/Processing/loganalysis/data/logs/perry"));
    
//    File dir = new File(dataPath("/home/ginman/Processing/loganalysis/data/logs/perry"));
    File dir = new File("/home/ginman/Processing/loganalysis/data/logs/perry");
    String[] foldernames = dir.list();
    
    println(foldernames);
    
    
    println("You've made it to 2");
    
    println(dir);
    
//    String[] foldernames = dir.list();
    
    //logfile = loadStrings("N97C_LOG.TXT");
    directory = "/home/ginman/Processing/loganalysis/data/logs/perry/" + foldernames[0] + "/SW48A" + filename;
    println(directory);
    logfile = loadStrings(directory);
    
    for (int index = 1; index < foldernames.length; index++){
      
      directory = "/home/ginman/Processing/loganalysis/data/logs/perry/" + foldernames[index] + "/SW48A" + filename;

      logfiletemp = loadStrings(directory);
      
      if (logfiletemp==null){
        println("No log file found");
      }
      else{
        //splice(logfile,logfiletemp, 0);
        logfile = concat(logfile,logfiletemp);
       
      }
    }

    
//    logfile = loadStrings("/home/ginman/Processing/loganalysis/web-export/N97C_LOG.TXT");
//    if (logfile==null){
//      println("File not loaded");
//    }
//    else{  
//      println(logfile);
//    }
    
    int loglength = logfile.length;
    int[] data = new int[loglength];
    String[] timestamp = new String[loglength];
    float[] platavg = new float[loglength];
    float[] peak = new float[loglength];
    float[] plattime = new float[loglength];
    float[] avg = new float[loglength];
    
    for (int index = 0; index < logfile.length; index++) {
      String[] currentlog = split(logfile[index],',');
      timestamp[index] = currentlog[0];
      platavg[index] = float(currentlog[4]);
      peak[index] = float(currentlog[1]);
      plattime[index] = 0.02*float(currentlog[3]);
      avg[index] = float(currentlog[2]);
    }

//      for (int i=0; i < logfile.length; i++) {
//        println(logfile[i]);
//      }
//
//      println("Imported " + logfile.length + " switch movement data logs");
  fill(255);
  stroke(0);
  // draw the graph outline
  rect(xaxislocation,yaxislocation,height - 2*0.05*height,height - 2*0.05*height);
  
  numPoints = min(numPoints, logfile.length);
  
  float[] inputArray = new float[numPoints];
  float[] graphArray = new float[numPoints];
  /*
  // cycle through each array, find if any have points outside of the warn limits
  inputArray = peak;
  float average = findAvg(inputArray);
  float standardDeviation = findSD(inputArray, average);
  float upperWarnValue = average+2*standardDeviation;
  float lowerWarnValue = average-2*standardDeviation;
  
  // find points outside of the WL
  for(int index = 0; index < inputArray.length; index++){
    if(inputArray[index] > upperWarnValue || inputArray[index] < lowerWarnValue){
     peakTab.alert = true;
    } 
  }
  
  inputArray = platavg;
  average = findAvg(inputArray);
  standardDeviation = findSD(inputArray, average);
  upperWarnValue = average+2*standardDeviation;
  lowerWarnValue = average-2*standardDeviation;
  
  // find points outside of the WL
  for(int index = 0; index < inputArray.length; index++){
    if(inputArray[index] > upperWarnValue || inputArray[index] < lowerWarnValue){
     platavgTab.alert = true;
    } 
  }
  */
  
  peakTab.alert = alertFunction(peak, peakTab.lastViewNumber);
  avgTab.alert = alertFunction(avg, avgTab.lastViewNumber);
  platlenTab.alert = alertFunction(plattime, platlenTab.lastViewNumber);
  platavgTab.alert = alertFunction(platavg, platavgTab.lastViewNumber);
  
  
  currentView.lastViewNumber = numPoints;
  
  
//  println(peakTab.lastViewNumber);
//  println(avgTab.lastViewNumber);
//  println(platlenTab.lastViewNumber);
//  println(platavgTab.lastViewNumber);
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
     platavgTab.alert = false;
    }
  
  float average = findAvg(inputArray);
  float standardDeviation = findSD(inputArray, average);
  float upperWarnValue = average+2*standardDeviation;
  float lowerWarnValue = average-2*standardDeviation;
  
//  // find points outside of the WL
//  for(int index = 0; index < inputArray.length; index++){
//    if(inputArray[index] > upperWarnValue || inputArray[index] < lowerWarnValue){
//     platavgTab.alert = true;
//    } 
//  }
  
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
  
  /*
  println("maxpeak = " + arrayMax + ", minpeak = " + arrayMin + ", divlen = " + divlen); 
  println("xaxisdiv = " + xaxisdiv);
  println("yaxismin = " + yaxismin);
  println("yaxismax = " + yaxismax);
  println("axisscale = " + axisscale);
  println("range = " + range);
  */
  
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
  //println("SD = " + standardDeviation);
  //println("avg = " + average);
  
  // create and plot the x axis divisions
//  for(int index = 0; index <= peak.length; index++){ 
  
  fill(255);
  stroke(0);
  // plot the points
  for(int index = 0; index < numPoints; index++){
    rectMode(CENTER);
    rect(xaxisdiv*index+xaxislocation, height - axisscale*(graphArray[index] - yaxismin)/range-yaxislocation,3,3);
    rectMode(CORNER);
//    println("index = " + index);
//    println("point = " + inputArray[index]);
//    println("xpoint = " + xaxisdiv*index+xaxislocation);
//    println("ypoint = " + axisscale*(inputArray[index] - yaxismin)/range);  
  }
  
  // sidebar output
  fill(0);
  text("SD = " + standardDeviation, sidebarMargin, buttony*2.5);
  text("avg = " + average, sidebarMargin, buttony*3);
  text("UWL = " + upperWarnValue, sidebarMargin, buttony*3.5);
  text("LWL = " + lowerWarnValue, sidebarMargin, buttony*4);
  text("# logs: " + inputArray.length, sidebarMargin, buttony*4.5);
  
  drawtag = 0;
  }
  if(updatebuttonpressed){
    println("DING");
    updatebuttonpressed = false;
  }
  
  
}  

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

boolean alertFunction(float[] testArray, int testlastviewnumber){
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


