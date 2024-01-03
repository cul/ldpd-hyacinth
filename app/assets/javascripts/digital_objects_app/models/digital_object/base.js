// Abstract DigitalObject class
Hyacinth.defineNamespace('Hyacinth.DigitalObjectsApp.DigitalObject');

Hyacinth.DigitalObjectsApp.DigitalObject.Base = function (digital_object_data) {
  var that = this;
  $.each(digital_object_data, function (key, val) {
    that[key] = val;
  });
};

// Class methods
Hyacinth.DigitalObjectsApp.DigitalObject.Base.instantiateDigitalObjectFromData = function (digital_object_data) {
  var digitalObjectTypeStringKeysToClasses = {
    item: Hyacinth.DigitalObjectsApp.DigitalObject.Item,
    asset: Hyacinth.DigitalObjectsApp.DigitalObject.Asset,
    group: Hyacinth.DigitalObjectsApp.DigitalObject.Group,
    file_system: Hyacinth.DigitalObjectsApp.DigitalObject.FileSystem,
    publish_target: Hyacinth.DigitalObjectsApp.DigitalObject.PublishTarget
  };
  return new digitalObjectTypeStringKeysToClasses[digital_object_data['digital_object_type']['string_key']](digital_object_data);
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.getImageUrl = function (pid, type, size) {
  if (type == 'scaled') { type = 'full'; }
  if (type == 'square') { type = 'featured'; }

  return Hyacinth.imageServerUrl + '/iiif/2/' + pid + '/' + type + '/!' + size + ',' + size + '/0/default.jpg';
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.showMediaViewModal = function (pid) {
  Hyacinth.showMainModal(
    'Media View: ' + pid,
    '<iframe id="digital-object-media-view" src="/digital_objects/' + pid + '/media_view" allowfullscreen></iframe>',
    '<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>'
  );

  $('#digital-object-media-view').height($(window).height() - 240);
};

//Instance methods

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getJsonViewUrl = function () {
  return Hyacinth.getLocationOrigin() + '/digital_objects/' + this.getPid() + '.json';
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getModsXmlViewUrl = function () {
  return Hyacinth.getLocationOrigin() + '/digital_objects/' + this.getPid() + '/mods.xml';
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getXacmlXmlViewUrl = function () {
  return Hyacinth.getLocationOrigin() + '/digital_objects/' + this.getPid() + '/xacml.xml';
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getParentDigitalObjectPids = function () {
  return $.map(this.parent_digital_objects, function (parent_digital_object) { return parent_digital_object['pid']; });
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getOrderedChildDigitalObjectPids = function () {
  return $.map(this.ordered_child_digital_objects, function (child_digital_object) { return child_digital_object['pid']; });
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getNumberOfChildDigitalObjects = function () {
  return this.ordered_child_digital_objects.length;
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getState = function () {
  return this.state;
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getDcType = function () {
  return this.dc_type;
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getStateAsDisplayLabel = function () {
  var statesToDisplayLabels = { 'A': 'Active', 'D': 'Deleted', 'I': 'Inactive' }
  return statesToDisplayLabels[this.getState()];
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.isNewRecord = function () {
  return (this.getPid() == null);
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getTitle = function () {

  if (this.isNewRecord()) {
    return 'New ' + this.digital_object_type['display_label'];
  }

  return this.title;
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getPid = function () {
  return this.pid;
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getProject = function () {
  return this.project;
};

// hasImage method is meant to be overridden by DigitalObject subclasses
Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.hasImage = function () {
  return false;
}

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getImageUrl = function (type, size) {
  return Hyacinth.DigitalObjectsApp.DigitalObject.Base.getImageUrl(this.getPid(), type, size);
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getCreatedBy = function () {
  return this.created_by;
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getCreated = function () {
  return new Date(this.created);
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getModifiedBy = function () {
  return this.modified_by;
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getModified = function () {
  return new Date(this.modified);
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getFirstPublished = function () {
  return (this.first_published ? new Date(this.first_published) : null);
};

Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getDoi = function () {
  return this.doi || null;
};
Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getPerformDerivativeProcessing = function () {
  return this.perform_derivative_processing;
};
Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.hasRestrictions = function () {
  return typeof (this.restrictions) !== 'undefined';
};
Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.getAssignments = function () {
  return this.assignments;
};
Hyacinth.DigitalObjectsApp.DigitalObject.Base.prototype.hasAssignment = function (permissionType) {
  var assignment = _.find(this.getAssignments(), function (assignment) {
    return (assignment['task'] == permissionType);
  }) || null;
  return assignment;
};
