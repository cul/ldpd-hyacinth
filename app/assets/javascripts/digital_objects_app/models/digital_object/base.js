// Abstract DigitalObject class
Hyacinth.defineNamespace('Hyacinth.DigitalObjectsApp.DigitalObject');

Hyacinth.DigitalObjectsApp.DigitalObject.Base = function(digital_object_data) {
  this.pid = digital_object_data['pid'];
  this.title = digital_object_data['title'];
  this.state = digital_object_data['state'];
  this.projects = digital_object_data['projects'];
  this.digital_object_type = digital_object_data['digital_object_type'];
  this.dynamic_field_data = digital_object_data['dynamic_field_data'];
  this.parent_digital_object_pids = digital_object_data['parent_digital_object_pids'] || [];
  this.ordered_child_digital_object_pids = digital_object_data['ordered_child_digital_object_pids'] || [];
  this.dc_type = digital_object_data['dc_type'] || '';
};

// Class methods
Hyacinth.DigitalObjectsApp.DigitalObject.Base.instantiateDigitalObjectFromData = function(digital_object_data){
  var digitalObjectTypeStringKeysToClasses = {
    item: Hyacinth.DigitalObjectsApp.DigitalObject.Item,
    asset: Hyacinth.DigitalObjectsApp.DigitalObject.Asset,
    group:  Hyacinth.DigitalObjectsApp.DigitalObject.Group,
    publish_target: Hyacinth.DigitalObjectsApp.DigitalObject.PublishTarget
  }
  return new digitalObjectTypeStringKeysToClasses[digital_object_data['digital_object_type']['string_key']](digital_object_data);
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.getImageUrl = function(pid, type, size){
  return Hyacinth.repositoryCacheUrl + '/images/' + pid + '/' + type + '/' + size + '.jpg';
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.showMediaViewModal = function(pid){
  Hyacinth.showMainModal(
    'Media View: ' + pid,
    '<iframe id="digital-object-media-view" src="/digital_objects/' + pid + '/media_view" allowfullscreen></iframe>',
    '<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>'
  );

  $('#digital-object-media-view').height($(window).height() - 240);
};

//Instance methods

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getJsonViewUrl = function() {
  return Hyacinth.getLocationOrigin() + '/digital_objects/' + this.getPid() + '.json';
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getModsXmlViewUrl = function() {
  return Hyacinth.getLocationOrigin() + '/digital_objects/' + this.getPid() + '/mods.xml';
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getParentDigitalObjectPids = function() {
  return this.parent_digital_object_pids;
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getOrderedChildDigitalObjectPids = function() {
  return this.ordered_child_digital_object_pids;
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getNumberOfChildDigitalObjects = function() {
  return this.getOrderedChildDigitalObjectPids().length;
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getState = function() {
  return this.state;
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getDcType = function() {
  return this.dc_type;
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getStateAsDisplayLabel = function(){
  var statesToDisplayLabels = {'A' : 'Active', 'D' : 'Deleted', 'I' : 'Inactive'}
  return statesToDisplayLabels[this.getState()];
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.isNewRecord = function(){
  return (this.getPid() == null);
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getTitle = function(){

  if (this.isNewRecord()) {
    return 'New ' + this.digital_object_type['display_label'];
  }

  return this.title;
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getPid = function(){
  return this.pid;
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getProjects = function(){
  return this.projects;
};

// hasImage method is meant to be overridden by DigitalObject subclasses
Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.hasImage = function() {
  return false;
}

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getImageUrl = function(type, size){
  return Hyacinth.DigitalObjectsApp.DigitalObject.Base.getImageUrl(this.getPid(), type, size);
};

/***************************************************************
 * Digital Object subclasses that are meant to be instantiated *
 ***************************************************************/

// Item - Subclass
Hyacinth.DigitalObjectsApp.DigitalObject.Item = function(digital_object_data){
  Hyacinth.DigitalObjectsApp.DigitalObject.Base.call(this, digital_object_data); // call parent constructor
};
Hyacinth.extendClass(Hyacinth.DigitalObjectsApp.DigitalObject.Item, Hyacinth.DigitalObjectsApp.DigitalObject.Base); //Extend

// Group - Subclass
Hyacinth.DigitalObjectsApp.DigitalObject.Group = function(digital_object_data){
  Hyacinth.DigitalObjectsApp.DigitalObject.Base.call(this, digital_object_data); // call parent constructor
};
Hyacinth.extendClass(Hyacinth.DigitalObjectsApp.DigitalObject.Group, Hyacinth.DigitalObjectsApp.DigitalObject.Base); //Extend

// PublishTarget - Subclass
Hyacinth.DigitalObjectsApp.DigitalObject.PublishTarget = function(digital_object_data){
  Hyacinth.DigitalObjectsApp.DigitalObject.Base.call(this, digital_object_data); // call parent constructor
};
Hyacinth.extendClass(Hyacinth.DigitalObjectsApp.DigitalObject.PublishTarget, Hyacinth.DigitalObjectsApp.DigitalObject.Base); //Extend
