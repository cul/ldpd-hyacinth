Hyacinth.DigitalObjectsApp.DigitalObjectOrderedChildEditor = function(containerElementId, options) {

  this.$containerElement = $('#' + containerElementId);
  this.digitalObject = options['digitalObject'];
  this.orderedChildDigitalObjects = options['orderedChildDigitalObjects'];
  this.tooManyToShow = options['tooManyToShow'];

  this.init();
};

/*******************************
 *******************************
 * Class methods and variables *
 *******************************
 *******************************/

Hyacinth.DigitalObjectsApp.DigitalObjectOrderedChildEditor.ORDERED_CHILD_EDITOR_ELEMENT_CLASS = 'digital-object-ordered-child-editor';
Hyacinth.DigitalObjectsApp.DigitalObjectOrderedChildEditor.ORDERED_CHILD_EDITOR_DATA_KEY = 'ordered_child_editor';

Hyacinth.DigitalObjectsApp.DigitalObjectOrderedChildEditor.getEditorInstanceForElement = function(element) {
  return $(element).closest('.' + Hyacinth.DigitalObjectsApp.DigitalObjectOrderedChildEditor.ORDERED_CHILD_EDITOR_ELEMENT_CLASS).data(Hyacinth.DigitalObjectsApp.DigitalObjectOrderedChildEditor.ORDERED_CHILD_EDITOR_DATA_KEY);
};

/**********************
 * Data Serialization *
 **********************/
//Todo

/******************
 * Form Rendering *
 ******************/
//Todo

// Add/Remove/Reorder methods
//Todo

/**********************************
 **********************************
 * Instance methods and variables *
 **********************************
 **********************************/

/*******************
 * Setup / Cleanup *
 *******************/

Hyacinth.DigitalObjectsApp.DigitalObjectOrderedChildEditor.prototype.init = function() {

  var that = this;

  this.$containerElement.addClass(Hyacinth.DigitalObjectsApp.DigitalObjectOrderedChildEditor.ORDERED_CHILD_EDITOR_ELEMENT_CLASS); //Add class to container element
  this.$containerElement.data(Hyacinth.DigitalObjectsApp.DigitalObjectOrderedChildEditor.ORDERED_CHILD_EDITOR_DATA_KEY, this); //Assign this editor object as data to the container element so that we can access it later

  //Setup form html
  this.$containerElement.html(
    Hyacinth.DigitalObjectsApp.renderTemplate('digital_objects_app/widgets/digital_object_ordered_child_editor/index.ejs', {
      digitalObject: this.digitalObject,
      orderedChildDigitalObjects: this.orderedChildDigitalObjects,
      tooManyToShow: this.tooManyToShow
    })
  );

  //Bind reordering click listeners
  this.$containerElement.find('.shift-child-up').on('click', function(e){
    e.preventDefault();

    var $orderedChild = $(this).closest('.ordered-child');
    var $prevOrderedChild = $orderedChild.prev('.ordered-child');
    if ($prevOrderedChild) {
      $prevOrderedChild.insertAfter($orderedChild);
      $orderedChild.find('.shift-child-up').blur(); //Seems weird, but I need to do this to blur the clicked button.  Directly calling blur on the button element isn't working.
    }

  });
  this.$containerElement.find('.shift-child-down').on('click', function(e){
    e.preventDefault();

    var $orderedChild = $(this).closest('.ordered-child');
    var $nextOrderedChild = $orderedChild.next('.ordered-child');
    if ($nextOrderedChild) {
      $orderedChild.insertAfter($nextOrderedChild);
      $orderedChild.find('.shift-child-down').blur(); //Seems weird, but I need to do this to blur the clicked button.  Directly calling blur on the button element isn't working.
    }

  });

  this.$containerElement.find('.ordered-child-editor-form').on('submit', function(e){

    e.preventDefault();
    var $submitButton = $(this).find('.editor-submit-button');
    $submitButton.attr('data-original-value', $submitButton.val()).val('Saving...');
    Hyacinth.addAlert('Saving...', 'info');

    var orderedPids = [];

    $orderedChildren = that.$containerElement.find('.ordered-child');

    if ($orderedChildren.length > 0) {
      $orderedChildren.each(function(){
        orderedPids.push($(this).attr('data-pid'));
      });
    }

    $.ajax({
      url: '/digital_objects/' + that.digitalObject.getPid() + '.json',
      type: 'POST',
      data: {
        '_method': 'PUT', //For proper RESTful Rails requests
        digital_object : {
          ordered_child_digital_object_pids: orderedPids
        },
      },
      cache: false
    }).done(function(digitalObjectCreationResponse){
      $submitButton.val($submitButton.attr('data-original-value'));

      if (digitalObjectCreationResponse['errors']) {
        Hyacinth.addAlert('Errors encountered during save. Please try again.', 'danger');
      } else {
        Hyacinth.addAlert('Digital Object saved.', 'success');
      }

    }).fail(function(){
      $submitButton.val($submitButton.attr('data-original-value'));
      alert(Hyacinth.unexpectedAjaxErrorMessage);
    });

  });

};

//Clean up event handlers
Hyacinth.DigitalObjectsApp.DigitalObjectOrderedChildEditor.prototype.dispose = function() {
  this.$containerElement.removeData(Hyacinth.DigitalObjectsApp.DigitalObjectOrderedChildEditor.ORDERED_CHILD_EDITOR_DATA_KEY) // Break this (circular) reference.  This is important!
  this.$containerElement.find('.shift-child-up').off('click');
  this.$containerElement.find('.shift-child-down').off('click');
  this.$containerElement.find('.ordered-child-editor-form').off('submit');
};
