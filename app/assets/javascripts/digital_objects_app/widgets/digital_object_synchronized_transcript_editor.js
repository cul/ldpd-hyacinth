Hyacinth.DigitalObjectsApp.DigitalObjectSynchronizedTranscriptEditor = function (containerElementId, options) {

  this.$containerElement = $('#' + containerElementId);
  this.digitalObject = options['digitalObject'];
  this.mode = options['mode'];
  this.assignment = options['assignment'];
  this.playerUrl = options['playerUrl'];
  this.init();
};

/*******************************
 *******************************
 * Class methods and variables *
 *******************************
 *******************************/

Hyacinth.DigitalObjectsApp.DigitalObjectSynchronizedTranscriptEditor.SYNCHRONIZED_TRANSCRIPT_EDITOR_ELEMENT_CLASS = 'digital-object-synchronized-transcript-editor';
Hyacinth.DigitalObjectsApp.DigitalObjectSynchronizedTranscriptEditor.SYNCHRONIZED_TRANSCRIPT_EDITOR_DATA_KEY = 'synchronized_transcript_editor';

Hyacinth.DigitalObjectsApp.DigitalObjectSynchronizedTranscriptEditor.getEditorInstanceForElement = function (element) {
  return $(element).closest('.' + Hyacinth.DigitalObjectsApp.DigitalObjectSynchronizedTranscriptEditor.SYNCHRONIZED_TRANSCRIPT_EDITOR_ELEMENT_CLASS).data(Hyacinth.DigitalObjectsApp.DigitalObjectSynchronizedTranscriptEditor.SYNCHRONIZED_TRANSCRIPT_EDITOR_DATA_KEY);
};

/**********************************
 **********************************
 * Instance methods and variables *
 **********************************
 **********************************/

/*******************
 * Setup / Cleanup *
 *******************/

Hyacinth.DigitalObjectsApp.DigitalObjectSynchronizedTranscriptEditor.prototype.init = function () {

  this.$containerElement.addClass(Hyacinth.DigitalObjectsApp.DigitalObjectSynchronizedTranscriptEditor.SYNCHRONIZED_TRANSCRIPT_EDITOR_ELEMENT_CLASS); //Add class to container element
  this.$containerElement.data(Hyacinth.DigitalObjectsApp.DigitalObjectSynchronizedTranscriptEditor.SYNCHRONIZED_TRANSCRIPT_EDITOR_DATA_KEY, this); //Assign this editor object as data to the container element so that we can access it later

  if (['MovingImage', 'Sound'].indexOf(this.digitalObject.getDcType()) > -1) {
    this.$containerElement.html(
      Hyacinth.DigitalObjectsApp.renderTemplate('digital_objects_app/widgets/digital_object_synchronized_transcript_editor/oh_synchronizer_transcript_mode.ejs', {
        digitalObject: this.digitalObject,
        mode: this.mode,
        assignment: this.assignment
      })
    );

    this.createSynchronizerWidget();
  } else {
    this.$containerElement.html(
      Hyacinth.DigitalObjectsApp.renderTemplate('digital_objects_app/widgets/digital_object_synchronized_transcript_editor/unsupported_object_type.ejs', {
        digitalObject: this.digitalObject,
        mode: this.mode,
        assignment: this.assignment
      })
    );
  }
};

Hyacinth.DigitalObjectsApp.DigitalObjectSynchronizedTranscriptEditor.prototype.dispose = function () {
  if (this.synchronizerWidget) {
    this.synchronizerWidget.dispose();
    this.synchronizerWidget = null;
  }
}

Hyacinth.DigitalObjectsApp.DigitalObjectSynchronizedTranscriptEditor.prototype.createSynchronizerWidget = function () {
  var widgetOptions = {
    player: {
      type: 'video',
      url: this.playerUrl
    },
    transcript: {
      id: 'input-transcript',
      // TODO: Don't use Hyacinth.DigitalObjectsApp.currentUser as an indication of whether we're in the js app or not. There's a better way. Temp solution here.
      url: this.assignment && (!Hyacinth.DigitalObjectsApp.currentUser) ? '/assignments/' + this.assignment['id'] + '/changeset/proposed' : '/digital_objects/' + this.digitalObject.getPid() + '/synchronized_transcript',
    },
    options: {
      previewOnly: this.mode == 'view'
    }
  };

  this.synchronizerWidget = new OHSynchronizer(widgetOptions);
  OHSynchronizer.playerControls.bindNavControls(); //bind modal forward/back/etc. nav controls. TODO: Move this to widget js instead of Hyacinth js
  OHSynchronizer.errorHandler = function (e) {
    Hyacinth.addAlert(e, 'danger');
  }

  this.$containerElement.find('.save-synchronized-transcript-button').on('click', $.proxy(this.saveSynchronizedTranscript, this));

  // TODO: Move code below into synchronizer widget?
  //////////////////////////////////////////////
  if (widgetOptions.options.previewOnly) {
    this.$containerElement.find('.preview-button').hide();
    this.$containerElement.find('#sync-controls').hide();
    this.$containerElement.find('.save-synchronized-transcript-button').hide();
    this.$containerElement.find('#sync-roll').val('0'); // no sync time offset when in captions preview mode
  } else {
    $('.preview-button').on('click', function () {
      this.synchronizerWidget.transcript.preview();
    }.bind(this));
  }

  // Manually initialize the widget's player because it normally relies on jQuery's document ready
  this.$containerElement.find('video, audio').filter('.video-js[src]').each(function (index, element) {
    if (!$(element).attr('data-initialized')) {
      $(element).attr('data-initialized', 'true');
      const optionsForVideo = {
        autoplay: false,
        controls: true,
        responsive: true,
        fluid: true,
        playbackRates: [0.5, 1, 1.5, 2],
        sources: [{
          src: element.src,
          type: element.src.includes('.m3u8') || element.src.includes('blob:') ? 'application/x-mpegURL' : 'video/mp4',
        }],
      };

      videojs(element, optionsForVideo, function () {
        //console.log("player is ready");
      });
    }
  });
  //////////////////////////////////////////////
};

Hyacinth.DigitalObjectsApp.DigitalObjectSynchronizedTranscriptEditor.prototype.saveSynchronizedTranscript = function () {
  var vttExport = this.synchronizerWidget.transcript.exportVTT();
  if (vttExport === false) {
    Hyacinth.addAlert('An error occurred during VTT export.', 'danger');
    return;
  }
  $.ajax({
    url: this.assignment ? '/assignments/' + this.assignment['id'] + '/changeset' : '/digital_objects/' + this.digitalObject.getPid() + '/synchronized_transcript',
    type: 'POST',
    data: {
      '_method': 'PUT', //For proper RESTful Rails requests
      'synchronized_transcript_text': vttExport
    },
    cache: false
  }).done(function (transcriptPutResponse) {
    if (transcriptPutResponse['success']) {
      Hyacinth.addAlert('Synchronized transcript updated.', 'info');
    } else {
      alert(Hyacinth.unexpectedAjaxErrorMessage);
    }
  }).fail(function () {
    alert(Hyacinth.unexpectedAjaxErrorMessage);
  });
};

//Clean up event handlers
Hyacinth.DigitalObjectsApp.DigitalObjectSynchronizedTranscriptEditor.prototype.dispose = function () {
  this.$containerElement.removeData(Hyacinth.DigitalObjectsApp.DigitalObjectSynchronizedTranscriptEditor.SYNCHRONIZED_TRANSCRIPT_EDITOR_DATA_KEY) // Break this (circular) reference.  This is important!
  if (this.$containerElement.find('.save-transcript-button').length > 0) {
    this.$containerElement.find('.save-transcript-button').off('click');
  }
};
