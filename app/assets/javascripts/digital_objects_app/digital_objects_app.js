Hyacinth.defineNamespace('Hyacinth.DigitalObjectsApp');

Hyacinth.DigitalObjectsApp.defaultParams = {controller: 'digital_objects', action: 'index'};
Hyacinth.DigitalObjectsApp.registeredControllerClasses = {};

//Main objects
Hyacinth.DigitalObjectsApp.currentController = null;
Hyacinth.DigitalObjectsApp.mostRecentSearchParams = null;
Hyacinth.DigitalObjectsApp.mostRecentSearchResult = null;

/* Used to start the app and set things up */
Hyacinth.DigitalObjectsApp.init = function() {
  
  //Handle unauthorized responses with a global ajax handler for the 401 status code
  $.ajaxSetup({
      statusCode: {
          401: Hyacinth.promptForLogin
      }
  });

  //It's possible that the user tried to get a hash-based URL before logging in.
  //If so, we stored that hash.  Let's check to see if that hash value is available.
  var hashValue = Hyacinth.readCookie('hash_at_login');
  if (hashValue != null) {
    Hyacinth.eraseCookie('hash_at_login');
    window.location.hash = hashValue;
  }
  
  //Get user permissions and run callback function to set up rest of the app
  Hyacinth.DigitalObjectsApp.setupCurrentUser(function(){
    //Setup hash change listener
    $(window).on('hashchange', Hyacinth.DigitalObjectsApp.handleHashChange);
    //Call hash change listener method to get things started for the current hash
    Hyacinth.DigitalObjectsApp.handleHashChange();
  });
}

Hyacinth.DigitalObjectsApp.setupCurrentUser = function(callback) {
  
  $.ajax({
    url: '/users/current_user_data.json',
    cache: false
  }).done(function(current_user_data){
    Hyacinth.DigitalObjectsApp.currentUser = current_user_data;
    Hyacinth.DigitalObjectsApp.currentUser.hasProjectPermission = function(project_pid, permission_type){
      var project = _.find(this.permissions.projects, function(project) { return project['project_pid'] == project_pid; } );
      if (typeof(project) != 'undefined') {
        return project[permission_type];
      }
      return false;
    };
    callback();
  }).fail(function(reponse){
    alert(Hyacinth.unexpectedAjaxErrorMessage);
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
