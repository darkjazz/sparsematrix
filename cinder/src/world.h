/*
 *  world.h
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
#ifndef WORLD_H
#define WORLD_H

#include <vector>
#include <iostream>
#include <math.h>
#include <assert.h>

#include "util.h"

using namespace std;

enum Interpolation { NONE, LINEAR, COSINE };
enum Symmetry { ZERO, AX, AY, DIAG, QUAD };

class Node {
public:
	Node() : x(0), y(0) {};
	~Node() {};
	vector<double> weights;	
	int x, y; 
	double states[3];
	double phase;
	Node* neighbors[8];
	
	double difference (vector<double>);
	void update (vector<double>, double, double);
	void nextState (double, int);
	void nextState (double, int, bool);
	void nextPhase (int, int, Interpolation, int);
	void nextGeneration(int*, int*, int, int);
	int countAliveNeighbors(int);
	
};

class World {
	
public:
	World();
	~World();
	void init(int, int, int, int, double);
	void clear();
//	void setNeighborWeights(vector<double>);
	Node** nodes;
	int vectorSize() { return _vectorSize; };
	void setAdd (double);
	void setSymmetry(Symmetry sym) { _sym = sym; };
	void resetAverageState() { _avg = 0; }
	void incrementAverageState(double value) { _avg += value; };
	void finalizeAverageState() { _avg = _avg / (_sizeX * _sizeY); };
	
	int index() { return _index; };
	int sizeX() { return _sizeX; };
	int sizeY() { return _sizeY; };
	double add() { return _add; };
	int interpCount() { return _interpCount; };
	int interpPhase() { return _interpPhase; };
	double averageState() { return _avg; };
	Interpolation interpType() { return _interpType; };
	double cellState(int, int);
	void setStates(int numStates) { _numStates = numStates; };
	int numStates() { return _numStates; };
	
	Node* findBMU();
	void train(Node*, Node*);

	void incrementTrainCount();
	void incrementIndex();
	void nextPhase() { _interpPhase++; };
	int nextIndex();
	void setCells(int, int);
	
	void nextGeneration(int, int);
	
	void setBirths(int*);
	void setSurvivals(int*);
		
	void setInterpolation(Interpolation, int);
	
	void mapStates(bool);

	vector<double> neighborWeights;
	vector<double> inputWeights;
	
	bool bmuInitialized;

private:
	int _vectorSize, _sizeX, _sizeY, _trainDur, _trainCount, _index, _phase;
	double _initLearningRate, _learningRate, _mapRadius, _timeConst, _add, _avg;
	Interpolation _interpType;
	Symmetry _sym;
	int _interpCount, _interpPhase, _numStates;
	int *_births, *_survivals;
};


#endif