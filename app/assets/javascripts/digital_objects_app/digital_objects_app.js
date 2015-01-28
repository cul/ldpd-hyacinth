Hyacinth.defineNamespace('Hyacinth.DigitalObjectsApp');

Hyacinth.DigitalObjectsApp.defaultParams = {controller: 'digital_objects', action: 'index'};
Hyacinth.DigitalObjectsApp.registeredControllerClasses = {};

//Main objects
Hyacinth.DigitalObjectsApp.currentController = null;
Hyacinth.DigitalObjectsApp.mostRecentSearchParams = null;
Hyacinth.DigitalObjectsApp.mostRecentSearchResult = null;

/* Used to start the app and set things up */
Hyacinth.DigitalObjectsApp.init = function() {
  //Setup hash change listener
  $(window).on('hashchange', Hyacinth.DigitalObjectsApp.handleHashChange);
  //Call hash change listener method to get things started for the current hash
  Hyacinth.DigitalObjectsApp.handleHashChange();

  //Handle unauthorized responses with a global ajax handler for the 401 status code
  $.ajaxSetup({
      statusCode: {
          401: Hyacinth.promptForLogin
      }
  });
}

Hyacinth.DigitalObjectsApp.paramsToHashValue = function(params) {
  params = typeof params !== 'undefined' ? params : Hyacinth.DigitalObjectsApp.params;
  return encodeURIComponent(JSON.stringify(params));
};

Hyacinth.DigitalObjectsApp.hashValueToParams = function(hashValue) {
  hashValue = typeof hashValue !== 'undefined' ? hashValue : (location.hash.length > 0 && location.hash != '#' ? location.hash.substring(1) : null);
  return JSON.parse(decodeURIComponent(hashValue));
};

Hyacinth.DigitalObjectsApp.reloadCurrentAction = function() {
  Hyacinth.DigitalObjectsApp.handleHashChange();
}

Hyacinth.DigitalObjectsApp.handleHashChange = function() {

  //Cleanup existing controller instance
  if (Hyacinth.DigitalObjectsApp.currentController != null) {
    Hyacinth.DigitalObjectsApp.currentController.dispose();
  }

  //Handle new params
  Hyacinth.DigitalObjectsApp.params = Hyacinth.DigitalObjectsApp.hashValueToParams();
  if (Hyacinth.DigitalObjectsApp.params == null) {
    document.location.hash = Hyacinth.DigitalObjectsApp.paramsToHashValue(Hyacinth.DigitalObjectsApp.defaultParams);
    return;
  }

  //Setup and run new controller instance
  Hyacinth.DigitalObjectsApp.currentController = new Hyacinth.DigitalObjectsApp.registeredControllerClasses[Hyacinth.DigitalObjectsApp.params['controller']]();

  //Run action
  Hyacinth.DigitalObjectsApp.currentController.runAction(Hyacinth.DigitalObjectsApp.params['action']);
};

Hyacinth.DigitalObjectsApp.registerController = function(controllerClass) {
  this.registeredControllerClasses[controllerClass.controllerName] = controllerClass;
};

Hyacinth.promptForLogin = function(){
  alert('You need to log in!');
};


//Rendering template files

// localVariables is a hash of the format: {localVariableName: 'some value', anotherLocalVariableName: 'another value'}
// keys in the localVariables hash will be defined as local variables within the rendered template context
Hyacinth.DigitalObjectsApp.renderTemplate = function(pathToTemplate, localVariables) {
  //We're abstracting away the template rendering library so that we can switch libraries if needed

  //Cache response
  if (typeof(this.cachedCompiledTemplates) == 'undefined') {
    this.cachedCompiledTemplates = {};
  }

  if (typeof(this.cachedCompiledTemplates[pathToTemplate]) == 'undefined') {
    var templateUrl = Hyacinth.DigitalObjectsApp.View.getEjsTemplateUrl(pathToTemplate);
    if (typeof(templateUrl) == 'undefined') {
      alert('Could not resolve relative template path: ' + pathToTemplate);
      return false;
    }

    //Synchronous request for inline rendering of templates so that we don't need callbacks in nested views that have templates that call templates
    this.cachedCompiledTemplates[pathToTemplate] = _.template($.ajax({
      type: "GET",
      url: templateUrl,
      async: false
    }).responseText);
  }

  return this.cachedCompiledTemplates[pathToTemplate](localVariables);
};
