Hyacinth.DigitalObjectsApp.DigitalObjectTranscriptEditor = function(containerElementId, options) {

  this.$containerElement = $('#' + containerElementId);
  this.digitalObject = options['digitalObject'];
  this.mode = options['mode'];
  this.assignment = options['assignment'];
  this.init();
  if(this.mode == 'edit') {
    this.$containerElement.find('.transcript-textarea').val(options['transcriptText']);
  } else {
    this.$containerElement.find('.transcript-readonly-container').html(options['transcriptText'].length > 0 ? options['transcriptText'] : 'No transcript available.');
  }
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

  //Setup form html
  this.$containerElement.html(
    Hyacinth.DigitalObjectsApp.renderTemplate('digital_objects_app/widgets/digital_object_transcript_editor/index.ejs', {
      digitalObject: this.digitalObject,
      mode: that.mode,
      assignment: this.assignment
    })
  );

  // set up file upload widget
  var $uploadForm = $('.transcript-editor-form');
  $uploadForm.fileupload({
      dataType: 'json',
      url: this.assignment ? '/assignments/' + this.assignment['id'] + '/changeset' : '/digital_objects/' + Hyacinth.DigitalObjectsApp.params['pid'] + '/transcript',
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

        if(progress < 100) {
          $uploadForm.find('.extended-progress-info').html('Upload rate: ' + bitrateDisplayValue);
        } else {
          $uploadForm.find('.extended-progress-info').html('Finishing...');
        }
      },
      done: function (e, data) {
        var result = data['result'];
        if(result['success']) {
          Hyacinth.DigitalObjectsApp.reloadCurrentAction();
          Hyacinth.addAlert('Transcript upload completed successfully.', 'info');
        } else {
          $uploadForm.find('.extended-progress-info').html('Upload failed:<br />' + result['errors'].join('<br />'));
        }
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
    url: this.assignment ? '/assignments/' + this.assignment['id'] + '/changeset' : '/digital_objects/' + Hyacinth.DigitalObjectsApp.params['pid'] + '/transcript',
    type: 'POST',
    data: {
      '_method': 'PUT', //For proper RESTful Rails requests
      'transcript_text': this.$containerElement.find('.transcript-textarea').val()
    },
    cache: false
  }).done(function(transcriptPutResponse){
    if (transcriptPutResponse['success']) {
      Hyacinth.addAlert('Transcript updated.', 'info');
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
