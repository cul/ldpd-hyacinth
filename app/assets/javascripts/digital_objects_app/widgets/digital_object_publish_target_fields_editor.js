Hyacinth.DigitalObjectsApp.DigitalObjectPublishTargetFieldsEditor = function(containerElementId, options) {

  this.$containerElement = $('#' + containerElementId);
  this.digitalObject = options['digitalObject'];

  this.init();
};

/*******************************
 *******************************
 * Class methods and variables *
 *******************************
 *******************************/

Hyacinth.DigitalObjectsApp.DigitalObjectPublishTargetFieldsEditor.PUBLISH_TARGET_FIELDS_ELEMENT_CLASS = 'digital-object-ordered-child-editor';
Hyacinth.DigitalObjectsApp.DigitalObjectPublishTargetFieldsEditor.PUBLISH_TARGET_FIELDS_DATA_KEY = 'publish_target_fields';

Hyacinth.DigitalObjectsApp.DigitalObjectPublishTargetFieldsEditor.getEditorInstanceForElement = function(element) {
  return $(element).closest('.' + Hyacinth.DigitalObjectsApp.DigitalObjectPublishTargetFieldsEditor.PUBLISH_TARGET_FIELDS_ELEMENT_CLASS).data(Hyacinth.DigitalObjectsApp.DigitalObjectPublishTargetFieldsEditor.PUBLISH_TARGET_FIELDS_DATA_KEY);
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

Hyacinth.DigitalObjectsApp.DigitalObjectPublishTargetFieldsEditor.prototype.init = function() {

  var that = this;

  this.$containerElement.addClass(Hyacinth.DigitalObjectsApp.DigitalObjectPublishTargetFieldsEditor.PUBLISH_TARGET_FIELDS_EDITOR_ELEMENT_CLASS); //Add class to container element
  this.$containerElement.data(Hyacinth.DigitalObjectsApp.DigitalObjectPublishTargetFieldsEditor.PUBLISH_TARGET_FIELDS_EDITOR_DATA_KEY, this); //Assign this editor object as data to the container element so that we can access it later

  //Setup form html
  this.$containerElement.html(
    Hyacinth.DigitalObjectsApp.renderTemplate('digital_objects_app/widgets/digital_object_publish_target_fields_editor/index.ejs', {
      digitalObject: this.digitalObject
    })
  );
  
  //Save button is only visible if a user has the right permissions
  if(this.$containerElement.find('.publish-target-fields-editor-form').length > 0) {
    this.$containerElement.find('.publish-target-fields-editor-form').on('submit', function(e){
      
      e.preventDefault();
      
      var $submitButton = $(this).find('.editor-submit-button');
      $submitButton.attr('data-original-value', $submitButton.val()).val('Saving...');
      Hyacinth.addAlert('Saving...', 'info');
      
      var publishTargetData = {};
     
      $(this).find('input[name],textarea[name]').each(function(){
        publishTargetData[$(this).attr('name')] = $(this).val();
      });
      
      var digitalObjectData = {publish_target_data: publishTargetData};
      
      console.log('sending:');
      console.log(digitalObjectData);
      
      $.ajax({
        url: '/digital_objects/' + that.digitalObject.getPid() + '.json',
        type: 'POST',
        data: {
          '_method': 'PUT', //For proper RESTful Rails requests
          digital_object_data_json : JSON.stringify(digitalObjectData),
        },
        cache: false
      }).done(function(digitalObjectSaveResponse){
        $submitButton.val($submitButton.attr('data-original-value'));
  
        if (digitalObjectSaveResponse['errors']) {
          var error_messages = [];
          _.each(digitalObjectSaveResponse['errors'], function(error_message, error_key){
            error_messages.push(error_message);
          });
          Hyacinth.addAlert('Errors encountered during save: <br />' + error_messages.join('<br />'), 'danger');
        } else {
          Hyacinth.addAlert('Digital Object saved.', 'success');
        }
  
      }).fail(function(){
        $submitButton.val($submitButton.attr('data-original-value'));
        alert(Hyacinth.unexpectedAjaxErrorMessage);
      });
  
    });
  }
};

//Clean up event handlers
Hyacinth.DigitalObjectsApp.DigitalObjectPublishTargetFieldsEditor.prototype.dispose = function() {
  this.$containerElement.removeData(Hyacinth.DigitalObjectsApp.DigitalObjectPublishTargetFieldsEditor.PUBLISH_TARGET_FIELDS_EDITOR_DATA_KEY) // Break this (circular) reference.  This is important!
};
