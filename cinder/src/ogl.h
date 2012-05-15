/*
 *  ogl.h
 *  funkt
 *
 *  Created by alo on 22/04/2011.
 *  
 *	This file is part of funkt.
 *
 *	funkt is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 
 *	funkt is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 
 *	You should have received a copy of the GNU General Public License
 *	along with funkt.  If not, see <http://www.gnu.org/licenses/>. 
 *
 */
#ifndef OGL_H
#define OGL_H

#include "Resources.h"

#include "cinder/app/AppBasic.h"
#include "cinder/gl/gl.h"
#include "cinder/Camera.h"
#include "cinder/gl/GlslProg.h"
#include "cinder/Perlin.h"
#include "cinder/Vector.h"
#include "cinder/Sphere.h"
#include "cinder/gl/Fbo.h"
#include <utility>

#include "world.h"
using std::pair;

#include <list>
using std::list;

using namespace ci;
using namespace ci::app;
using namespace std;

const int numPatterns = 20;

struct pattern {

	bool active; 
	double alpha;
	int alphamap;
	int colormap;
	
	pattern(): active(false), alpha(0), alphamap(0), colormap(0) {};
	~pattern() {};
};

class GraphicsRenderer {

public:
	GraphicsRenderer(World* world, int winWidth, int winHeight) {
		patternLib = new pattern[numPatterns];
		_world = world;
		_winWidth = winWidth;
		_winHeight = winHeight;
		_halfX = winWidth * 0.5f;
		_halfY = winHeight * 0.5f;
		ptrBMU = NULL;
		mDirectional = 1.0f;
		bSHADER = true;
		bLIGHT = true;
		_fCounter = 0;
		mLightLoc = Vec3f::zero();
		blocx = 0.0f;
		blocy = 0.0f;
	};
	
	~GraphicsRenderer() {
		delete [] patternLib;
	};
	
	pattern* patternLib;	
	
	// *** OpenGL global setup  *** //

	void setupOgl();
	
	void reshape(ResizeEvent);
	
	void prepareFrame();
	
	void finalizeFrame();

	// *** draw cells *** //

	void drawFragment(Node*, Node*, int, int);
	
	void drawSOMFragment(Node*, Node*, int, int);
	
	void drawRow();
	
	void drawWorld();
	
	// cinder camera
	
//	CameraPersp mCam; 
	gl::GlslProg mShader;
//	gl::Fbo mFbo;
	
	bool bSHADER;
	float mDirectional; 
	Vec3f mLightLoc;
	bool bLIGHT;
		
private:
	
	double fragSizeX, fragSizeY, state;
	float xL, yB, zF, xW, yH, zD, red, green, blue, alpha;
	float blocx, blocy;
	int currentIndex, vectorSize, _winWidth, _winHeight, _halfX, _halfY, _fCounter;
	Node* currentNode;
	Node* ptrBMU;
	World* _world;
	
	GLfloat *rowVertices, *worldVertices, *rowNormals, *worldNormals, *rowColors, *worldColors;
	
	bool _drawRow, _drawWorld;

	void pattern00(int, int);

	void pattern01(int, int);
	
	void pattern02(int, int);
	
	void pattern03(int, int);

	void pattern04(int, int);
	
	void pattern05(int, int);
	
	void pattern06(int, int);
	
	void pattern07(int, int);
	
	void pattern08(int, int);
	
	void pattern09(int, int);

	void pattern10(int, int);
	
	void pattern11(int, int);
	
	void pattern12(int, int);
	
	void pattern13(int, int);
	
	void pattern14(int, int);

	void pattern15(int, int);

	void pattern16(int, int);
	
	void pattern17(int, int);

	void pattern18(int, int);

	void pattern19(int, int);

	// *** basic drawing functions *** //
	
	void fillRect (int);
	
	void strokeRect (int, float);
	
	void drawPoint (float, float, float, float);
	
	void drawLine (float, float, float, float, float, float, float);
	
	void drawCircle (int, float, int, bool);
	
	void strokeRectArray();
	
};

#endif