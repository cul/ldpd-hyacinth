// Asset - Subclass
Hyacinth.DigitalObjectsApp.DigitalObject.Asset = function(digital_object_data){
  Hyacinth.DigitalObjectsApp.DigitalObject.Base.call(this, digital_object_data); // call parent constructor
  this.assetData = digital_object_data['asset_data'];
};
Hyacinth.extendClass(Hyacinth.DigitalObjectsApp.DigitalObject.Asset, Hyacinth.DigitalObjectsApp.DigitalObject.Base); //Extend


Hyacinth.DigitalObjectsApp.DigitalObject.Asset.prototype.getFilesystemLocation = function(){
  return this.assetData['filesystem_location'];
};

Hyacinth.DigitalObjectsApp.DigitalObject.Asset.prototype.getAccessCopyLocation = function(){
  return this.assetData['access_copy_location'];
};

Hyacinth.DigitalObjectsApp.DigitalObject.Asset.prototype.getServiceCopyLocation = function(){
  return this.assetData['service_copy_location'];
};

Hyacinth.DigitalObjectsApp.DigitalObject.Asset.prototype.getFileChecksum = function(){
  return this.assetData['checksum'];
};

Hyacinth.DigitalObjectsApp.DigitalObject.Asset.prototype.getFileSizeInBytes = function(){
  return this.assetData['file_size_in_bytes'];
};

Hyacinth.DigitalObjectsApp.DigitalObject.Asset.prototype.getAccessCopyFileSizeInBytes = function(){
  return this.assetData['access_copy_file_size_in_bytes'];
};

Hyacinth.DigitalObjectsApp.DigitalObject.Asset.prototype.getServiceCopyFileSizeInBytes = function(){
  return this.assetData['service_copy_file_size_in_bytes'];
};

Hyacinth.DigitalObjectsApp.DigitalObject.Asset.prototype.getFileSizeString = function() {
  return this.bytesToSizeString(this.getFileSizeInBytes());
};

Hyacinth.DigitalObjectsApp.DigitalObject.Asset.prototype.getAccessCopyFileSizeString = function() {
  return this.bytesToSizeString(this.getAccessCopyFileSizeInBytes());
};

Hyacinth.DigitalObjectsApp.DigitalObject.Asset.prototype.getServiceCopyFileSizeString = function() {
  return this.bytesToSizeString(this.getServiceCopyFileSizeInBytes());
};

Hyacinth.DigitalObjectsApp.DigitalObject.Asset.prototype.bytesToSizeString = function(bytes) {
  var sizeInBytes = parseInt(bytes);
  var value = sizeInBytes;
  var unit = 'B';
	if(sizeInBytes < 1000) {
  	return value + ' ' + unit;
  } else if(sizeInBytes < 1000000) {
  	value = sizeInBytes/1000;
    unit = 'kB';
  } else if(sizeInBytes < 1000000000) {
  	value = sizeInBytes/1000000;
    unit = 'MB';
  } else {
	  value = sizeInBytes/1000000000;
    unit = ' GB';
  }

  return parseFloat(parseFloat(value).toFixed(2)) + ' ' + unit; // the outermost parseFloat call removes trailing ".00" if present, but leaves values like ".01"
};

Hyacinth.DigitalObjectsApp.DigitalObject.Asset.prototype.getOriginalFilename = function(){
  return this.assetData['original_filename'];
};

Hyacinth.DigitalObjectsApp.DigitalObject.Asset.prototype.getOriginalFilePath = function(){
  return this.assetData['original_file_path'];
};

Hyacinth.DigitalObjectsApp.DigitalObject.Asset.prototype.hasImage = function(){
  return Hyacinth.imageServerUrl && this.isStillImage();
};

Hyacinth.DigitalObjectsApp.DigitalObject.Asset.prototype.isRestrictedSizeImage = function(){
  return this.hasRestrictions() && this.restrictions.restricted_size_image;
};

Hyacinth.DigitalObjectsApp.DigitalObject.Asset.prototype.isRestrictedOnsite = function(){
  return this.hasRestrictions() && this.restrictions.restricted_onsite;
};
