/*
 *  world.cpp
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

#include "world.h"

/* ****** NODE ****** */

double Node::difference (vector<double> compareVector) {
	double diff;
	int i;
	diff = 0.0;
	for (i = 0; i < compareVector.size(); i++) {
		diff += pow(weights[i] - compareVector[i] , 2);
	}
	
	return diff;
}

void Node::update (vector<double> inputVector, double learningRate, double influence) {
	int i;
	
	for (i = 0; i < inputVector.size(); i++)
		weights[i] = weights[i] + ((inputVector[i] - weights[i]) * learningRate * influence);

}

void Node::nextPhase (int interpIndex, int worldIndex, Interpolation interp, int interpCount) {

	if (interpCount < 1) 
		interpCount = 1;
	
	switch (interp) {
		case LINEAR:
			phase = linInterp(states[wrapi(worldIndex - 1, 0, 2)], states[worldIndex], interpIndex / interpCount);
			break;
		case COSINE:
			phase = cosInterp(states[wrapi(worldIndex - 1, 0, 2)], states[worldIndex], interpIndex / interpCount);
			break;
		default:
			phase = states[worldIndex];
			break;
	}
}

void Node::nextState (double add, int index) {
	int i;
	double avg, sum;
	
	avg = 0;
	sum = 0;
	
	for (i = 0; i < 8; i++) {
		avg += (neighbors[i]->states[index] * 1.0);
		sum += 1.0;
	}
	
	avg = avg / sum + add;
	
	this->states[wrapi(index + 1, 0, 2)] = wrapd(avg, 0.0, 1.0);
	
}


void Node::nextState (double add, int index, bool x) {
	int i;
	double avg;
	
	avg = 0;
	
	for (i = 0; i < 8; i++) {
		avg += neighbors[i]->states[index];
	}
	
	avg = avg / 8 + add;
	
	this->states[wrapi(index + 1, 0, 2)] = wrapd(avg, 0.0, 1.0);
	
}

int Node::countAliveNeighbors(int index) {
	int count, i;
	count = 0;
	for (i = 0; i < 8; i++) {
		if (neighbors[i]->states[index] == 1.0) {
			count++;
		}
	}
	return count;
}

void Node::nextGeneration(int* births, int* survivals, int numStates, int index) {
	int alive, state, nextIndex;
	
	nextIndex = wrapi(index + 1, 0, 2);
	
	alive = countAliveNeighbors(index);
	state = this->states[index];
	if (state > 1.0) {
		if (state < numStates) {
			this->states[nextIndex] = state + 1.0;
		}
		else
		{
			this->states[nextIndex] = 0.0;
		}
	}
	else
	{
		if (state == 0.0)
		{
			this->states[nextIndex] = births[alive];
		}
		else
		{
			if (survivals[alive] == 0.0) {
				if (state < numStates) {
					this->states[nextIndex] = state + 1.0;
				}
				else
				{
					this->states[nextIndex] = 0.0;
				}
			}
			else
			{
				this->states[nextIndex] = 1.0;
			}
		}
	}
	
}


/* ****** WORLD ****** */

World::World () {
	
	_trainCount = 0;
	_add = 0.005;
	_index = 0;
	_vectorSize = 0;
	_interpType = NONE;
	_sym = QUAD;
	_interpCount = 1;
	_interpPhase = 0;
	nodes = NULL;	
	_avg = 0;
	_births = NULL;
	_survivals = NULL;
	bmuInitialized = false;
	
}

World::~World() {
	this->clear();
}

void World::init (int sizeX, int sizeY, int sizeV, int tDur, double lRate) {
	int x, y, i, j, nCount = 0;
	double state;
	
	this->clear();

	_sizeX = sizeX; _sizeY = sizeY; _vectorSize = sizeV;
	_trainDur = tDur; _learningRate = lRate; _initLearningRate = lRate;

	_mapRadius = (double)max(_sizeX, _sizeY) / 2.0f;
	
	_timeConst = (double)(_trainDur / logf(_mapRadius));
	
	for (int i = 0; i < 8; i++) 
		neighborWeights.push_back(1.0);
		
	nodes = new Node*[_sizeX];
	assert(nodes);
	for (x = 0; x < _sizeX; x++) {
		nodes[x] = new Node[_sizeY];
		assert(nodes[x]);
		for (y = 0; y < _sizeY; y++) {
			nodes[x][y].x = x;
			nodes[x][y].y = y;
			for (i = 0; i < _vectorSize; i++) {
				state = randd();
 				nodes[x][y].weights.push_back(state);
			}
			state = randd();
			for (i = 0; i < 3; i++) {
				nodes[x][y].states[i] = 0;			
			}
			
		}
	}
	
	for (x = 0; x < _sizeX; x++) {
		for (y = 0; y < _sizeY; y++) {
			nCount = 0;
			for (i = 0; i < 3; i++) {
				for (j = 0; j < 3; j++) {
					if (!(i == 1 && j == 1)) {
//						nodes[x][y].neighbors[nCount] = &(nodes[wrapi(x+(i-1), 0, _sizeX-1)][wrapi(y+(j-1), 0, _sizeY-1)]);
						nodes[x][y].neighbors[nCount] = &(nodes[fold(x+(i-1), 0, _sizeX-1)][fold(y+(j-1), 0, _sizeY-1)]);
						nCount++;
					}
				}
			}
			
		}
	}
	
}

void World::clear (void) {
	int y;
	if (nodes) {
		for (y = 0; y < _sizeY; y++) {
			if (nodes[y]) {
				delete [] nodes[y];
				nodes[y] = NULL;
			}
		}
		delete [] nodes; 
		nodes = NULL;
	}
}

//void World::setNeighborWeights(vector<double> newWeights) {
//	for (int i = 0; i < newWeights.size(); i++) {
//		neighborWeights[i] = newWeights[i];
//	}
//}

void World::setAdd (double value) { _add = value; }

double World::cellState(int x, int y) { return nodes[x][y].states[_index]; }

Node* World::findBMU() {
	int x, y;
	double diff, best;
	Node* theNode;
	
	best = 10.0;
	
	for (x = 0; x < _sizeX; x++) {
		for (y = 0; y < _sizeY; y++) {
			diff = nodes[x][y].difference(inputWeights);
			if (diff < best) {
				best = diff;
				theNode = &(nodes[x][y]);
			}
		}
	}
	
	return theNode;
}

void World::train (Node* thisNode, Node* bmu) { 
	double tRadius, influence, dist;
	
	if (_trainCount < _trainDur) {
		tRadius = _mapRadius * exp(_trainCount / (_timeConst*-1.0));
		
		dist = pow(bmu->x - thisNode->x, 2) + pow(bmu->y - thisNode->y, 2);
		
		if (dist < pow(tRadius, 2)) {
			influence = exp(dist / (pow(tRadius, 2) * -2.0));
			thisNode->update(inputWeights, _learningRate, influence);
		}
		
		_learningRate = _initLearningRate * exp(_trainCount / (_trainDur * -1.0));
		
	}
		
}

void World::incrementTrainCount() { if (_trainCount < _trainDur) { _trainCount++; } }

// update the _index variable
void World::incrementIndex() { 
	_index = wrapi(_index + 1, 0, 2); 
	_interpPhase = 0; 
}

// return next index without updating the _index variable
int World::nextIndex() { return wrapi(_index + 1, 0, 2); }

void World::setInterpolation(Interpolation type, int count) { 
	
	_interpPhase = 0;

	if (type == NONE) {
		_interpType = type; 
		_interpCount = 1;
	}
	else
	{
		_interpType = type; 
		_interpCount = count; 
	}
}

void World::setCells(int x, int y) {
	int i, xx, yy, hlfx, hlfy;
	
	hlfx = _sizeX / 2 - 1;
	hlfy = _sizeY / 2 - 1;
	
	for (i = 0; i < 3; i++) {
		nodes[x][y].states[i] = 1.0 - _avg;
	}
	
	if (_sym > 0) {
		
		if (x > hlfx) 
		{ 
			xx = hlfx - wrapi(x, 0, hlfx); 
		}
		else
		{	
			xx = (_sizeX - 1) - x;
		}
		
		if (y > hlfy)
		{	
			yy = hlfy - wrapi(y, 0, hlfy); 
		}
		else
		{	
			yy = (_sizeY - 1) - y; 
		}

		if (_sym == AX || _sym == QUAD) {
			for (i = 0; i < 3; i++) {
				nodes[xx][y].states[i] = 1.0 - _avg;
			}
		}
		
		if (_sym == AY || _sym == QUAD) {
			for (i = 0; i < 3; i++) {
				nodes[x][yy].states[i] = 1.0 - _avg;
			}			
		}
		
		if (_sym == DIAG || _sym == QUAD) {
			for (i = 0; i < 3; i++) {
				nodes[xx][yy].states[i] = 1.0 - _avg;
			}						
		}
				
	}
		
}

void World::setBirths(int *births) {
	int i, size;
	if (!_births)
		_births = new int[8];
	
	for (i = 0; i < 8; i++) {
		_births[i] = 0;
	}
	if (births)
	{
		size = sizeof(births) / sizeof(int);
		for (i = 0; i < size; i++) {
			_births[births[i]] = 1;
		}
	}
}

void World::setSurvivals(int *survivals) {
	int i, size;
	if (!_survivals) 
		_survivals = new int[8];
	
	for (i = 0; i < 8; i++) {
		_survivals[i] = 0;
	}
	if (survivals)
	{
		size = sizeof(survivals) / sizeof(int);	
		for (i = 0; i < size; i++) {
			_survivals[survivals[i]] = 1;
		}
	}
}

void World::nextGeneration(int x, int y) {
	nodes[x][y].nextGeneration(_births, _survivals, _numStates, _index );
}

void World::mapStates(bool switchToContinuous) {
	
	int x, y;
	float state;
	
	for (x = 0; x < _sizeX; x++) {
		for (y = 0; y < _sizeY; y++) {
			state = nodes[x][y].states[_index];
			if (switchToContinuous)
				state = unmapf(state, 0.0, _numStates - 1);
			else
				state = (float)((int)mapf(state, 0.0, _numStates - 1));
			
			nodes[x][y].states[0] = state;
			nodes[x][y].states[1] = state;
			nodes[x][y].states[2] = state;
		}
	}
	
}
