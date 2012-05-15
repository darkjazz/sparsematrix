/*
 *  ogl.cpp
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

#include "ogl.h"

GLfloat no_mat[]			= { 0.0, 0.0, 0.0, 1.0 };
GLfloat mat_ambient[]		= { 0.3, 0.1, 0.4, 1.0 };
GLfloat mat_diffuse[]		= { 0.3, 0.5, 0.8, 1.0 };
GLfloat mat_specular[]		= { 1.0, 1.0, 1.0, 1.0 };
GLfloat mat_emission[]		= { 0.4, 0.7, 1.0, 0.0 };
GLfloat no_shininess[]		= { 0.0 };
GLfloat mat_shininess[]		= { 128.0 };

void GraphicsRenderer::setupOgl () {
		
	mShader = gl::GlslProg(loadResource( RES_VERT_GLSL ), loadResource( RES_FRAG_GLSL ) ); 
	
	gl::clear( Color( 0.0, 0.0, 0.0 ) );
		
	gl::enableAlphaBlending();	
	gl::enableDepthWrite();
	gl::enableDepthRead();
	gl::enable(GL_LINE_SMOOTH);
		
}

void GraphicsRenderer::reshape( ResizeEvent event ) {
//	mCam.lookAt( Vec3f(0.0f, 0.0f, 500.0f), Vec3f::zero() );
//	mCam.setPerspective(60, getWindowAspectRatio(), 1, 5000);
//	gl::setMatrices( mCam );
}

void GraphicsRenderer::prepareFrame() {
	
	currentIndex = _world->index();
	
	fragSizeX = (double)(_winWidth / _world->sizeX());
	fragSizeY = (double)(_winHeight / _world->sizeY());
	vectorSize = _world->vectorSize();
			
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
	
	_fCounter++;
		
	if (patternLib[5].active) {
		
		gl::enable( GL_LIGHTING );
		gl::enable( GL_LIGHT0 );
		
		if (_fCounter % 2 == 0) {
			bLIGHT = !bLIGHT;
		}
		
		if (_world->bmuInitialized)
		{
			mDirectional -= ( mDirectional - 0.985f ) * 0.1f;
			blocx = ( ptrBMU->x * fragSizeX + (fragSizeX * 0.5f)) - getWindowWidth() * 0.5f;
			blocy = getWindowHeight() * 0.5f - ( ptrBMU->y * fragSizeY + (fragSizeY * 0.5f));				
		}
		else
		{
			mDirectional -= ( mDirectional - 0.51f ) * 0.1f;
		}
		
		mLightLoc -= ( mLightLoc - Vec3f(blocx, blocy, 40.0) ) * 0.1f;

		GLfloat light_position[] = { mLightLoc.x, mLightLoc.y, mLightLoc.z, mDirectional };
		
		glLightfv( GL_LIGHT0, GL_POSITION, light_position );
		glLightf( GL_LIGHT0, GL_CONSTANT_ATTENUATION, 0.0f );
		glLightf( GL_LIGHT0, GL_LINEAR_ATTENUATION, 0.0f );
		glLightf( GL_LIGHT0, GL_QUADRATIC_ATTENUATION, 0.00015f );
				
	}
	else
	{
		gl::disable( GL_LIGHTING );
		gl::disable( GL_LIGHT0 );
	
	}
	
}

void GraphicsRenderer::finalizeFrame() {
		
}

void GraphicsRenderer::drawSOMFragment(Node *theNode, Node *bmu, int x, int y) {
	double compare;
	int index;
	
	currentNode = theNode;
	ptrBMU = bmu;
	
	state = currentNode->phase;
	
	compare = 0.0;
	index = 0;
	
	for (int i = 0; i < vectorSize; i++) {
		if (currentNode->weights[i] > compare) {
			index = i;
			compare = currentNode->weights[i];
		}
	}
	
	if (index == 0) {
		pattern00(x, y);
		pattern08(x, y);
	} else if (index == 1) {
		pattern01(x, y);
		pattern09(x, y);
	} else if (index == 2) {
		pattern02(x, y);
		pattern10(x, y);
	} else if (index == 3) {
		pattern03(x, y);
		pattern11(x, y);
	} else if (index == 4) {
		pattern04(x, y);
		pattern12(x, y);
	} else if (index == 5) {
		pattern05(x, y);
		pattern13(x, y);
	} else if (index == 6) {
		pattern06(x, y);
		pattern14(x, y);
	} else if (index == 7) {
		pattern07(x, y);
		pattern15(x, y);
	}
	
		
}


void GraphicsRenderer::drawFragment(Node *theNode, Node* bmu, int x, int y) {
	
	currentNode = theNode;
	ptrBMU = bmu;
	
	state = currentNode->phase;
	if (patternLib[0].active) {
		pattern00(x, y);
	}
	if (patternLib[1].active) {
		pattern01(x, y);	
	}
	if (patternLib[2].active) {
		pattern02(x, y);	
	}
	if (patternLib[3].active) {
		pattern03(x, y);	
	}
	if (patternLib[4].active) {
		pattern04(x, y);	
	}
	if (patternLib[5].active) {
		pattern05(x, y);	
	}
	if (patternLib[6].active) {
		pattern06(x, y);	
	}
	if (patternLib[7].active) {
		pattern07(x, y);	
	}
	if (patternLib[8].active) {
		pattern08(x, y);	
	}
	if (patternLib[9].active) {
		pattern09(x, y);	
	}
	if (patternLib[10].active) {
		pattern10(x, y);	
	}
	if (patternLib[11].active) {
		pattern11(x, y);	
	}
	if (patternLib[12].active) {
		pattern12(x, y);	
	}
	if (patternLib[13].active) {
		pattern13(x, y);	
	}
	if (patternLib[14].active) {
		pattern14(x, y);	
	}
	if (patternLib[15].active) {
		pattern15(x, y);	
	}
	if (patternLib[16].active) {
		pattern16(x, y);	
	}
	if (patternLib[17].active) {
		pattern17(x, y);	
	}
	if (patternLib[18].active) {
		pattern18(x, y);	
	}
	if (patternLib[19].active) {
		pattern19(x, y);	
	}
	
	
}

void GraphicsRenderer::drawRow() {
	
	if (_drawRow)
	{
	
		glEnableClientState(GL_NORMAL_ARRAY);
		glEnableClientState(GL_COLOR_ARRAY);
		glEnableClientState(GL_VERTEX_ARRAY);
		
		glNormalPointer(GL_FLOAT, 0, rowNormals);
		glColorPointer(4, GL_FLOAT, 0, rowColors);
		glVertexPointer(3, GL_FLOAT, 0, rowVertices);

		glEnable(GL_LINE_SMOOTH);
		
		glDrawArrays(GL_LINES, 0, _world->sizeY());
		
		glDisable(GL_LINE_SMOOTH);
		
	//	glEnable(GL_POLYGON_SMOOTH);
	//	
	//	glDrawArrays(GL_POLYGON, 0, world->sizeY());
	//	
	//	glDisable(GL_POLYGON_SMOOTH);
		
		glDisableClientState(GL_VERTEX_ARRAY);
		glDisableClientState(GL_COLOR_ARRAY);
		glDisableClientState(GL_NORMAL_ARRAY);
	}
	
}

void GraphicsRenderer::drawWorld() {

}

void GraphicsRenderer::pattern00(int x, int y) {
	float ctr, yval;
	
	ctr = _world->sizeY()*fragSizeY*0.5;
	
	yval = ctr - (y * fragSizeY);
	xL = x * fragSizeX + fragSizeX - (fragSizeX * 4.0 * state);
//	yB = (_winHeight * 0.5f) + (((_winHeight * 0.5f) - (y * fragSizeY)) * 0.5f);
	yB = sin((yval / ctr) * (PI * 0.5)) * abs(yval); 
	zF = zD = fragSizeX * state * currentNode->weights[2] * -1.0;
	
	xL -= _halfX;
	
	xW = fragSizeX * state * 8.0;
	yH = fragSizeY * state * (sin((yval / ctr) * (PI * 0.5)) * 0.3);
	
	red = abs(patternLib[0].colormap - state);
	green = abs(patternLib[0].colormap - state);
	blue = abs(patternLib[0].colormap - state);
	alpha = abs(patternLib[0].alphamap - state);
	alpha *= patternLib[0].alpha;
	
	gl::color(red, green, blue, alpha);
	gl::drawStrokedRect(Rectf(xL, yB, xL + xW, yB + yH));

}

void GraphicsRenderer::pattern01(int x, int y) {
	xL = (_winWidth * 0.5f) + (((_winWidth * 0.5f) - (x * fragSizeX)) * 0.4f);
	yB = y * fragSizeY + fragSizeY - (fragSizeY * 10.0 * state);
	zF = zD = 0.0;

	xL -= _halfX;
	yB -= _halfY;
	
//	xL += fragSizeX * 2.0 * sin(state * 2 * PI);
		
	xW = fragSizeX * state * 0.2;
	yH = fragSizeY * state * 20.0;
	
	red = abs(patternLib[1].colormap - state);
	green = abs(patternLib[1].colormap - state);
	blue = abs(patternLib[1].colormap - state);
	alpha = abs(patternLib[1].alphamap - state);
	alpha *= patternLib[1].alpha;
	
	gl::color(red, green, blue, alpha);
	gl::drawStrokedRect(Rectf(xL, yB, xL + xW, yB + yH));
	
}

void GraphicsRenderer::pattern02(int x, int y) {

	xL = x * fragSizeX + mapf(state * 0.5f, 0.9f, 1.5f);
	yB = y * fragSizeY + mapf(state * 0.5f, 0.9f, 1.5f);
	
	xL -= _halfX;
	yB -= _halfY;
		
	xW = fragSizeX * mapf(state, 0.9f, 1.5f);
	yH = fragSizeY * mapf(state, 0.9f, 1.5f);
	
	red = abs(patternLib[2].colormap - state);
	green = abs(patternLib[2].colormap - state);
	blue = abs(patternLib[2].colormap - state);
	alpha = abs(patternLib[2].alphamap - state);	
	alpha = patternLib[2].alpha;
	
	if (_world->bmuInitialized) {
		if (ptrBMU->x == x || ptrBMU->y == y) 
		{
			if (ptrBMU->y == y) {
				yB = y * fragSizeY + (fragSizeY * 0.4f);
				yB -= _halfY;

				yH = fragSizeY * 0.1f;
				xW = fragSizeX;
			} else {
				xL = x * fragSizeX + (fragSizeX * 0.4f);				
				xL -= _halfX;
				
				xW = fragSizeX * 0.1f;
				yH = fragSizeY;
			}
			
			alpha = clipf(alpha+0.33f, 0.0f, 1.0f);
			gl::color(red, green, blue, alpha);
			gl::drawSolidRect(Rectf(xL, yB, xL + xW, yB + yH));
		}
		{
			alpha *= 0.5f;		
		}
	}
	{
		alpha *= 0.4f;
	}
	
	gl::color(red, green, blue, alpha);
	gl::drawStrokedRect(Rectf(xL, yB, xL + xW, yB + yH));
		
}

void GraphicsRenderer::pattern03(int x, int y) {
	
	float eState;
	float mul;
	float maxdist, dist;
		
	if (x > 0 && y > 0 && x < _world->sizeX() - 1 && y < _world->sizeY() - 1)
	{
		
		maxdist = sqrt((pow((float)_world->sizeX(), 2) + pow((float)_world->sizeY(), 2))) * 0.5f;
		
		dist = sqrt(pow(x - (_world->sizeX() * 0.5f), 2) + pow(y - (_world->sizeY() * 0.5f), 2));
		mul = linlin(maxdist - dist, 0, maxdist, 1.0, 2.0);
		
		xL = fragSizeX * 1.1 * x + (fragSizeX * cos(state * 2 * PI)) - (fragSizeX * mul * cos(state * 2 * PI));
		yB = fragSizeY * 1.1 * y + (fragSizeY * sin(state * 2 * PI)) - (fragSizeY * mul * sin(state * 2 * PI));
		zF = zD = 0;
		
		xL -= _halfX;
		yB -= _halfY;
				
		red = abs(patternLib[3].colormap - state);
		green = abs(patternLib[3].colormap - state);
		blue = abs(patternLib[3].colormap - state);
		alpha = abs(patternLib[3].alphamap - state);
		alpha *= patternLib[3].alpha;
		
		gl::color(red, green, blue, alpha);
		
//		dist = sqrt(pow(currentNode->neighbors[3]->x - (_world->sizeX() * 0.5f), 2) + pow(currentNode->neighbors[3]->y - (_world->sizeY() * 0.5f), 2));
//		mul = linlin(maxdist - dist, 0, maxdist, 1.0, 4.0);
//		
//		eState = currentNode->neighbors[3]->phase;
//		xW = fragSizeX * 1.1 * x + (fragSizeX * cos(eState * 2 * PI)) - (fragSizeX * mul * cos(eState * 2 * PI));
//		yH = fragSizeY * 1.1 * (y - 1) + (fragSizeY * sin(eState * 2 * PI)) - (fragSizeY * mul * sin(eState * 2 * PI));
//
//		gl::drawLine(Vec2f(xL, yB), Vec2f(xW, yH));
				
		dist = sqrt(pow(currentNode->neighbors[0]->x - (_world->sizeX() * 0.5f), 2) + pow(currentNode->neighbors[0]->y - (_world->sizeY() * 0.5f), 2));
		mul = linlin(maxdist - dist, 0, maxdist, 1.0, 2.0);
				
		eState = currentNode->neighbors[0]->phase;				
		xW = fragSizeX * 1.1 * (x - 1) + (fragSizeX * cos(eState * 2 * PI)) - (fragSizeX * mul * cos(eState * 2 * PI));
		yH = fragSizeY * 1.1 * (y - 1) + (fragSizeY * sin(eState * 2 * PI)) - (fragSizeY * mul * sin(eState * 2 * PI));
		
		xW -= _halfX;
		yH -= _halfY;
				
		gl::drawLine(Vec2f(xL, yB), Vec2f(xW, yH));
		
//		dist = sqrt(pow(currentNode->neighbors[1]->x - (_world->sizeX() * 0.5f), 2) + pow(currentNode->neighbors[1]->y - (_world->sizeY() * 0.5f), 2));
//		mul = linlin(maxdist - dist, 0, maxdist, 1.0, 2.0);
//		
//		eState = currentNode->neighbors[1]->phase;				
//		xW = fragSizeX * 1.1 * (x - 1) + (fragSizeX * cos(eState * 2 * PI)) - (fragSizeX * mul * cos(eState * 2 * PI));
//		yH = fragSizeY * 1.1 * y + (fragSizeY * sin(eState * 2 * PI)) - (fragSizeY * mul * sin(eState * 2 * PI));
//		
//		gl::drawLine(Vec2f(xL, yB), Vec2f(xW, yH));

		dist = sqrt(pow(currentNode->neighbors[2]->x - (_world->sizeX() * 0.5f), 2) + pow(currentNode->neighbors[2]->y - (_world->sizeY() * 0.5f), 2));
		mul = linlin(maxdist - dist, 0, maxdist, 1.0, 2.0);
		
		eState = currentNode->neighbors[2]->phase;				
		xW = fragSizeX * 1.1 * (x - 1) + (fragSizeX * cos(eState * 2 * PI)) - (fragSizeX * mul * cos(eState * 2 * PI));
		yH = fragSizeY * 1.1 * (y + 1) + (fragSizeY * sin(eState * 2 * PI)) - (fragSizeY * mul * sin(eState * 2 * PI));

		xW -= _halfX;
		yH -= _halfY;
		
		gl::drawLine(Vec2f(xL, yB), Vec2f(xW, yH));
	}
		
}

void GraphicsRenderer::pattern04(int x, int y) {
	
//	int i;
	float xx, yy;
	
	xx = fragSizeX * cos((state + (x + 1 / _world->sizeX())) * (2 * PI));
	yy = fragSizeY * sin((state * 2.0f + (y + 1 / _world->sizeY())) * (2 * PI));
		
	xL = x * fragSizeX + xx;
	yB = (_winHeight * 0.5f) + (((_winHeight * 0.5f) - (y * fragSizeY)) * 0.5f) + yy;

	xL -= _halfX;
	yB -= _halfY;
	
	red = abs(patternLib[4].colormap - state);
	green = abs(patternLib[4].colormap - state);
	blue = abs(patternLib[4].colormap - state);
	alpha = abs(patternLib[4].alphamap - state);
	alpha *= patternLib[4].alpha;
	
	gl::color(red, green, blue, alpha);		
	
	glLineWidth(mapf(state, 1.0f, 2.0f));
	
	gl::drawLine(Vec2f(xL, yB), Vec2f(xL+1.0,yB+1.0));

	glLineWidth(1.0f);

	xx = fragSizeX * sin((state + (x + 1 / 40)) * (2 * PI));
	yy = fragSizeY * cos((state + (y + 1 / 40)) * (2 * PI));
		
	xL = x * fragSizeX + xx;
	yB = (_winHeight * 0.5f) + (((_winHeight * 0.5f) - (y * fragSizeY)) * 0.5f) + yy;
	
	xL -= _halfX;
	yB -= _halfY;
	
	glLineWidth(mapf(1.0 - state, 1.0f, 2.0f));
	
	gl::drawLine(Vec2f(xL, yB), Vec2f(xL+1.0,yB+1.0));
	
	glLineWidth(1.0f);
	
}

void GraphicsRenderer::pattern05(int x, int y) {
	
	Vec3f sphereLoc, dirFromLight;
	float distFromLight, distFromLightPer;
	
	xL = x * fragSizeX + fragSizeX - (fragSizeX * state);
	xW = fragSizeX * state * 2.0;
	
	yB = y * fragSizeY + fragSizeY - (fragSizeY * state);
	yH = fragSizeY * state * 2.0;
	
	zF = fragSizeX * state * -2.0;
	
	xL -= _halfX;
	yB -= _halfY;
	
	red = abs(patternLib[5].colormap - state);
	green = abs(patternLib[5].colormap - state);
	blue = abs(patternLib[5].colormap - state);
	alpha = abs(patternLib[5].alphamap - state);
	alpha *= patternLib[5].alpha;
	
	sphereLoc = Vec3f( xL + cos(fragSizeX * (2*PI*(state))), yB + sin(fragSizeY * (2*PI*state)), zF );
	dirFromLight = sphereLoc - mLightLoc;
	distFromLight = dirFromLight.length();
	
	distFromLightPer = 1.20f - distFromLight/300.0f;
	
	if (distFromLightPer < 0.0f) distFromLightPer = 0.0f;
	distFromLightPer = pow( distFromLightPer, 10.0f );
	
	if (distFromLight < 200.0)
	{
		
		if (bLIGHT) {
			
			ci::ColorA color(CM_HSV, red, green, blue, alpha);
			
			glMaterialfv(GL_FRONT, GL_DIFFUSE, color);
			glMaterialfv(GL_FRONT, GL_AMBIENT, mat_ambient);
			glMaterialfv(GL_FRONT, GL_SPECULAR, mat_specular);
			glMaterialfv(GL_FRONT, GL_SHININESS, mat_shininess);
			glMaterialfv(GL_FRONT, GL_EMISSION, mat_emission);
		}
		else
		{
			glMaterialfv( GL_FRONT, GL_DIFFUSE,	no_mat );
			glMaterialfv( GL_FRONT, GL_AMBIENT,	no_mat );
			glMaterialfv( GL_FRONT, GL_SPECULAR, no_mat );
			glMaterialfv( GL_FRONT, GL_SHININESS, no_shininess );
			glMaterialfv( GL_FRONT, GL_EMISSION, no_mat );	
		}
		
		if ( bSHADER ) {
			mShader.bind();
			mShader.uniform( "NumEnabledLights", 1 );
		}
		
		gl::drawSolidRect( Rectf(xL, yB, xL + xW, yB + xW ) );
			
//		gl::drawSphere( sphereLoc, xW, 16 );
		
		if ( mShader) mShader.unbind();
	}
}

void GraphicsRenderer::pattern06(int x, int y) {
	
	int i, pts;
	float xx, yy;
	float alphas[] = { 1.0, 0.8, 0.7 };
	
	pts = 3;
	
	for (i = 0; i < pts; i++) {
	
		xx = fragSizeX * cos( (currentNode->states[i] ) * (4 * PI));
		yy = fragSizeY * sin( (currentNode->states[i] ) * (4 * PI));
				
		xL = x * fragSizeX + xx;
		yB = y * fragSizeY + yy;
		
		xL -= _halfX;
		yB -= _halfY;
				
		red = abs(patternLib[6].colormap - state);
		green = abs(patternLib[6].colormap - state);
		blue = abs(patternLib[6].colormap - state);
		alpha = abs(patternLib[6].alphamap - state);
		alpha *= (patternLib[6].alpha * alphas[i]);
		
		drawPoint(xL, yB, 0.0, 2.0);
	}
			
}

void GraphicsRenderer::pattern07(int x, int y) {
	
	int i, count;
	float xx, yy;
	
	if ( (isEven(x) && isEven(y)) || ( !isEven(x) && !isEven(y) ) )
	{
		xL = (x * fragSizeX + (fragSizeX * cosf(state * 2.0 * PI))) - (fragSizeX * 2.0 * cosf(state * 2.0 * PI));
		yB = (y * fragSizeY + (fragSizeY * sinf(state * 2.0 * PI))) - (fragSizeY * 2.0 * sinf(state * 2.0 * PI));
	}
	else
	{
		xL = (x * fragSizeX + (fragSizeX * sinf(state * 2.0 * PI))) - (fragSizeX * 2.0 * sinf(state * 2.0 * PI));
		yB = (y * fragSizeY + (fragSizeY * cosf(state * 2.0 * PI))) - (fragSizeX * 2.0 * cosf(state * 2.0 * PI));	
	}
		
	xL -= _halfX;
	yB -= _halfY;
	
	red = abs(patternLib[7].colormap - state);
	green = abs(patternLib[7].colormap - state);
	blue = abs(patternLib[7].colormap - state);
	alpha = abs(patternLib[7].alphamap - state);
	alpha *= patternLib[7].alpha;
	
	gl::color( red, green, blue, alpha );
	
	xW = fragSizeX * 2.0;
	yH = fragSizeY * 2.0;
	
	count = 8;

	for (i = 0; i < count; i++) {
		
		xx = xL + (xW * cosf( (PI*state) * (((float)i/(float)count) * (2.0*PI)) ) );
		yy = yB + (yH * sinf( (PI*state) * (((float)i/(float)count) * (2.0*PI)) ) );
		
		drawLine(xL, yB, state * -1.0,  xx, yy, state * -2.0, 1.0f);
		
	}
	
}

void GraphicsRenderer::pattern08(int x, int y) {
	
	xL = x * fragSizeX + fragSizeX - (fragSizeX * 2.0 * state);
	yB = y * fragSizeY + (fragSizeY * 0.5);
	zF = zD = fragSizeX * sin(state);
	
	xL -= _halfX;
	yB -= _halfY;
	
	yB += (fragSizeY * 4.0 * sin(state * 2 * pi)) - (fragSizeY * 8.0 * sin(state * 2 * PI));
	
	xW = fragSizeX * state * 4.0;
	yH = yB;
			
	red = abs(patternLib[8].colormap - state);
	green = abs(patternLib[8].colormap - state);
	blue = abs(patternLib[8].colormap - state);
	alpha = abs(patternLib[8].alphamap - state);
	alpha *= patternLib[8].alpha;
		
	gl::color(red, green, blue, alpha);
	gl::drawLine( Vec3f(xL, yB, zF), Vec3f(xL+xW, yH, zD) );
	
}

void GraphicsRenderer::pattern09(int x, int y) {
	
	red = abs(patternLib[9].colormap - state);
	green = abs(patternLib[9].colormap - state);
	blue = abs(patternLib[9].colormap - state);
	alpha = abs(patternLib[9].alphamap - state);
	alpha *= patternLib[9].alpha;

	xL = x * fragSizeX + (fragSizeX * 0.25);
	yB = y * fragSizeY + (fragSizeY * 0.25);

	xW = fragSizeX * state * 2.0;

	zF = fragSizeX * state * 2.0;
	
	xL -= _halfX;
	yB -= _halfY;
	
	gl::color(red, green, blue, alpha);
	
	gl::drawLine( Vec3f(xL, yB, zF), Vec3f(xL + xW, yB, zF) );

	xL = x * fragSizeX + (fragSizeX * 0.75);
	yB = y * fragSizeY + (fragSizeY * 0.75);

	xW = fragSizeX * state * -2.0;
		
	xL -= _halfX;
	yB -= _halfY;	
	
	gl::drawLine( Vec3f(xL, yB, zF), Vec3f(xL + xW, yB, zF) );

	red = 1.0 - abs(patternLib[9].colormap - state);
	green = 1.0 - abs(patternLib[9].colormap - state);
	blue = 1.0 - abs(patternLib[9].colormap - state);
	alpha = 1.0 - abs(patternLib[9].alphamap - state);
	alpha *= patternLib[9].alpha;
	
	xL = x * fragSizeX + (fragSizeX * 0.75);
	yB = y * fragSizeY + (fragSizeY * 0.25);
	
	yH = fragSizeX * state * 2.0;
		
	xL -= _halfX;
	yB -= _halfY;
	
	gl::color(red, green, blue, alpha);
		
	gl::drawLine( Vec3f(xL, yB, zF), Vec3f(xL, yB + yH, zF) );
	
	xL = x * fragSizeX + (fragSizeX * 0.25);
	yB = y * fragSizeY + (fragSizeY * 0.75);
	
	yH = fragSizeX * state * -2.0;
	
	xL -= _halfX;
	yB -= _halfY;	
	
	gl::drawLine( Vec3f(xL, yB, zF), Vec3f(xL, yB + yH, zF) );

}

void GraphicsRenderer::pattern10(int x, int y) {
	
	if (state > 0.0) {

		float unmap;

		unmap = unmapf(state, 0, _world->numStates()-1);
		
		xL = x * fragSizeX + fragSizeX - (fragSizeX * 10.0 * unmap);
		yB = (_winHeight * 0.5f) + (((_winHeight * 0.5f) - (y * fragSizeY)) * 0.5f);
		zF = zD = 0.0;
		
		xL -= _halfX;
		yB -= _halfY;
		
		xW = fragSizeX * unmap * 20.0;
		yH = fragSizeY * unmap * 0.1;
		
		red = abs(patternLib[10].colormap - unmap);
		green = abs(patternLib[10].colormap - unmap);
		blue = abs(patternLib[10].colormap - unmap);
		alpha = abs(patternLib[10].alphamap - unmap);
		alpha *= patternLib[10].alpha;
		
		gl::color(red, green, blue, alpha);
		gl::drawStrokedRect(Rectf(xL, yB, xL + xW, yB + yH));
		
	}
}

void GraphicsRenderer::pattern11(int x, int y) {
	
	if (state > 0.0) {

		float unmap;

		unmap = unmapf(state, 0, _world->numStates()-1);
				
		xL = (_winWidth * 0.5f) + (((_winWidth * 0.5f) - (x * fragSizeX)) * 0.4f);
		yB = y * fragSizeY + fragSizeY - (fragSizeY * 10.0 * unmap);
		zF = zD = 0.0;
		
		xL -= _halfX;
		yB -= _halfY;
		
		xW = fragSizeX * unmap * 0.2;
		yH = fragSizeY * unmap * 20.0;
		
		red = abs(patternLib[11].colormap - unmap);
		green = abs(patternLib[11].colormap - unmap);
		blue = abs(patternLib[11].colormap - unmap);
		alpha = abs(patternLib[11].alphamap - unmap);
		alpha *= patternLib[11].alpha;
		
		gl::color(red, green, blue, alpha);
		gl::drawSolidRect(Rectf(xL, yB, xL + xW, yB + yH));
	}	
}

void GraphicsRenderer::pattern12(int x, int y) {

	if (state > 0.0) {
		
		float lenX, lenY, unmap;
		
		unmap = unmapf(state, 0, _world->numStates()-1);
			
		xL = x * fragSizeX + (fragSizeX * 0.5f);
		yB = y * fragSizeY + (fragSizeY * 0.5f);
		
		xL -= _halfX;
		yB -= _halfY;
		
		lenX = fragSizeX * unmap * 8.0;
		lenY = fragSizeY * unmap * 8.0;
		
		red = abs(patternLib[12].colormap - unmap);
		green = abs(patternLib[12].colormap - unmap);
		blue = abs(patternLib[12].colormap - unmap);
		alpha = abs(patternLib[12].alphamap - unmap);
		alpha *= patternLib[12].alpha;
		
		gl::color(red, green, blue, alpha);
		
		gl::drawLine( Vec2f(xL, yB-lenY), Vec2f(xL, yB+lenY) );
		
		lenY *= currentNode->weights[0];
		gl::drawLine( Vec2f(xL - (fragSizeX * 0.25), yB-lenY), Vec2f(xL - (fragSizeX * 0.25), yB+lenY) );
		
		lenY *= currentNode->weights[1];
		gl::drawLine( Vec2f(xL + (fragSizeX * 0.25), yB-lenY), Vec2f(xL + (fragSizeX * 0.25), yB+lenY) );
		
		

	}
	
}

void GraphicsRenderer::pattern13(int x, int y) {
	if (state > 0.0) {
		
		float lenX, lenY, unmap;
		
		unmap = unmapf(state, 0, _world->numStates()-1);
		
		xL = x * fragSizeX + (fragSizeX * 0.5f);
		yB = y * fragSizeY + (fragSizeY * 0.5f);
		
		xL -= _halfX;
		yB -= _halfY;
		
		lenX = fragSizeX * unmap * 8.0;
		lenY = fragSizeY * unmap * 8.0;
		
		red = abs(patternLib[13].colormap - unmap);
		green = abs(patternLib[13].colormap - unmap);
		blue = abs(patternLib[13].colormap - unmap);
		alpha = abs(patternLib[13].alphamap - unmap);
		alpha = patternLib[13].alpha;
		
		gl::color(red, green, blue, alpha);
		
		gl::drawLine( Vec2f(xL-lenX, yB), Vec2f(xL+lenX, yB) );
				
		lenX *= currentNode->weights[2];
		
		glBegin(GL_LINES);
		
		gl::color(red * currentNode->weights[0], green * currentNode->weights[1], blue * currentNode->weights[2], alpha);
				
		gl::vertex( Vec2f(xL - lenX, yB - (fragSizeY * 0.25)) );
		
		gl::color(red * currentNode->weights[2], green * currentNode->weights[1], blue * currentNode->weights[0], alpha);
		
		gl::vertex( Vec2f(xL + lenX, yB - (fragSizeY * 0.25)) );
		
		lenX *= currentNode->weights[3];

		gl::color(red * currentNode->weights[0], green * currentNode->weights[1], blue * currentNode->weights[2], alpha);

		gl::vertex( Vec2f(xL - lenX, yB + (fragSizeY * 0.25)) );

		gl::color(red * currentNode->weights[2], green * currentNode->weights[1], blue * currentNode->weights[0], alpha);

		gl::vertex( Vec2f(xL + lenX, yB + (fragSizeY * 0.25)) );
		
		glEnd();
		
	}
	
}

void GraphicsRenderer::pattern14(int x, int y) {

	if (state > 0.0) {
	
		float max, dist, unmap, step;

		unmap = unmapf(state, 0, _world->numStates()-1);

		max = getWindowHeight() * 0.5;
		
		dist = max - (x + 1 * _world->sizeX());
		step = (2*PI) / _world->sizeY();
		
		xL = dist * cos( step * y );
		yB = dist * sin( step * y );
		
		xW = dist * cos( step * (y + 1));
		yH = dist * sin( step * (y + 1));
		
		zF = (fragSizeX * x) - 700.0f;
		
		red = abs(patternLib[14].colormap - unmap);
		green = abs(patternLib[14].colormap - unmap);
		blue = abs(patternLib[14].colormap - unmap);
		alpha = abs(patternLib[14].alphamap - unmap);
		alpha *= patternLib[14].alpha;

		glLineWidth(unmap * 4.0f);
		
		glBegin(GL_LINE_STRIP);
		
		gl::color( red, green, blue, alpha );

		gl::vertex( Vec3f(xL, yB, zF) );
		
		gl::color( red*unmap, green*unmap, blue*unmap, alpha*unmap );
		
		gl::vertex( Vec3f(xW, yH, zF) );
		
		glEnd();
		
		glLineWidth(1.0f);
				
	}
}

void GraphicsRenderer::pattern15(int x, int y) {

	if (x != 0 && y != 0 && x < _world->sizeX() && y < _world->sizeY() && state > 0.0) {
		
		float unmap, unother;
		int i;
		
		unmap = unmapf(state, 0, _world->numStates()-1);
		
		xL = x * fragSizeX + (fragSizeX * 0.5);
		yB = y * fragSizeY + (fragSizeY * 0.5);
		
		xL -= _halfX;
		yB -= _halfY;

		zF = fragSizeX * unmap * -4.0;

		red = 0.0;
		green = 0.5;
		blue = abs(patternLib[15].colormap - unmap);
		alpha = abs(patternLib[15].alphamap - unmap);
		alpha *= patternLib[15].alpha;
		
		gl::color(red, green, blue, alpha * unmap);
				
		gl::drawSphere( Vec3f(xL, yB, zF), fragSizeY * 0.3, 4 );
		
		for (i = 0; i < 8; i++) {
			
			if (currentNode->neighbors[i]->states[currentIndex] > 0.0) {
				xW = currentNode->neighbors[i]->x * fragSizeX + (fragSizeX * 0.5);
				yH = currentNode->neighbors[i]->y * fragSizeY + (fragSizeY * 0.5);
				
				xW -= _halfX;
				yH -= _halfY;
				
				unother = unmapf(currentNode->neighbors[i]->states[currentIndex], 0, _world->numStates()-1);
				
				zD = fragSizeX * unother * -4.0;

				red = 0.0;
				green = 0.5;
				blue = abs(patternLib[13].colormap - unother);
				alpha = abs(patternLib[13].alphamap - unother);
				alpha = patternLib[13].alpha;
				
				gl::color( red, green, blue, alpha );
				gl::drawLine( Vec3f(xL, yB, zF), Vec3f(xW, yH, zD) );
				
			}
			
		}
		
	}

}

void GraphicsRenderer::pattern16(int x, int y) {
		
	if (state > 0.0) {
		
		float t, c, unmap, w, h;

		float rx= sin(_fCounter*0.025f);
		float ry= sin(_fCounter*0.025f+1.0f);
		float tx= sin(_fCounter*0.020f+2.0f)+rx;
		float ty= sin(_fCounter*0.020f+3.0f)+ry;
		
		unmap = unmapf(state, 0, _world->numStates()-1);
		
		w = x*fragSizeX + (fragSizeX * unmap);
		h = y*fragSizeY + (fragSizeY * unmap);
		
		w -= _halfX;
		h -= _halfY;

		red = abs(patternLib[16].colormap - unmap);
		green = abs(patternLib[16].colormap - unmap);
		blue = abs(patternLib[16].colormap - unmap);
		alpha = abs(patternLib[16].alphamap - unmap);
		alpha *= patternLib[16].alpha;
		t = ((float)x + 50.0f) / (_world->sizeX() + 50.0);
		c= sin(t*PI*2)*0.5f+0.5f;
		xL = (sin(t*PI*2*rx*tx)*0.495f*t*0.5f)*w;
		yB = (cos(t*PI*2*ry*ty)*0.495f*t+0.5f)*h;
		
		xW = (cos(t*PI*2*rx*tx)*0.495f*t+0.5f)*w;
		yH = (sin(t*PI*2*rx*tx)*0.495f*t*0.5f)*h;
		
		glLineWidth(unmap * 4.0f);
		gl::enable(GL_LINE_STIPPLE);
		glLineStipple(3, (GLushort)state);
		gl::color( red*c, green, blue, alpha );
		gl::drawLine( Vec3f(xL, yB, mapf(unmap, 14.0, -14.0)), Vec3f(xW, yH, mapf(unmap, 14.0, -14.0)) );
		gl::disable(GL_LINE_STIPPLE);
		glLineWidth(1.0f);
	}
}

void GraphicsRenderer::pattern17(int x, int y) {
	
	if (state > 0.0) {
		
		float unmap;

		unmap = unmapf(state, 0, _world->numStates()-1);
		
		xL = x * fragSizeX + fragSizeX - (fragSizeX * unmap);
		xW = fragSizeX * unmap * 2.0;
		
		xL -= _halfX;
		
		zF = y * fragSizeX + fragSizeX - (fragSizeX * unmap);
		zD = fragSizeX * unmap * 2.0;
		
		yB = getWindowHeight() * 0.333 - _halfY;
		
		red = abs(patternLib[17].colormap - unmap);
		green = abs(patternLib[17].colormap - unmap);
		blue = abs(patternLib[17].colormap - unmap);
		alpha = abs(patternLib[17].alphamap - unmap);
		alpha *= patternLib[17].alpha;
		
		gl::color( red, green, blue, alpha );
		
		fillRect(2);

		yB = getWindowHeight() * 0.667 - _halfY;

		gl::color( 1.0-red, 1.0-green, 1.0-blue, 1.0-alpha );

		strokeRect(2, 2.0);

	}	
}

void GraphicsRenderer::pattern18(int x, int y) {

	if (state > 0.0) {
		
		float unmap;
		
		unmap = unmapf(state, 0, _world->numStates()-1);
		
		xL = x * fragSizeX + fragSizeX - (fragSizeX * 2.0 * unmap);
		yB = y * fragSizeY + fragSizeY - (fragSizeY * 2.0 * unmap);
		zF = zD = 0.0;
		
		xL -= _halfX;
		yB -= _halfY;
		
		xW = fragSizeX * unmap * 4.0;
		yH = fragSizeY * unmap * 4.0;
		
		red = 0.0 * abs(patternLib[18].colormap - unmap);
		green = 0.6 * abs(patternLib[18].colormap - unmap);
		blue = 1.0 * abs(patternLib[18].colormap - unmap);
		alpha = abs(patternLib[18].alphamap - unmap);
		alpha *= patternLib[18].alpha;
		
		strokeRect(0, 1.0);		
	
	}	
	
	if (currentNode->states[(int)wrapf(_world->index() - 1, 0, 2)] > 0.0) {

		float unmap, pstate;
		
		pstate = currentNode->states[(int)wrapf(_world->index() - 1, 0, 2)];
		
		unmap = unmapf(pstate, 0, _world->numStates()-1);
		
		xL = x * fragSizeX + fragSizeX - (fragSizeX * 2.0 * unmap);
		yB = y * fragSizeY + fragSizeY - (fragSizeY * 2.0 * unmap);
		zF = zD = fragSizeX + (fragSizeX * state * -2.0);
		
		xL -= _halfX;
		yB -= _halfY;
		
		xW = fragSizeX * unmap * 4.0;
		yH = fragSizeY * unmap * 4.0;
		
		red = 0.0 * abs(patternLib[18].colormap - unmap);
		green = 0.6 * abs(patternLib[18].colormap - unmap);
		blue = 1.0 * abs(patternLib[18].colormap - unmap);
		alpha = abs(patternLib[18].alphamap - unmap);
		alpha *= patternLib[18].alpha;

		strokeRect(0, 1.0);
				
	}
	
}

void GraphicsRenderer::pattern19(int x, int y) {
	
	if (state > 0.0) {
		
		float unmap;
		
		unmap = unmapf(state, 0, _world->numStates()-1);
		
		xL = x * fragSizeX + fragSizeX - (fragSizeX * unmap);
		yB = y * fragSizeY + fragSizeY - (fragSizeY * unmap);
		zF = zD = 0.0;
		
		xL -= _halfX;
		yB -= _halfY;
		
		xW = fragSizeX * unmap * 2.0;
		yH = fragSizeY * unmap * 2.0;
		
		red = 0.0 * abs(patternLib[19].colormap - unmap);
		green = 0.6 * abs(patternLib[19].colormap - unmap);
		blue = 1.0 * abs(patternLib[19].colormap - unmap);
		alpha = abs(patternLib[19].alphamap - unmap);
		alpha *= patternLib[19].alpha;
		
		gl::color(red, green, blue, alpha);
		gl::drawSolidRect(Rectf(xL, yB, xL + xW, yB + yH));
		
	}	
}

void GraphicsRenderer::strokeRectArray() {
	
	GLfloat vertices[] = {
		xL, yB, zF,				xL + xW, yB, zF,
		xL + xW, yB, zF,		xL + xW, yB + yH, zF,
		xL + xW, yB + yH, zF,	xL, yB + yH, zF,
		xL, yB + yH, zF,		xL, yB, zF
	};
	
	GLfloat normals[] = {
		0, 0, 1,				0, 0, 1,
		0, 0, 1,				0, 0, 1,
		0, 0, 1,				0, 0, 1,
		0, 0, 1,				0, 0, 1
	};
	
	GLfloat colors[] = {
		red, green, blue, alpha,	red, green, blue, alpha,
		red, green, blue, alpha,	red, green, blue, alpha,
		red, green, blue, alpha,	red, green, blue, alpha,
		red, green, blue, alpha,	red, green, blue, alpha
	};
	
	glEnableClientState(GL_NORMAL_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_VERTEX_ARRAY);
	
	glNormalPointer(GL_FLOAT, 0, normals);
	glColorPointer(4, GL_FLOAT, 0, colors);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	
	glEnable(GL_LINE_SMOOTH);
	
	glDrawArrays(GL_LINES, 0, 8);
	
	glDisable(GL_LINE_SMOOTH);
		
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_NORMAL_ARRAY);
	
}

void GraphicsRenderer::fillRect (int plane) {
	glColor4f(red, green, blue, alpha);
	glEnable(GL_POLYGON_SMOOTH);
	glBegin(GL_POLYGON);
	
	switch (plane)
	{
		case 0:
			glVertex3f (xL, yB, zF);
			glVertex3f (xL + xW, yB, zF);
			
			glVertex3f (xL + xW, yB, zF);
			glVertex3f (xL + xW, yB + yH, zF);
			
			glVertex3f (xL + xW, yB + yH, zF);
			glVertex3f (xL, yB + yH, zF);
			
			glVertex3f (xL, yB + yH, zF);
			glVertex3f (xL, yB, zF);
			
			break;
			
		case 1:
			glVertex3f (xL, yB, zF);
			glVertex3f (xL, yB, zF + zD);
			
			glVertex3f (xL, yB, zF + zD);
			glVertex3f (xL, yB + yH, zF + zD);
			
			glVertex3f (xL, yB + yH, zF + zD);
			glVertex3f (xL, yB + yH, zF);
			
			glVertex3f (xL, yB + yH, zF);
			glVertex3f (xL, yB, zF);
			
			break;
			
		case 2:
			glVertex3f (xL, yB, zF);
			glVertex3f (xL + xW, yB, zF);
			
			glVertex3f (xL + xW, yB, zF);
			glVertex3f (xL + xW, yB, zF + zD);
			
			glVertex3f (xL + xW, yB, zF + zD);
			glVertex3f (xL, yB, zF + zD);
			
			glVertex3f (xL, yB, zF + zD);
			glVertex3f (xL, yB, zF);
			
			break;
			
	}
	
	glEnd();
	glDisable(GL_POLYGON_SMOOTH);
	
}

void GraphicsRenderer::strokeRect (int plane, float lineWidth) {
	glColor4f(red, green, blue, alpha);
	glEnable(GL_LINE_SMOOTH);
	glLineWidth(lineWidth);
	glBegin(GL_LINES);
	
	switch (plane)
	{
		case 0:
			glVertex3f (xL, yB, zF);
			glVertex3f (xL + xW, yB, zF);
			
			glVertex3f (xL + xW, yB, zF);
			glVertex3f (xL + xW, yB + yH, zF);
			
			glVertex3f (xL + xW, yB + yH, zF);
			glVertex3f (xL, yB + yH, zF);
			
			glVertex3f (xL, yB + yH, zF);
			glVertex3f (xL, yB, zF);
			
			break;
			
		case 1:
			glVertex3f (xL, yB, zF);
			glVertex3f (xL, yB, zF + zD);
			
			glVertex3f (xL, yB, zF + zD);
			glVertex3f (xL, yB + yH, zF + zD);
			
			glVertex3f (xL, yB + yH, zF + zD);
			glVertex3f (xL, yB + yH, zF);
			
			glVertex3f (xL, yB + yH, zF);
			glVertex3f (xL, yB, zF);
			
			break;
			
		case 2:
			glVertex3f (xL, yB, zF);
			glVertex3f (xL + xW, yB, zF);
			
			glVertex3f (xL + xW, yB, zF);
			glVertex3f (xL + xW, yB, zF + zD);
			
			glVertex3f (xL + xW, yB, zF + zD);
			glVertex3f (xL, yB, zF + zD);
			
			glVertex3f (xL, yB, zF + zD);
			glVertex3f (xL, yB, zF);
			
			break;
			
	}
	
	
	glEnd();
	glDisable(GL_LINE_SMOOTH);
}

void GraphicsRenderer::drawPoint (float x, float y, float z, float sz) {
	glColor4f(red, green, blue, alpha);
	glEnable(GL_POINT_SMOOTH);
	glPointSize(sz);
	glBegin(GL_POINTS);
	glVertex3f(x, y, z);
	glEnd();
	glDisable(GL_POINT_SMOOTH);
}


void GraphicsRenderer::drawLine (float startx, float starty, float startz, float endx, float endy, float endz, float lineWidth) {
	glColor4f(red, green, blue, alpha);
	glEnable(GL_LINE_SMOOTH);
	glLineWidth(lineWidth);
	glBegin(GL_LINES);
	
	glVertex3f(startx, starty, startz);
	glVertex3f(endx, endy, endz);
	
	glEnd();
	glDisable(GL_LINE_SMOOTH);
}

void GraphicsRenderer::drawCircle (int plane, float r, int num_segments, bool fill) { 
	int i;
	float theta, tangetial_factor, radial_factor, x, y;
	theta = 2 * PI / num_segments;
	tangetial_factor = tanf(theta);
	radial_factor = cosf(theta);
	x = r;
	y = 0;
	
	if (fill) {
		glBegin(GL_POLYGON);	
	}
	{
		glBegin(GL_LINE_LOOP);
	}
	glColor4f(red, green, blue, alpha);
	for(i = 0; i < num_segments; i++) 
	{ 
		switch (plane) {
			case 0:
				glVertex3f(x + xL, y + yB, zF);
				break;
			case 1: 
				glVertex3f(xL, x + yB, y + zF);
				break;
			case 2:
				glVertex3f(y + xL, yB, x + zF);
				break;
		}
		
        
		float tx = -y; 
		float ty = x; 
		x += tx * tangetial_factor; 
		y += ty * tangetial_factor; 
		x *= radial_factor; 
		y *= radial_factor; 
	} 
	glEnd(); 
}


/*	
 was pattern05, promising but not quite
 
 zF = y * fragSizeX + fragSizeX - (fragSizeX * 0.5 * state);
 zD = fragSizeX * state;
 
 yB = getWindowHeight() * 0.333 - _halfY;
 
 
 gl::color( red, green, blue, alpha );
 
 if (isEven(y))
 fillRect(2);
 else
 strokeRect(2, 1.0);
 
 
 zF -= getWindowWidth();
 
 if (!isEven(y))
 strokeRect(2, 2.0);	
 else
 fillRect(2);
 
 zF = y * fragSizeX + fragSizeX - (fragSizeX * 0.5 * state);
 
 yB = getWindowHeight() * 0.667 - _halfY;
 
 gl::color( 1.0-red, 1.0-green, 1.0-blue, 1.0-alpha );
 
 if (isEven(y))
 strokeRect(2, 2.0);
 else
 fillRect(2);
 
 zF -= getWindowWidth();
 
 if (isEven(2))
 fillRect(2);
 else
 strokeRect(2, 1.0);
 */


