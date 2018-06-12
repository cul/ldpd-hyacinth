Hyacinth.DigitalObjectsApp.DigitalObjectTranscriptEditor = function(containerElementId, options) {

  this.$containerElement = $('#' + containerElementId);
  this.digitalObject = options['digitalObject'];

  this.init();
};

/*******************************
 *******************************
 * Class methods and variables *
 *******************************
 *******************************/

Hyacinth.DigitalObjectsApp.DigitalObjectTranscriptEditor.TRANSCRIPT_EDITOR_ELEMENT_CLASS = 'digital-object-transcript-editor';
Hyacinth.DigitalObjectsApp.DigitalObjectTranscriptEditor.TRANSCRIPT_EDITOR_DATA_KEY = 'transcript_editor';

Hyacinth.DigitalObjectsApp.DigitalObjectTranscriptEditor.getEditorInstanceForElement = function(element) {
  return $(element).closest('.' + Hyacinth.DigitalObjectsApp.DigitalObjectTranscriptEditor.TRANSCRIPT_EDITOR_ELEMENT_CLASS).data(Hyacinth.DigitalObjectsApp.DigitalObjectTranscriptEditor.TRANSCRIPT_EDITOR_DATA_KEY);
};

/**********************************
 **********************************
 * Instance methods and variables *
 **********************************
 **********************************/

/*******************
 * Setup / Cleanup *
 *******************/

Hyacinth.DigitalObjectsApp.DigitalObjectTranscriptEditor.prototype.init = function() {

  var that = this;

  this.$containerElement.addClass(Hyacinth.DigitalObjectsApp.DigitalObjectTranscriptEditor.TRANSCRIPT_EDITOR_ELEMENT_CLASS); //Add class to container element
  this.$containerElement.data(Hyacinth.DigitalObjectsApp.DigitalObjectTranscriptEditor.TRANSCRIPT_EDITOR_DATA_KEY, this); //Assign this editor object as data to the container element so that we can access it later

  //Determine mode based on current user permission
  var mode = Hyacinth.DigitalObjectsApp.currentUser.hasProjectPermission(this.digitalObject.getProject()['pid'], 'can_update') ? 'edit' : 'view';

  //Setup form html
  this.$containerElement.html(
    Hyacinth.DigitalObjectsApp.renderTemplate('digital_objects_app/widgets/digital_object_transcript_editor/index.ejs', {
      digitalObject: this.digitalObject,
      mode: mode
    })
  );

  //Save button is only rendered in main template if a user has the right permissions
  if(this.$containerElement.find('.transcript-upload-form').length > 0) {

    $editorForm = this.$containerElement.find('.publish-target-fields-editor-form');

    $editorForm.on('submit', function(e){
      e.preventDefault();
      that.submitEditorForm(false);
    });

    $editorForm.on('click', '.editor-submit-button', function(e){
      e.preventDefault();
      that.submitEditorForm(false);
    });

    $editorForm.on('click', '.editor-submit-and-publish-button', function(e){
      e.preventDefault();
      that.submitEditorForm(true);
    });
  }
};

Hyacinth.DigitalObjectsApp.DigitalObjectTranscriptEditor.prototype.submitEditorForm = function(publish) {

};

//Clean up event handlers
Hyacinth.DigitalObjectsApp.DigitalObjectTranscriptEditor.prototype.dispose = function() {
  this.$containerElement.removeData(Hyacinth.DigitalObjectsApp.DigitalObjectTranscriptEditor.TRANSCRIPT_EDITOR_DATA_KEY) // Break this (circular) reference.  This is important!
};
