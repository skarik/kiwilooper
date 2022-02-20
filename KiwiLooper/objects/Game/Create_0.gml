if (singleton_this()) exit;

// Set up transition 
global._transition_source = null;
global._cutscene_main = null;

global.game_editorRun = false;

global.game_loadingInfo = kGameLoadingFromGMS;
global.game_loadingMap = "";

// Load up cutscene backend
//cutsceneBackendLoad();

// Initial state of collision storage
//col3_internal_query_reset();
//roomPrepassCleanup();
