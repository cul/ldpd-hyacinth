Hyacinth.DigitalObjectsApp.DigitalObjectAnnotationEditor = function(containerElementId, options) {

  this.$containerElement = $('#' + containerElementId);
  this.digitalObject = options['digitalObject'];
  this.mode = options['mode'];
  this.assignment = options['assignment'];
  this.init();
};

/*******************************
 *******************************
 * Class methods and variables *
 *******************************
 *******************************/

Hyacinth.DigitalObjectsApp.DigitalObjectAnnotationEditor.ANNOTATION_EDITOR_ELEMENT_CLASS = 'digital-object-annotation-editor';
Hyacinth.DigitalObjectsApp.DigitalObjectAnnotationEditor.ANNOTATION_EDITOR_DATA_KEY = 'annotation_editor';

Hyacinth.DigitalObjectsApp.DigitalObjectAnnotationEditor.getEditorInstanceForElement = function(element) {
  return $(element).closest('.' + Hyacinth.DigitalObjectsApp.DigitalObjectAnnotationEditor.ANNOTATION_EDITOR_ELEMENT_CLASS).data(Hyacinth.DigitalObjectsApp.DigitalObjectAnnotationEditor.ANNOTATION_EDITOR_DATA_KEY);
};

/**********************************
 **********************************
 * Instance methods and variables *
 **********************************
 **********************************/

/*******************
 * Setup / Cleanup *
 *******************/

Hyacinth.DigitalObjectsApp.DigitalObjectAnnotationEditor.prototype.init = function() {

  this.$containerElement.addClass(Hyacinth.DigitalObjectsApp.DigitalObjectAnnotationEditor.ANNOTATION_EDITOR_ELEMENT_CLASS); //Add class to container element
  this.$containerElement.data(Hyacinth.DigitalObjectsApp.DigitalObjectAnnotationEditor.ANNOTATION_EDITOR_DATA_KEY, this); //Assign this editor object as data to the container element so that we can access it later

  if(['MovingImage', 'Sound'].indexOf(this.digitalObject.getDcType()) > -1) {
    this.$containerElement.html(
      Hyacinth.DigitalObjectsApp.renderTemplate('digital_objects_app/widgets/digital_object_annotation_editor/oh_synchronizer_index_mode.ejs', {
        digitalObject: this.digitalObject,
        mode: this.mode,
        assignment: this.assignment
      })
    );

    this.createSynchronizerWidget();
  } else {
    this.$containerElement.html(
      Hyacinth.DigitalObjectsApp.renderTemplate('digital_objects_app/widgets/digital_object_annotation_editor/unsupported_object_type.ejs', {
        digitalObject: this.digitalObject,
        mode: this.mode,
        assignment: this.assignment
      })
    );
  }
};

Hyacinth.DigitalObjectsApp.DigitalObjectAnnotationEditor.prototype.dispose = function() {
  if(this.synchronizerWidget) {
    this.synchronizerWidget.dispose();
    this.synchronizerWidget = null;
  }
}

Hyacinth.DigitalObjectsApp.DigitalObjectAnnotationEditor.prototype.createSynchronizerWidget = function(){
  var widgetOptions = {
    player: {
      type: 'video',
  		url: '/digital_objects/' + this.digitalObject.getPid() + '/download_access_copy'
    },
    index: {
      id: 'input-index',
      // TODO: Don't use Hyacinth.DigitalObjectsApp.currentUser as an indication of whether we're in the js app or not. There's a better way. Temp solution here.
      url: this.assignment && (!Hyacinth.DigitalObjectsApp.currentUser) ? '/assignments/' + this.assignment['id'] + '/changeset/proposed' : '/digital_objects/' + this.digitalObject.getPid() + '/index_document',
    },
    options: {
      previewOnly: this.mode == 'view'
    }
  };

	this.synchronizerWidget = new OHSynchronizer(widgetOptions);
  OHSynchronizer.playerControls.bindNavControls(); //bind modal forward/back/etc. nav controls. TODO: Move this to widget js instead of Hyacinth js
  OHSynchronizer.errorHandler = function(e) {
    Hyacinth.addAlert(e, 'danger');
  }

  this.$containerElement.find('.save-index-document-button').on('click', $.proxy(this.saveIndexDocument, this));

  // TODO: Move code below into synchronizer widget?
  //////////////////////////////////////////////
	if (widgetOptions.options.previewOnly) {
		this.$containerElement.find('.preview-button').hide();
    this.$containerElement.find('.save-index-document-button').hide();

	} else {
		$('.preview-button').on('click', function() {
			this.synchronizerWidget.index.preview();
		}.bind(this));
	}

  // Manually initialize the widget's player because it normally relies on jQuery's document ready
  this.$containerElement.find('video, audio').filter('[data-able-player]').each(function (index, element) {
    if ($(element).data('able-player') !== undefined) {
      new AblePlayer($(this),$(element));
    }
  });
  //////////////////////////////////////////////
};

Hyacinth.DigitalObjectsApp.DigitalObjectAnnotationEditor.prototype.saveIndexDocument = function() {
  $.ajax({
    url: this.assignment ? '/assignments/' + this.assignment['id'] + '/changeset' : '/digital_objects/' + this.digitalObject.getPid() + '/index_document',
    type: 'POST',
    data: {
      '_method': 'PUT', //For proper RESTful Rails requests
      'index_document_text': this.synchronizerWidget.index.exportVTT()
    },
    cache: false
  }).done(function(transcriptPutResponse){
    if (transcriptPutResponse['success']) {
      Hyacinth.addAlert('Index document updated.', 'info');
    } else {
      alert(Hyacinth.unexpectedAjaxErrorMessage);
    }
  }).fail(function(){
    alert(Hyacinth.unexpectedAjaxErrorMessage);
  });
};

//Clean up event handlers
Hyacinth.DigitalObjectsApp.DigitalObjectAnnotationEditor.prototype.dispose = function() {
  this.$containerElement.removeData(Hyacinth.DigitalObjectsApp.DigitalObjectAnnotationEditor.ANNOTATION_EDITOR_DATA_KEY) // Break this (circular) reference.  This is important!
  if(this.$containerElement.find('.save-index-document-button').length > 0) {
    this.$containerElement.find('.save-index-document-button').off('click');
  }
};
