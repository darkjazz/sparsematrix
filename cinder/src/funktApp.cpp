#include "OscSender.h"
#include "OscListener.h"

#include "ogl.h"

#define SCREENX		1440
#define SCREENY		900

class FunktApp : public AppBasic {
 public:
	void prepareSettings(Settings*);
	void setup();
	void update();
	void resize( ResizeEvent event);
	void draw();
	void shutdown();
	
	void sendMessage(int);
	
	World *world; 
	GraphicsRenderer *ogl; 

	bool _initializeWorld;
	bool _newVectorReceived;
	bool _updateStates;
	bool _continuous;
	
	World *_world;
	Node *_bmu, *_currentNode;
	GraphicsRenderer *_ogl;
	
	int _worldX, _worldY, _vectorSize, _learningDuration;
	float _learningRate;	
	
	int _winSizeX, _winSizeY;
	int _frameRate, _inport, _outport, _framesPerUpdate, _windowMode;
	string _remoteHost;
		
	osc::Sender _sender;
	osc::Listener _listener;
	
	CameraPersp mCam; 
		
};

void FunktApp::prepareSettings(Settings *settings) {
	
	vector<string> args;
	int i;
	string myarg;
	
	_winSizeX = 800;
	_winSizeY = 600;
	_frameRate = 32;
	_remoteHost	= "127.0.0.1";
	_inport = 7000;
	_outport = 57120;
	_framesPerUpdate = 8;
	_windowMode = 0;
	
	args = getArgs();
	
	for (i = 1; i < args.size(); i+=2) {
		if (args[i].compare("-screenx") == 0) {
			_winSizeX = atoi(args[i+1].c_str());
		}
		else if (args[i].compare("-screeny") == 0) {
			_winSizeY = atoi(args[i+1].c_str());		
		}
		else if (args[i].compare("-fps") == 0) {
			_frameRate = atoi(args[i+1].c_str());		
		}
		else if (args[i].compare("-remote") == 0) {
			_remoteHost = args[i+1];		
		}
		else if (args[i].compare("-inport") == 0) {
			_inport = atoi(args[i+1].c_str());		
		}
		else if (args[i].compare("-outport") == 0) {
			_outport = atoi(args[i+1].c_str());		
		}
		else if (args[i].compare("-fpu") == 0) {
			_framesPerUpdate = atoi(args[i+1].c_str());		
		}
		else if (args[i].compare("-wmode") == 0) {
			_windowMode = atoi(args[i+1].c_str());		
		}		
	}
			
	settings->setWindowSize( _winSizeX, _winSizeY );
	if (_windowMode == 0)
		settings->setWindowPos( 0, SCREENY - _winSizeY );
	else 
		settings->setWindowPos( SCREENX, SCREENY - _winSizeY);

	settings->setFrameRate( _frameRate );
	settings->setBorderless( true );
			
}


void FunktApp::setup() {

	_initializeWorld = false;
	_newVectorReceived = false;
	_continuous = true;
	
	_world = new World();
		
	_ogl = new GraphicsRenderer(_world, getWindowWidth(), getWindowHeight());
	
	_ogl->setupOgl();
		
	_sender.setup(_remoteHost, _outport);
	_listener.setup(_inport);
		
}

void FunktApp::update() {
	int i;
	
	while (_listener.hasWaitingMessages()) {
		osc::Message m;
		_listener.getNextMessage(&m);
		
		if (m.getAddress() == "/funkt/init") {
			_worldX = m.getArgAsInt32(0);
			_worldY = m.getArgAsInt32(1);
			_vectorSize = m.getArgAsInt32(2);
			_learningDuration = m.getArgAsInt32(3);
			_learningRate = m.getArgAsFloat(4);
			_initializeWorld = true;			
		} else if (m.getAddress() == "/funkt/weights") {
			if (m.getNumArgs() == _vectorSize)
			{
				for (int i = 0; i < _vectorSize; i++) {
					_world->inputWeights.clear();
					_world->inputWeights.push_back(m.getArgAsFloat(i));
				}
				_newVectorReceived = true;
				if (!_world->bmuInitialized) _world->bmuInitialized = true;				
			}
		} else if (m.getAddress() == "/funkt/pattern") {
			int patIndex;
			patIndex = m.getArgAsInt32(0);
			_ogl->patternLib[patIndex].active = (bool)m.getArgAsInt32(1);
			_ogl->patternLib[patIndex].alpha = m.getArgAsFloat(2);
			_ogl->patternLib[patIndex].alphamap = m.getArgAsInt32(3);
			_ogl->patternLib[patIndex].colormap = m.getArgAsInt32(4);
		} else if (m.getAddress() == "/funkt/interp") {
			_world->setInterpolation((Interpolation)m.getArgAsInt32(0), m.getArgAsInt32(1));
		} else if (m.getAddress() == "/funkt/symmetry") {
			_world->setSymmetry((Symmetry)m.getArgAsInt32(0));
		} else if (m.getAddress() == "/funkt/add") {
			_world->setAdd(m.getArgAsFloat(0));
		}		
		else if (m.getAddress() == "/funkt/births") {
			int *b;
			b = new int[m.getNumArgs()];
			for (i = 0; i < m.getNumArgs(); i++) {
				b[i] = m.getArgAsInt32(i);
			}
			_world->setBirths(b);
			delete [] b;
		}
		else if (m.getAddress() == "/funkt/survivals") {
			int *s;
			s = new int[m.getNumArgs()];
			for (i = 0; i < m.getNumArgs(); i++) {
				s[i] = m.getArgAsInt32(i);
			}
			_world->setSurvivals(s);
			delete [] s;
		}
		else if (m.getAddress() == "/funkt/states") {
			_world->setStates(m.getArgAsInt32(0));
		}
		else if (m.getAddress() == "/funkt/rule") {
			if (m.getArgAsInt32(0) == 1)
				_continuous = false;
			else
				_continuous = true;
			
			_world->mapStates(_continuous);
			
		}
/*
		else if (m.getAddress() == "/funkt/reset/rand") {
			bool include;
			if (m.getArgAsInt32(7) == 1) 
			{	include = true; }
			else
			{	include = false; }
			
			_world->initRandInArea(
								   m.getArgAsInt32(0), 
								   m.getArgAsInt32(1), 
								   m.getArgAsInt32(2), 
								   m.getArgAsInt32(3), 
								   m.getArgAsInt32(4), 
								   m.getArgAsInt32(5), 
								   _world->rule()->numStates() - 1,
								   m.getArgAsFloat(6), 
								   include
								   );
		}
		else if (addr.compare("/funkt/reset/wirecube") == 0) {
			_world->initWireCube(
								 m.getArgAsInt32(0), 
								 m.getArgAsInt32(1), 
								 m.getArgAsInt32(2), 
								 m.getArgAsInt32(3), 
								 m.getArgAsInt32(4), 
								 m.getArgAsInt32(5) 
								 );
		}	
*/		
		else if (m.getAddress() == "/funkt/quit") {
			quit();
		}
		
	}
	
	if (_initializeWorld) {
		_world->init(_worldX, _worldY, _vectorSize, _learningDuration, _learningRate);
		_initializeWorld = false;
	}
	
}

void FunktApp::resize( ResizeEvent event) {
	mCam.lookAt( Vec3f(0.0f, 0.0f, 500.0f), Vec3f::zero() );
	mCam.setPerspective(60, getWindowAspectRatio(), 1, 5000);
	gl::setMatrices( mCam );
	//	ogl->reshape(event);
}

void FunktApp::draw()
{
		
	if (_world->nodes) {
		
		if (_newVectorReceived) 
			_bmu = _world->findBMU();
		
		_updateStates = false;
		
		if (_world->interpCount() == _world->interpPhase()) {
			_world->incrementIndex();
			_world->resetAverageState();
			_updateStates = true;
		}
		
		_world->nextPhase();
				
		_ogl->prepareFrame();
		
		for (int x = 0; x < _world->sizeX(); x++) {
			for (int y = 0; y < _world->sizeY(); y++) {
				
				_currentNode = &_world->nodes[x][y];
				if (_newVectorReceived)
					_world->train(_currentNode, _bmu);
				
				if (_updateStates) {
					if (_continuous) {
						_currentNode->nextState(_world->add(), _world->index());
						_world->incrementAverageState(_currentNode->states[_world->index()]);
					}
					else {
						_world->nextGeneration(x, y);
					}
				}
				
				_currentNode->nextPhase(_world->interpPhase(), _world->index(), _world->interpType(), _world->interpCount());
				_ogl->drawFragment( &_world->nodes[x][y], _bmu, x, y );
				
			}
		}	
		
		if (_updateStates)
			_world->finalizeAverageState();
		
		if (_newVectorReceived) {
			_world->setCells(_bmu->x, _bmu->y);
			_newVectorReceived = false;
			_world->incrementTrainCount();
		}
								
		_ogl->finalizeFrame();
		
	}
	
}

void FunktApp::sendMessage(int alive) {
	osc::Message msg;
	
	msg.setAddress("/funkt/world/alive");
	msg.addIntArg(alive);
	
	msg.setRemoteEndpoint(_remoteHost, _outport);
	_sender.sendMessage(msg);
}

void FunktApp::shutdown() {
	delete _world;
	delete _ogl;	
}

// This line tells Flint to actually create the application
CINDER_APP_BASIC( FunktApp, RendererGl )