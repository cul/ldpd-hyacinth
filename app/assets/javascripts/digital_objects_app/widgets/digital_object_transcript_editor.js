Hyacinth.DigitalObjectsApp.DigitalObjectTranscriptEditor = function(containerElementId, options) {

  this.$containerElement = $('#' + containerElementId);
  this.digitalObject = options['digitalObject'];
  this.init();
  this.$containerElement.find('.transcript-textarea').val(options['transcriptText']);
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

  // set up file upload widget
  var $uploadForm = $('.transcript-editor-form');
  $uploadForm.fileupload({
      dataType: 'text',
      url: '/digital_objects/' + Hyacinth.DigitalObjectsApp.params['pid'] + '/transcript',
      type: 'POST',
      formData: {
        '_method': 'PUT' //For proper RESTful Rails requests
      },
      add: function (e, data) {
          $uploadForm.find('.progress .progress-bar').css('width', 0 + '%');
          setTimeout(function() {
            //that.addUploadPlaceholder(data['files'][0]['name']);
            data.submit();
          }, 1000);
      },
      progressall: function (e, data) {
        var progress = parseInt(data.loaded / data.total * 100, 10);
        $uploadForm.find('.progress .progress-bar').css('width', progress + '%');

        var bitrate = data.bitrate;
        var bitrateDisplayValue = null;
        if (bitrate > 1000000000) {
          bitrateDisplayValue = parseInt(data.bitrate/1000000000) + ' Gbit/s';
        } else if (bitrate > 1000000) {
          bitrateDisplayValue = parseInt(data.bitrate/1000000) + ' Mbit/s';
        } else {
          bitrateDisplayValue = parseInt(data.bitrate/1000) + ' kbit/s';
        }

        $uploadForm.find('.extended-progress-info').html('Upload rate: ' + bitrateDisplayValue);
      },
      done: function (e, data) {
        Hyacinth.addAlert('Transcript upload complete (TODO: Display possible errors.).', 'info');
        //that.handleUploadResponse(data['result']);
      }
  });
  //assign $uploadForm to this.uploadForm so that we can dispose of it later in the dispose function
  this.uploadForm = $uploadForm;

  //transcript-editor-form is only rendered in main template if a user has the right permissions
  if(this.$containerElement.find('.transcript-editor-form').length > 0) {

    $editorForm = this.$containerElement.find('.transcript-editor-form');

    $editorForm.on('submit', function(e){
      e.preventDefault();
      that.submitEditorForm();
    });

    $editorForm.on('click', '.editor-submit-button', function(e){
      e.preventDefault();
      that.submitEditorForm();
    });

  }
};

Hyacinth.DigitalObjectsApp.DigitalObjectTranscriptEditor.prototype.submitEditorForm = function() {
  $.ajax({
    url: '/digital_objects/' + Hyacinth.DigitalObjectsApp.params['pid'] + '/transcript',
    type: 'POST',
    data: {
      '_method': 'PUT', //For proper RESTful Rails requests
      'transcript_text': this.$containerElement.find('.transcript-textarea').val()
    },
    cache: false
  }).done(function(transcriptPutResponse){
    if (transcriptPutResponse['success']) {
      Hyacinth.addAlert('Transcript updated.', 'info');
      Hyacinth.DigitalObjectsApp.reloadCurrentAction();
    } else {
      alert(Hyacinth.unexpectedAjaxErrorMessage);
    }
  }).fail(function(){
    alert(Hyacinth.unexpectedAjaxErrorMessage);
  });
};

//Clean up event handlers
Hyacinth.DigitalObjectsApp.DigitalObjectTranscriptEditor.prototype.dispose = function() {
  this.$containerElement.removeData(Hyacinth.DigitalObjectsApp.DigitalObjectTranscriptEditor.TRANSCRIPT_EDITOR_DATA_KEY) // Break this (circular) reference.  This is important!
  this.uploadForm.fileupload('destroy');
};
