Hyacinth.DigitalObjectsApp.Controller = function() {
};
Hyacinth.DigitalObjectsApp.Controller.controllerName = 'controller'; //Class variable

Hyacinth.DigitalObjectsApp.Controller.prototype.runAction = function(actionName) {

  if(typeof(this.beforeAction) !== 'undefined') {
    this.beforeAction();
  }

  if(typeof(this[actionName]) !== 'undefined') {
    this[actionName]();
  } else {
    alert('Undefined action: ' + actionName);
    window.history.back();
  }
};

//Called when we're done with a controller action
//Generally used for un-binding event handlers
Hyacinth.DigitalObjectsApp.Controller.prototype.dispose = function() {

};
