//Define controller subclass
Hyacinth.DigitalObjectsApp.DigitalObjectsController = function() {
  Hyacinth.DigitalObjectsApp.Controller.call(this); // call parent constructor
};
Hyacinth.DigitalObjectsApp.DigitalObjectsController.controllerName = 'digital_objects'; //Class variable
Hyacinth.extendClass(Hyacinth.DigitalObjectsApp.DigitalObjectsController, Hyacinth.DigitalObjectsApp.Controller); //Extend controller
Hyacinth.DigitalObjectsApp.registerController(Hyacinth.DigitalObjectsApp.DigitalObjectsController);  //Register controller

//beforeAction -- special method that's run before all actions
Hyacinth.DigitalObjectsApp.DigitalObjectsController.prototype.beforeAction = function() {
  $('#digital-object-dynamic-content').html('Loading...');
}

//Index Action - Searches
Hyacinth.DigitalObjectsApp.DigitalObjectsController.prototype.index = function() {

  $('#digital-object-dynamic-content').html(Hyacinth.DigitalObjectsApp.renderTemplate('digital_objects_app/digital_objects/index.ejs'));

  var digitalObjectSearch = new Hyacinth.DigitalObjectsApp.DigitalObjectSearch('digital-object-search', {});

  this.dispose = function(){
    digitalObjectSearch.dispose();
    digitalObjectSearch = null;
  };

};

//New Setup Action - Select Project and DigitalObjectType For New Digital Object
Hyacinth.DigitalObjectsApp.DigitalObjectsController.prototype.new_setup = function() {

  var that = this;

  $.ajax({
    url: '/projects/where_current_user_can_create.json',
    cache: false
  }).done(function(project_data){
    $('#digital-object-dynamic-content').html(Hyacinth.DigitalObjectsApp.renderTemplate('digital_objects_app/digital_objects/new_setup.ejs', {
      projects: project_data,
    }));

    if($('#project-select-form').length > 0) {
      var lastSelectedProjectStringKey = Hyacinth.readCookie('last_selected_project_string_key');
      if (lastSelectedProjectStringKey != null) {
        $('#project-select-form select').val(lastSelectedProjectStringKey);
      }
    }

    //Setup event handlers
    $('#project-select-form').on('submit', function(e){
      e.preventDefault();
      var projectStringKey = $(this).find('select[name="project_string_key"]').val();
      Hyacinth.createCookie('last_selected_project_string_key', projectStringKey, 30); // Store value for pre-set select convencience later on
      document.location.hash = Hyacinth.DigitalObjectsApp.paramsToHashValue(
        Hyacinth.ObjectHelpers.merge(Hyacinth.DigitalObjectsApp.params, {'project_string_key' : projectStringKey})
      );
    });

    $('#project-and-digital-object-type-select-form').on('submit', function(e){
      e.preventDefault();
      var projectStringKey = $(this).find('input[name="project_string_key"]').val();
      var digitalObjectTypeStringKey = $(this).find('select[name="digital_object_type_string_key"]').val();
      var newLocationParams = {controller: 'digital_objects', action: 'new', project_string_key: projectStringKey, digital_object_type_string_key: digitalObjectTypeStringKey};

      if ($(this).find('input[name="parent_digital_object_pid"]').length > 0) {
        newLocationParams['parent_digital_object_pid'] = $(this).find('input[name="parent_digital_object_pid"]').val();
      }

      document.location.hash = Hyacinth.DigitalObjectsApp.paramsToHashValue(newLocationParams);
    });

    //Event Cleanup
    that.dispose = function(){
      $('#project-select-form').off('submit');
      $('#project-and-digital-object-type-select-form').off('submit');
    };

  }).fail(function(reponse){
    alert(Hyacinth.unexpectedAjaxErrorMessage);
  });

};

//New Action - Create A New Digital Object
Hyacinth.DigitalObjectsApp.DigitalObjectsController.prototype.new = function() {

  var that = this;

  $.ajax({
    url: '/digital_objects/data_for_editor.json',
    data: {
      project_string_key: Hyacinth.DigitalObjectsApp.params['project_string_key'],
      digital_object_type_string_key: Hyacinth.DigitalObjectsApp.params['digital_object_type_string_key']
    },
    cache: false
  }).done(function(data_for_editor){

    if (Hyacinth.DigitalObjectsApp.params['parent_digital_object_pid']) {
      data_for_editor['digital_object'].parent_digital_object_pids = [Hyacinth.DigitalObjectsApp.params['parent_digital_object_pid']];
    }

    var digitalObject = Hyacinth.DigitalObjectsApp.DigitalObject.Base.instantiateDigitalObjectFromData(data_for_editor['digital_object']);

    $('#digital-object-dynamic-content').html(Hyacinth.DigitalObjectsApp.renderTemplate('digital_objects_app/digital_objects/new.ejs'));

    var digitalObjectEditor = new Hyacinth.DigitalObjectsApp.DigitalObjectEditor('digital-object-editor', {
      mode: 'edit',
      digitalObject: digitalObject,
      fieldsets: data_for_editor['fieldsets'],
      dynamicFieldHierarchy: data_for_editor['dynamic_field_hierarchy'],
      dynamicFieldIdsToEnabledDynamicFields: data_for_editor['dynamic_field_ids_to_enabled_dynamic_fields'],
      allowedPublishTargets: data_for_editor['allowed_publish_targets']
    });

    //Event cleanup
    that.dispose = function(){
      digitalObjectEditor.dispose();
      digitalObjectEditor = null;
    };

  }).fail(function(){
    alert(Hyacinth.unexpectedAjaxErrorMessage);
  });

};

//Edit Action - Edit A Digital Object
Hyacinth.DigitalObjectsApp.DigitalObjectsController.prototype.edit = function() {

  var that = this;

  $.ajax({
    url: '/digital_objects/data_for_editor.json',
    data: {pid: Hyacinth.DigitalObjectsApp.params['pid']},
    cache: false
  }).done(function(data_for_editor){

    var digitalObject = Hyacinth.DigitalObjectsApp.DigitalObject.Base.instantiateDigitalObjectFromData(data_for_editor['digital_object']);

    $('#digital-object-dynamic-content').html(Hyacinth.DigitalObjectsApp.renderTemplate('digital_objects_app/digital_objects/edit.ejs', {digitalObject: digitalObject}));

    var digitalObjectEditor = new Hyacinth.DigitalObjectsApp.DigitalObjectEditor('digital-object-editor', {
      mode: 'edit',
      digitalObject: digitalObject,
      fieldsets: data_for_editor['fieldsets'],
      dynamicFieldHierarchy: data_for_editor['dynamic_field_hierarchy'],
      dynamicFieldIdsToEnabledDynamicFields: data_for_editor['dynamic_field_ids_to_enabled_dynamic_fields'],
      allowedPublishTargets: data_for_editor['allowed_publish_targets']
    });

    //For deleting DigitalObjects
    $('.delete-digital-object-button').on('click', function(e){
      e.preventDefault();
      var confirmResponse = confirm('Are you sure you want to delete this Digital Object and unpublish it from all publish targets?');
      if (confirmResponse) {
        //After successful deletion, return to index page
        $.ajax({
          url: '/digital_objects/' + Hyacinth.DigitalObjectsApp.params['pid'] + '.json',
          type: 'POST',
          data: {'_method': 'DELETE'}, //For proper RESTful Rails requests
          cache: false
        }).done(function(deletionResponse){
          if (deletionResponse['success']) {
            Hyacinth.addAlert('Digital Object deleted.', 'info');
            document.location.hash = Hyacinth.DigitalObjectsApp.paramsToHashValue({controller: 'digital_objects', action: 'index'});
          } else {
            alert(Hyacinth.unexpectedAjaxErrorMessage);
          }
        }).fail(function(){
          alert(Hyacinth.unexpectedAjaxErrorMessage);
        });
      }
    });

    //For un-deleting DigitalObjects
    $('.undelete-digital-object-button').on('click', function(e){
      e.preventDefault();
      var confirmResponse = confirm('Are you sure you want to restore this Digital Object?');
      if (confirmResponse) {
        //After successful deletion, refresh the page
        $.ajax({
          url: '/digital_objects/' + Hyacinth.DigitalObjectsApp.params['pid'] + '/undelete.json',
          type: 'POST',
          data: {
            '_method': 'PUT' //For proper RESTful Rails requests
          },
          cache: false
        }).done(function(updateResponse){
          if (updateResponse['success']) {
            Hyacinth.addAlert('Digital Object restored.', 'info');
            Hyacinth.DigitalObjectsApp.reloadCurrentAction();
          } else {
            alert(Hyacinth.unexpectedAjaxErrorMessage);
          }
        }).fail(function(){
          alert(Hyacinth.unexpectedAjaxErrorMessage);
        });
      }
    });

    //Event cleanup
    that.dispose = function(){
      $('.delete-digital-object-button').off('click');
      $('.undelete-digital-object-button').off('click');
      digitalObjectEditor.dispose();
      digitalObjectEditor = null;
    };

  }).fail(function(){
    alert(Hyacinth.unexpectedAjaxErrorMessage);
  });

};

//Show Action - Show A Digital Object
Hyacinth.DigitalObjectsApp.DigitalObjectsController.prototype.show = function() {

  var that = this;

  //Check for presence of Hyacinth.DigitalObjectsApp.mostRecentSearchParams because without it, searchResultNumber doesn't mean anything (and it might have just come from a copied/pasted url)
  if (Hyacinth.DigitalObjectsApp.mostRecentSearchParams != null && typeof(Hyacinth.DigitalObjectsApp.params['searchResultNumber']) != 'undefined') {
    Hyacinth.DigitalObjectsApp.mostRecentSearchResult = parseInt(Hyacinth.DigitalObjectsApp.params['searchResultNumber']);
    Hyacinth.DigitalObjectsApp.mostRecentSearchResultPid = Hyacinth.DigitalObjectsApp.params['pid'];
  } else {
    Hyacinth.DigitalObjectsApp.mostRecentSearchResult = (typeof(Hyacinth.DigitalObjectsApp.mostRecentSearchResult) == 'undefined' ? null : Hyacinth.DigitalObjectsApp.mostRecentSearchResult);
    Hyacinth.DigitalObjectsApp.mostRecentSearchResultPid = Hyacinth.DigitalObjectsApp.mostRecentSearchResultPid || null;
  }

  $.ajax({
    url: '/digital_objects/data_for_editor.json',
    type: 'POST',
    data: {
      pid: Hyacinth.DigitalObjectsApp.params['pid'],
      search_result_number: Hyacinth.DigitalObjectsApp.mostRecentSearchResult,
      search: (Hyacinth.DigitalObjectsApp.mostRecentSearchResult == null) ? null : Hyacinth.DigitalObjectsApp.mostRecentSearchParams
    },
    cache: false
  }).done(function(data_for_editor){

    var digitalObject = Hyacinth.DigitalObjectsApp.DigitalObject.Base.instantiateDigitalObjectFromData(data_for_editor['digital_object']);

    var dataForTemplate = {
      digitalObject: digitalObject
    };

    if (data_for_editor['previous_and_next_data']) {
      dataForTemplate['previousSearchResultPid'] = data_for_editor['previous_and_next_data']['previous_pid'];
      dataForTemplate['nextSearchResultPid'] = data_for_editor['previous_and_next_data']['next_pid'];
      dataForTemplate['totalNumSearchResults'] = data_for_editor['previous_and_next_data']['total_num_results'];
    } else {
      dataForTemplate['previousSearchResultPid'] = null;
      dataForTemplate['nextSearchResultPid'] = null;
      dataForTemplate['totalNumSearchResults'] = null;
    }

    $('#digital-object-dynamic-content').html(Hyacinth.DigitalObjectsApp.renderTemplate('digital_objects_app/digital_objects/show.ejs', dataForTemplate));

    var digitalObjectEditor = new Hyacinth.DigitalObjectsApp.DigitalObjectEditor('digital-object-editor', {
      mode: 'show',
      digitalObject: digitalObject,
      fieldsets: data_for_editor['fieldsets'],
      dynamicFieldHierarchy: data_for_editor['dynamic_field_hierarchy'],
      dynamicFieldIdsToEnabledDynamicFields: data_for_editor['dynamic_field_ids_to_enabled_dynamic_fields'],
      allowedPublishTargets: data_for_editor['allowed_publish_targets']
    });

    //Event cleanup
    that.dispose = function(){
      digitalObjectEditor.dispose();
      digitalObjectEditor = null;
    };

  }).fail(function(){
    alert(Hyacinth.unexpectedAjaxErrorMessage);
  });

};

//Publish Target Fields Action - Edit fields for a publish target
Hyacinth.DigitalObjectsApp.DigitalObjectsController.prototype.manage_transcript = function() {
  var that = this;

  $.ajax({
    url: '/digital_objects/data_for_editor.json',
    type: 'POST',
    data: {
      pid: Hyacinth.DigitalObjectsApp.params['pid']
    },
    cache: false
  }).done(function(data_for_editor){

    $.ajax({
      url: '/digital_objects/' + Hyacinth.DigitalObjectsApp.params['pid'] + '/transcript',
      type: 'GET',
      cache: false
    }).done(function(transcriptText){
      var digitalObject = Hyacinth.DigitalObjectsApp.DigitalObject.Base.instantiateDigitalObjectFromData(data_for_editor['digital_object']);

      $('#digital-object-dynamic-content').html(Hyacinth.DigitalObjectsApp.renderTemplate('digital_objects_app/digital_objects/manage_transcript.ejs', {digitalObject: digitalObject}));

      var transcriptEditor = new Hyacinth.DigitalObjectsApp.DigitalObjectTranscriptEditor('digital-object-transcript-editor', {
        digitalObject: digitalObject,
        transcriptText: transcriptText
      });

      //Event cleanup
      that.dispose = function(){
        transcriptEditor.dispose();
        transcriptEditor = null;
      };

    }).fail(function(){
      alert(Hyacinth.unexpectedAjaxErrorMessage);
    });
  }).fail(function(){
    alert(Hyacinth.unexpectedAjaxErrorMessage);
  });
};

//Publish Target Fields Action - Edit fields for a publish target
Hyacinth.DigitalObjectsApp.DigitalObjectsController.prototype.publish_target_fields = function() {

  var that = this;

  $.ajax({
    url: '/digital_objects/data_for_editor.json',
    type: 'POST',
    data: {
      pid: Hyacinth.DigitalObjectsApp.params['pid']
    },
    cache: false
  }).done(function(data_for_editor){

    var digitalObject = Hyacinth.DigitalObjectsApp.DigitalObject.Base.instantiateDigitalObjectFromData(data_for_editor['digital_object']);

    $('#digital-object-dynamic-content').html(Hyacinth.DigitalObjectsApp.renderTemplate('digital_objects_app/digital_objects/publish_target_fields.ejs', {digitalObject: digitalObject}));

    var publishTargetFieldsEditor = new Hyacinth.DigitalObjectsApp.DigitalObjectPublishTargetFieldsEditor('digital-object-publish-target-fields-editor', {
      digitalObject: digitalObject
    });

    //Event cleanup
    that.dispose = function(){
      publishTargetFieldsEditor.dispose();
      publishTargetFieldsEditor = null;
    };

  }).fail(function(){
    alert(Hyacinth.unexpectedAjaxErrorMessage);
  });

};

//Manage Children Action - Manage the order of DigitalObject's child digital objects
Hyacinth.DigitalObjectsApp.DigitalObjectsController.prototype.manage_children = function() {

  var that = this;

  $.ajax({
    url: '/digital_objects/' + Hyacinth.DigitalObjectsApp.params['pid'] + '/data_for_ordered_child_editor.json',
    data: {},
    cache: false
  }).done(function(data_for_ordered_child_editor){

    var digitalObject = Hyacinth.DigitalObjectsApp.DigitalObject.Base.instantiateDigitalObjectFromData(data_for_ordered_child_editor['digital_object']);
    var tooManyToShow = data_for_ordered_child_editor['too_many_to_show'];
    var orderedChildDigitalObjects = [];
    var childPidsForDigitalObjectsNotImportedIntoHyacinth = [];
    $.each(data_for_ordered_child_editor['ordered_child_search_results'], function(index, child_digital_object){
      if(child_digital_object['not_in_hyacinth']) {
        // It's possible that this object has a child that has not been imported into Hyacinth. Separate those object pids.
        childPidsForDigitalObjectsNotImportedIntoHyacinth.push(child_digital_object['pid']);
      } else {
        orderedChildDigitalObjects.push(new Hyacinth.DigitalObjectsApp.DigitalObjectSearchResult(child_digital_object));
      }
    });

    $('#digital-object-dynamic-content').html(Hyacinth.DigitalObjectsApp.renderTemplate('digital_objects_app/digital_objects/manage_children.ejs', {digitalObject: digitalObject, childPidsForDigitalObjectsNotImportedIntoHyacinth: childPidsForDigitalObjectsNotImportedIntoHyacinth}));

    var digitalObjectOrderedChildEditor = new Hyacinth.DigitalObjectsApp.DigitalObjectOrderedChildEditor('digital-object-ordered-child-editor', {
      digitalObject: digitalObject,
      orderedChildDigitalObjects: orderedChildDigitalObjects,
      childPidsForDigitalObjectsNotImportedIntoHyacinth: childPidsForDigitalObjectsNotImportedIntoHyacinth,
      tooManyToShow: tooManyToShow
    });

    //Event cleanup
    that.dispose = function(){
      digitalObjectOrderedChildEditor.dispose();
      digitalObjectOrderedChildEditor = null;
    };

  }).fail(function(){
    alert(Hyacinth.unexpectedAjaxErrorMessage);
  });

};

//Upload Asset Action - Upload new assets under a parent Item Digital Object
Hyacinth.DigitalObjectsApp.DigitalObjectsController.prototype.upload_assets = function() {

  var that = this;

  $.ajax({
    url: '/digital_objects/data_for_editor.json',
    data: {pid: Hyacinth.DigitalObjectsApp.params['parent_digital_object_pid']},
    cache: false
  }).done(function(data_for_editor){

    var parentDigitalObject = Hyacinth.DigitalObjectsApp.DigitalObject.Base.instantiateDigitalObjectFromData(data_for_editor['digital_object']);

    $('#digital-object-dynamic-content').html(Hyacinth.DigitalObjectsApp.renderTemplate('digital_objects_app/digital_objects/upload_assets.ejs', {parentDigitalObject: parentDigitalObject}));

    digital_object_data_for_new_asset = {
      project: {
        pid: parentDigitalObject.project['pid']
      },
      parent_digital_objects: [
        {
          pid: parentDigitalObject['pid']
        }
      ],
      digital_object_type: {
        string_key: 'asset'
      }
    }

    var fileBrowserWidget = new Hyacinth.DigitalObjectsApp.FileBrowserWidget();
    fileBrowserWidget.setTitle('Upload Directory Browser');
    fileBrowserWidget.setActionButtonLabel('Import');
    fileBrowserWidget.onActionButtonClick = function(){

      Hyacinth.addAlert('Performing upload...', 'info');

      digital_object_data_for_new_asset['import_file'] = {
        import_type : "upload_directory",
        import_path : fileBrowserWidget.getPathFieldValue()
      }

      var filename = fileBrowserWidget.getPathFieldValue().replace(/^.*[\\\/]/, '');
      that.addUploadPlaceholder(filename);

      $.ajax({
        url: '/digital_objects.json',
        type: 'POST',
        data: {
          digital_object_data_json: JSON.stringify(digital_object_data_for_new_asset)
        },
        cache: false
      }).done(function(upload_response){
        that.handleUploadResponse(upload_response);
      }).fail(function(){
        alert(Hyacinth.unexpectedAjaxErrorMessage);
      });

    };
    $('#filesystem_upload').append(fileBrowserWidget.$el);

    var $uploadForm = $('.digital-object-asset-upload-form');

    digital_object_data_for_new_asset['import_file'] = {
      import_type : "post_data",
      import_path : fileBrowserWidget.getPathFieldValue()
    }

    $uploadForm.fileupload({
        dataType: 'json',
        url: '/digital_objects.json',
        type: 'POST',
        formData: {
          digital_object_data_json: JSON.stringify(digital_object_data_for_new_asset)
        },
        add: function (e, data) {
            $uploadForm.find('.progress .progress-bar').css('width', 0 + '%');
            setTimeout(function() {
              that.addUploadPlaceholder(data['files'][0]['name']);
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
          that.handleUploadResponse(data['result']);
        }
    });

    //Event cleanup
    that.dispose = function(){
      $uploadForm.fileupload('destroy');
    };

  }).fail(function(){
    alert(Hyacinth.unexpectedAjaxErrorMessage);
  });

};

Hyacinth.DigitalObjectsApp.DigitalObjectsController.prototype.addUploadPlaceholder = function(filename) {

  var $uploadedFilesTableBody = $('.uploaded-files-table tbody');
  if ($uploadedFilesTableBody.find('.placeholder').length > 0) {
    $uploadedFilesTableBody.find('.placeholder').remove();
  }

  $(
    '<tr data-file-placeholder-for="' + _.escape(filename) + '">' +
      '<td>' + filename + '</td>' +
      '<td class="aligncenter">-</td>' +
      '<td class="aligncenter">Pending...</td>' +
    '</tr>'
  ).appendTo($uploadedFilesTableBody);

};

Hyacinth.DigitalObjectsApp.DigitalObjectsController.prototype.handleUploadResponse = function(response_data) {

  var $uploadedFilesTableBody = $('.uploaded-files-table tbody');

  var name = response_data['uploaded_file_confirmation']['name'];
  var size = response_data['uploaded_file_confirmation']['size'];
  var errors = response_data['uploaded_file_confirmation']['errors'];

  if (errors.length > 0) {
    Hyacinth.addAlert(errors[0], 'danger');
  } else {
    var fileSize = size;
    var fileSizeDisplayValue = null;
    if (fileSize > 1000000000) {
      fileSizeDisplayValue = parseInt(fileSize/1000000000) + ' GB';
    } else if (fileSize > 1000000) {
      fileSizeDisplayValue = parseInt(fileSize/1000000) + ' MB';
    } else if (fileSize > 1000) {
      fileSizeDisplayValue = parseInt(fileSize/1000) + ' kB';
    } else {
      fileSizeDisplayValue = parseInt(fileSize) + ' B';
    }
    var date = new Date();

    $uploadedFilesTableBody.find('tr[data-file-placeholder-for="' + _.escape(name) + '"]').html(
      '<td>' + name + '</td>' +
      '<td class="aligncenter">' + fileSizeDisplayValue + '</td>' +
      '<td class="text-success aligncenter">' +
        '<span class="glyphicon glyphicon-ok-sign"></span> ' +
      '</td>'
    );

    Hyacinth.addAlert('File upload complete: ' + name, 'info');
  }

}

//Add Parent Action - Add a parent Digital Object to this Digital Object
Hyacinth.DigitalObjectsApp.DigitalObjectsController.prototype.manage_parents = function() {

  var that = this;

  $.ajax({
    url: '/digital_objects/data_for_editor.json',
    data: {pid: Hyacinth.DigitalObjectsApp.params['pid']},
    cache: false
  }).done(function(data_for_editor){

    var digitalObject = Hyacinth.DigitalObjectsApp.DigitalObject.Base.instantiateDigitalObjectFromData(data_for_editor['digital_object']);
    $('#digital-object-dynamic-content').html(Hyacinth.DigitalObjectsApp.renderTemplate('digital_objects_app/digital_objects/manage_parents.ejs', {digitalObject: digitalObject}));

    $('#add-parent-form').on('submit', function(e){
      var parentPid = $('#add-parent-form').find('[name="additional_parent_pid"]').val();
      e.preventDefault();
      $('#add-parent-button').prop('disabled', true);
      $.ajax({
        url: '/digital_objects/' + Hyacinth.DigitalObjectsApp.params['pid'] + '/add_parent.json',
        type: 'POST',
        data: {
          '_method': 'PUT', //For proper RESTful Rails requests
          parent_pid: parentPid
        },
        cache: false
      }).done(function(add_parent_response){
        $('#add-parent-button').prop('disabled', false);
        if (add_parent_response['success']) {
          Hyacinth.addAlert('Parent added.', 'success');
          Hyacinth.DigitalObjectsApp.reloadCurrentAction();
        } else {
          Hyacinth.addAlert('&bull; ' + add_parent_response['errors'].join('<br />&bull; '), 'danger');
        }
      }).fail(function(){
        alert(Hyacinth.unexpectedAjaxErrorMessage);
        $('#add-parent-button').prop('disabled', false);
      });
      return false;
    });

    $('#remove-parent-form').on('submit', function(e){
      var parentsToRemove = [];
      $('#remove-parent-form').find('[name="parent_pid"]:checked').each(function(){
        parentsToRemove.push($(this).val());
      });
      e.preventDefault();
      $('#remove-selected-parents-button').prop('disabled', true);
      $.ajax({
        url: '/digital_objects/' + Hyacinth.DigitalObjectsApp.params['pid'] + '/remove_parents.json',
        type: 'POST',
        data: {
          '_method': 'PUT', //For proper RESTful Rails requests
          parent_pids: parentsToRemove
        },
        cache: false
      }).done(function(remove_parents_response){
        $('#remove-selected-parents-button').prop('disabled', false);
        if (remove_parents_response['success']) {
          Hyacinth.addAlert('Selected parents have been removed.', 'success');
          Hyacinth.DigitalObjectsApp.reloadCurrentAction();
        } else {
          Hyacinth.addAlert('&bull; ' + remove_parents_response['errors'].join('<br />&bull; '), 'danger');
        }
      }).fail(function(){
        alert(Hyacinth.unexpectedAjaxErrorMessage);
        $('#remove-selected-parents-button').prop('disabled', false);
      });
      return false;
    });

    //Event cleanup
    that.dispose = function(){
      $('#add-parent-form').off('submit');
    };

  }).fail(function(){
    alert(Hyacinth.unexpectedAjaxErrorMessage);
  });

};
