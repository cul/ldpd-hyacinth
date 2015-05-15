Hyacinth.DigitalObjectsApp.FileBrowserWidget = function() {

  this.directoryListingUrl = '/digital_objects/upload_directory_listing.json';
  this.$el = $(Hyacinth.DigitalObjectsApp.renderTemplate('digital_objects_app/widgets/file_browser_widget/file_browser.ejs'));
  this.currentPath = '';
  this.onActionButtonClick = null;

  this.bindEventHandlers();
  this.renderCurrentDirectoryListing();
};

Hyacinth.DigitalObjectsApp.FileBrowserWidget.prototype.setTitle = function(title){
  this.$el.find('.title').html(title);
};

Hyacinth.DigitalObjectsApp.FileBrowserWidget.prototype.setActionButtonLabel = function(label){
  this.$el.find('.action-button').html(label);
};

Hyacinth.DigitalObjectsApp.FileBrowserWidget.prototype.dispose = function(){
  this.unbindEventHandlers();
};

Hyacinth.DigitalObjectsApp.FileBrowserWidget.prototype.bindEventHandlers = function(){
  this.$el.on('click', '.content a.file', this.clickOnFile.bind(this));
  this.$el.on('click', '.content a.directory', this.clickOnDirectory.bind(this));
  this.$el.on('click', '.content a.refresh-button', this.refreshCurrentDirectoryView.bind(this));
  this.$el.find('.action-button').on('click', this.actionButtonClicked.bind(this));
};

Hyacinth.DigitalObjectsApp.FileBrowserWidget.prototype.actionButtonClicked = function(){
  if (this.onActionButtonClick != null) {
    this.onActionButtonClick();
  }
};

Hyacinth.DigitalObjectsApp.FileBrowserWidget.prototype.unbindEventHandlers = function(){
  this.$el.off('click');
  this.$el.find('.action-button').off('click');
  this.onActionButtonClick = null;
};

Hyacinth.DigitalObjectsApp.FileBrowserWidget.prototype.clickOnFile = function(event) {
  event.preventDefault();
  this.$el.find('.path-field').val(decodeURIComponent($(event.currentTarget).attr('data-uri-encoded-path')));
};

Hyacinth.DigitalObjectsApp.FileBrowserWidget.prototype.getPathFieldValue = function() {
  return this.$el.find('.path-field').val();
};

Hyacinth.DigitalObjectsApp.FileBrowserWidget.prototype.clickOnDirectory = function(event) {
  event.preventDefault();
  this.currentPath = decodeURIComponent($(event.currentTarget).attr('data-uri-encoded-path'));
  this.renderCurrentDirectoryListing();
};

Hyacinth.DigitalObjectsApp.FileBrowserWidget.prototype.refreshCurrentDirectoryView = function(event) {
  event.preventDefault();
  this.renderCurrentDirectoryListing();
};

Hyacinth.DigitalObjectsApp.FileBrowserWidget.prototype.renderCurrentDirectoryListing = function() {

  this.$el.find('.directory-listing-content').html('Loading...');

  $.ajax({
    url: this.directoryListingUrl,
    cache: false,
    type: 'GET',
    data: {
      directory_path: this.currentPath
    },
  }).done(function(listingResponse){
    this.$el.find('.directory-listing-content').html(Hyacinth.DigitalObjectsApp.renderTemplate('digital_objects_app/widgets/file_browser_widget/_directory_listing.ejs', {
      currentPath: this.currentPath,
      directoryData: listingResponse['directoryData'],
    }));

    if (listingResponse['errors']) {
      listingResponse['errors'].forEach(function(error){
        console.log("WARNING: " + error)
      });
    }

  }.bind(this)).fail(function(reponse){
    alert(JSON.stringify(reponse));
  });

};