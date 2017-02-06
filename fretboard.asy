unitsize(20pt);

real fretSize = 1;
real stringSpacing = .6;

defaultpen(linecap(2));

/*
 * Globals
 * -------------------------------------------------------------------------- *
 */

int numFrets = 4;
int capo = 0;

int[] majorscale = {
  0, // 1
  2, // 2
  4, // 3
  5, // 4
  7, // 5
  9, // 6
  11 // 7
};

/*
 * Notes
 */

 int C = 0;
 int D = 2;
 int E = 4;
 int F = 5;
 int G = 7;
 int A = 9;
 int B = 11;

 /*
  * Default string set
  */

 int strings[] = {
   E,
   A,
   D,
   G,
   B,
   E
 };

 /*
  * Default pen set
  */

 pen[] defaultScalePens = {
   red,        // 1
   currentpen, // 2
   heavygreen, // 3
   currentpen, // 4
   lightolive, // 5
   currentpen, // 6
   currentpen  // 7
 };


/*
 * Calculated Globals
 * -------------------------------------------------------------------------- *
 */

real noteSize = .4 * stringSpacing;

void setStrings(int[] strs) {
  strings = strs;
}

int[] getStrings() {
  return strings;
}

int getStringsNumber() {
  return getStrings().length;
}

real getFingerboardHeight() {
   return (getStringsNumber() - 1) * stringSpacing;
};


/*
 * Private methods
 * -------------------------------------------------------------------------- *
 */


 /**
  * Contains scale's degree number and alteration
  */

 struct DegreeInfo {
   int degree;
   int alteration;
 };


 /**
  * Returns DegreeInfo from string token
  */

 DegreeInfo getDegreeInfoFromToken(string token="") {
   write("token: " + token);
   int degree = (int) substr(token, 0, 1);
   string alterationToken = substr(token, 1, 1);

   int alteration = 0;

   if (alterationToken == "b") {
     alteration = -1;
   }
   if (alterationToken == "#") {
     alteration = +1;
   }

   DegreeInfo degreeInfo;
   degreeInfo.degree = degree;
   degreeInfo.alteration = alteration;

   return degreeInfo;
 }

 /**
  * Returns an array of DegreeInfo's from scale string
  */

 DegreeInfo[] getDegreeInfosFromScale(string scale = "") {
   string[] tokens = split(scale, " ");
   DegreeInfo[] degreeInfos = {};

   for (int i = 0; i < tokens.length; ++i) {
     string token = tokens[i];
     DegreeInfo degreeInfo = getDegreeInfoFromToken(token);
     degreeInfos.push(degreeInfo);
   }

   return degreeInfos;
 }




 /**
  * Returns an array of pitches from scale string
  */

 int[] getPitchesFromScale(string scale = "") {
   string[] tokens = split(scale, " ");
   int[] pitches = {};
   for (int i = 0; i < tokens.length; ++i) {
     string token = tokens[i];
     int degree = (int) substr(token, 0, 1);

     if (degree > 7) {
       degree = degree - 7;
     }

     string alterationToken = substr(token, 1, 1);
     int alteration = 0;
     if (alterationToken == "b") {
       alteration = -1;
     }
     if (alterationToken == "#") {
       alteration = +1;
     }

     int pitch = majorscale[degree - 1] + alteration;
     write(pitch);
     pitches.push(pitch);
   }
   return pitches;
 }

  /**
  * Returns nicely formatted LaTeX string with alteration for scale degree token
  */

  string getFormattedDegreeFromToken(string token = "") {
    DegreeInfo degreeInfo = getDegreeInfoFromToken(token);
    write(degreeInfo.degree);
    write(degreeInfo.alteration);

    string degree = (string) degreeInfo.degree;

    string alteration = "";
    if (degreeInfo.alteration == 1) {
      alteration = "$\sharp$";
    }
    if (degreeInfo.alteration == -1) {
      alteration = "$\flat$";
    }

    return alteration + degree;
  }



/**
 * Draws title
 */

void drawTitle(string title = "") {
  label("\Large " + title, (getFingerboardHeight() / 2, 0), 7N);
  return;
}

/**
 * Returns token for given pitch and key
 */

string getTokenForPitchInKey(int pitch = 0, int key = 0) {
  write(format("pitch: %i", pitch));

  if (pitch < key) {
    pitch = pitch + 12;
  }

  pitch = pitch - key;


  for (int i = 0; i < majorscale.length; ++i) {
    if (pitch > majorscale[i]) continue;
    if (pitch == majorscale[i]) return (string) (i + 1);
    if (pitch < majorscale[i]) {
      return ((string) (i + 1)) + "b";
    };
  }
  return "7";
}



/**
 * Returns pen for given scale degree acording to `pens` pen set
 */

pen getPenForDegree(
  int degree = 1,
  pen[] pens = defaultScalePens
) {
  if (degree < pens.length + 1) {
    return pens[degree -1];
  }
  return currentpen;
}


/*
 * Public Methods
 * -------------------------------------------------------------------------- *
 */


/**
 * Draws fingerboard
 */

void drawFingerboard(string title = "", bool dots = false) {
  real fingerboardHeight = (getStringsNumber() - 1) * stringSpacing;

  drawTitle(title);

  /* Draw invisible lines for nice margin */
  draw((-1, -numFrets * fretSize)--(-1, 0), invisible);
  draw((fingerboardHeight + 1, -numFrets * fretSize)--(fingerboardHeight + 1,0), invisible);
  draw((- 1, -numFrets * fretSize - 1)--(fingerboardHeight + 1, -numFrets * fretSize - 1), invisible);
  draw((- 1, 3)--(fingerboardHeight + 1, 3), invisible);

  for (int i = 0; i < numFrets + 1; ++i) {
   real fretPos = - i * fretSize;
   draw((0, fretPos)--(fingerboardHeight, fretPos));

   int currentFret = i + capo;

   /* Draw dots */
   if (dots) {
     if (
       i > 0 &&
       currentFret % 2 > 0 && currentFret > 1 &&
       currentFret % 11 != 0 && currentFret % 13 != 0
     ) {
       fill(shift(-.6, fretPos + .5 * fretSize) * scale(.1) * unitcircle, gray);
     }

     if (i > 0 && currentFret == 12) {
       fill(shift(-.6, fretPos + .35 * fretSize) * scale(.1) * unitcircle, gray);
       fill(shift(-.6, fretPos + .65 * fretSize) * scale(.1) * unitcircle, gray);
     }
   }

   /* draw fret numbers */
  //  label("\tiny " + (string) (capo + i), (-.1, - i * fretSize), 2W, lightgray);
  }

  for (int i = 0; i < getStringsNumber(); ++i) {
   real stringPos = i * stringSpacing;
   draw((stringPos, 0)--(stringPos, - numFrets * fretSize));
  }

  if (capo == 0) {
   draw((0,0)--(fingerboardHeight, 0), linewidth(1.5) + linecap(1));
  }

  return;
}


/**
 * Returns canvas position of a note
 */

pair getNotePosition(
  int str = 1,
  int fret = 1
) {
  str = str - 1;
  pair notePosition = (
    str * stringSpacing,
    - fret * fretSize  + fretSize / 2
  );

  return notePosition;
}


 /**
  * Draws single note
  */

void drawNote(
  int str = 1,
  int fret = -1,
  string token = "",
  int finger = 0,
  pen bg = defaultpen,
  pen border = black,
  pen fg = white
) {

  assert(
    str < getStrings().length + 1 && str > 0,
    format("Wrong string number (%i)", str) +
    format(" when trying to put note at fret %i", fret)
  );

  assert(
    fret > -2 && fret < numFrets + 1,
    format("Wrong fret (%i)", fret)
  );

  assert(
    finger > -2 && finger < 5,
    format("Wrong finger (%i)", finger)
  );

  pair notePosition = getNotePosition(str, fret);
  str = str - 1;

  int fretNum = 0;
  if (fret == -1) {
    fretNum = 0;
  } else {
    fretNum = fret;
  }

  pen notePen = defaultpen;

  if (fret == -1) {
    label("$\times$", (str * stringSpacing, fretSize / 2));
    return;
  }

  if (fretNum == 0) {

    if (fg == white) {
      fg = defaultpen;
    }

    draw(
      shift(str * stringSpacing, fretSize / 2)
      * scale(noteSize)
      * unitcircle,
      bg
    );

    label(
      "\tiny " + getFormattedDegreeFromToken(token),
      (str * stringSpacing, fretSize / 2),
      fg
    );

    return;
  }


  filldraw(
    shift(notePosition)
    * scale(noteSize)
    * unitcircle,
    bg,
    border
  );

  label(
    "\tiny " + getFormattedDegreeFromToken(token),
    notePosition,
    fg
  );

  if (finger < 1) return;

  label(
    "\tiny " + (string) finger,
    notePosition + 1.8 * noteSize * SE ,
    gray
  );

  return;
}


/**
 * Draws fingering of a note
 */

 void drawFingering(int str = 1, int fret = 0, int finger = 0) {
   pair notePosition = getNotePosition(str, fret);

   if (finger < 1) return;

   label(
     "\tiny " + (string) finger,
     notePosition + 1.8 * noteSize * SE ,
     gray
   );
 }

/**
 * Draws notes according to tab string
 */


void drawChord(
  string tab = "x x x x x x",
  string fingering="",
  int root=0
) {
  string[] notes = split(tab, " ");
  string[] fingerings = split(fingering, " ");

  for (int i = 0; i < notes.length; ++i) {
    int string = i + 1;
    string note = notes[i];

    if (note == "-") continue;

    int finger = 0;
    int tuning = getStrings()[i];

    int pitch = -1;
    int fret = -1;

    string token = "";
    pen bg = currentpen;

    if (note != "x") {
      fret = (int) note;
      pitch = (tuning + fret + capo) % 12;
      token = getTokenForPitchInKey(pitch, root);
      DegreeInfo degreeInfo = getDegreeInfoFromToken(token);
      bg = getPenForDegree(degreeInfo.degree);
    }

    if (fingerings.length > i && note != "x" && fingerings[i] != "-") {
      finger = (int) fingerings[i];
    }

    drawNote(string, fret, token, finger, bg);
  }
  return;
}



/**
 * Draws notes of a scale, represented as array of semitones
 */

void drawScaleOnString(
  int root = 0,
  string scale = "1 2 3 4 5 6 7",
  int string=1,
  int tuning = 0,
  pen[] pens = defaultScalePens
) {
  int[] pitches = getPitchesFromScale(scale);
  string[] tokens = split(scale, " ");
  DegreeInfo[] degreeInfos = getDegreeInfosFromScale(scale);

  int fret = 0;
  int degree = 0;
  int offset = -tuning - 12 + root - capo;

  while (fret < numFrets) {
    fret = pitches[degree] + offset;
    int scaleDegree = degreeInfos[degree].degree;
    string token = tokens[degree];

    pen bg = getPenForDegree(scaleDegree, pens);

    if (fret > -1 && fret < numFrets + 1) {
      if (!(fret == 0 && capo > 0)) {
        drawNote(string, fret, token, bg);
      }
    }

    ++degree;

    if (degree > pitches.length - 1) {
      degree = 0;
      offset = fret + 12 - pitches[pitches.length - 1];
    }
  }
}


void drawScale(int root=0, string scale ="1 2 3 4 5 6 7", pen[] pens = defaultScalePens) {
  for (int i = 0; i < getStringsNumber(); ++i) {
    drawScaleOnString(root, scale, i + 1, strings[i], pens);
  }
}




/* -------------------------------------------------------------------------- */
