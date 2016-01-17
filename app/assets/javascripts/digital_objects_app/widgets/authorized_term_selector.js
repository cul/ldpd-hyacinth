Hyacinth.DigitalObjectsApp.AuthorizedTermSelector = function(containerElementId, $controlledTermUriFieldElement, $controlledTermValueDisplayElement) {

  this.$containerElement = $('#' + containerElementId);
  this.$controlledTermUriFieldElement = $($controlledTermUriFieldElement);
  this.$controlledTermValueDisplayElement = this.$controlledTermUriFieldElement.closest('.controlled_term_field').find('.controlled_term_value_display')
  this.$clearButtonElement = this.$controlledTermUriFieldElement.closest('.controlled_term_field').find('.controlled_term_clear_button');

  this.controlledVocabularyStringKey = this.$controlledTermUriFieldElement.attr('data-controlled-vocabulary-string-key');
  this.controlledVocabularyDisplayLabel = this.$controlledTermUriFieldElement.attr('data-controlled-vocabulary-display-label');
  this.additionalFieldsForControlledVocabulary = {};
  
  this.latestSearchPhrase = null;
  this.currentPage = 1;
  this.autoUpdateIntervalId = null;
  this.updateInProgress = false;
  
  //Get additional fields for this controlled vocabulary and then run init() function.
  
  var that = this;
  
  $.ajax({
      url: '/controlled_vocabularies/' + this.controlledVocabularyStringKey + '/term_additional_fields.json',
      type: 'GET',
      cache: false
    }).done(function(termAdditionalFieldsResponse){
      that.additionalFieldsForControlledVocabulary = termAdditionalFieldsResponse;
      that.init(); // Call widget init function!
    }).fail(function(){
      alert(Hyacinth.unexpectedAjaxErrorMessage);
    });
};

/*******************************
 *******************************
 * Class methods and variables *
 *******************************
 *******************************/

Hyacinth.DigitalObjectsApp.AuthorizedTermSelector.SELECTOR_ELEMENT_CLASS = 'authorized_term_selector';
Hyacinth.DigitalObjectsApp.AuthorizedTermSelector.SELECTOR_DATA_KEY = 'authorized_term_selector';

Hyacinth.DigitalObjectsApp.AuthorizedTermSelector.getAuthorizedTermSelectorInstanceForElement = function(element) {
  return $(element).closest('.' + Hyacinth.DigitalObjectsApp.AuthorizedTermSelector.SELECTOR_ELEMENT_CLASS).data(Hyacinth.DigitalObjectsApp.AuthorizedTermSelector.SELECTOR_DATA_KEY);
};

/*********************
 *********************
 * Instamnce methods *
 *********************
 *********************/

Hyacinth.DigitalObjectsApp.AuthorizedTermSelector.prototype.init = function(){

  var that = this;

  //Add class to container element and add object reference to the container element
  this.$containerElement.addClass(Hyacinth.DigitalObjectsApp.AuthorizedTermSelector.SELECTOR_ELEMENT_CLASS); //Add class to container element
  this.$containerElement.data(Hyacinth.DigitalObjectsApp.AuthorizedTermSelector.SELECTOR_DATA_KEY, this); //Assign this editor object as data to the container element so that we can access it later
  
  this.$containerElement.on('click', '.choose_authorized_term_button', function(e){
    e.preventDefault();

    var uri = decodeURIComponent($(this).attr('data-uri'));
    var value = decodeURIComponent($(this).attr('data-value'));

    that.$controlledTermUriFieldElement.val(uri);
    that.$controlledTermValueDisplayElement.html(value);
    that.$clearButtonElement.removeClass('hidden');
    Hyacinth.hideMainModal();
  });

  this.$containerElement.on('click', '.previous-page', function(e){
    e.preventDefault();
    that.currentPage = that.currentPage - 1;
    that.updateSearchResults();
  });

  this.$containerElement.on('click', '.next-page', function(e){
    e.preventDefault();
    that.currentPage = that.currentPage + 1;
    that.updateSearchResults();
  });

  this.$containerElement.html(Hyacinth.DigitalObjectsApp.renderTemplate('digital_objects_app/widgets/authorized_term_selector/index.ejs'));

  this.$containerElement.find('.authorized_term_adder').hide();
  
  //Set up add_authorized_term_form fields
  this.$containerElement.find('.add_authorized_term_form').find('.term_fields').html(this.generateAuthorizedTermFormFieldHtml());

  this.updateSearchResults(); //Immediately update the search results

  this.$containerElement.find('input.authorized_term_search_q').on('keydown', function(e){
    if (e.keyCode == 13) {
      //Enter was pressed
      var $searchResultButtons = $(this).closest('.authorized_term_selector').find('.authorized_term_search_results').find('button');
      if ($searchResultButtons.length == 1) {
        $searchResultButtons.click()
      }
    }
  });

  this.$containerElement.on('click', '.add_new_authorized_term', function(e){
    e.preventDefault();
    that.$containerElement.find('.authorized_term_search').hide();
    that.$containerElement.find('.authorized_term_adder').show();
  });
  
  this.$containerElement.on('click', '.back_to_term_search', function(e){
    e.preventDefault();
    that.$containerElement.find('.authorized_term_search').show();
    that.$containerElement.find('.authorized_term_adder').hide();
  });
  
  //add_authorized_term_form type select element should hide or show certain form fields
  this.$containerElement.find('.add_authorized_term_form').on('change', '.term-type-select', function(e){
    var type = $(this).val();
    var $addAuthorizedTermForm = $(this).closest('.add_authorized_term_form');
    if (type == 'external') {
        $addAuthorizedTermForm.find('.term-authority-field').show();
        $addAuthorizedTermForm.find('.term-uri-field').show();
        $addAuthorizedTermForm.find('.term-additional-field').show();
    } else if (type == 'local') {
        $addAuthorizedTermForm.find('.term-authority-field').show();
        $addAuthorizedTermForm.find('.term-uri-field').hide();
        $addAuthorizedTermForm.find('.term-uri-field').find('input').val(''); // clear value of uri input
        $addAuthorizedTermForm.find('.term-additional-field').show();
    } else if (type == 'temporary') {
        $addAuthorizedTermForm.find('.term-authority-field').hide();
        $addAuthorizedTermForm.find('.term-uri-field').hide().val('');
        $addAuthorizedTermForm.find('.term-uri-field').find('input').val(''); // clear value of uri input
        $addAuthorizedTermForm.find('.term-additional-field').hide();
        $addAuthorizedTermForm.find('.term-additional-field').find('input').val(''); // clear values of child inputs
    }
  });
  this.$containerElement.find('.add_authorized_term_form').find('.term-type-select').change();  //Manually trigger change event at load time

  this.$containerElement.find('.add_authorized_term_form').on('submit', function(e){
    e.preventDefault();

    var $submitButton = that.$containerElement.find('.add_authorized_term_form').find('.add_authorized_term_form_submit_button');
    $submitButton.attr('data-original-html', $submitButton.html()).html('Adding term...');

    var termData = {
      controlled_vocabulary_string_key: that.controlledVocabularyStringKey,
      type: $(this).find('.term-type-select').val()
    };
    $(this).find('.term_fields').find('.term-field-form-element').each(function(){
      termData[$(this).attr('name')] = $(this).val();
    })
    
    $.ajax({
      url: '/terms.json',
      type: 'POST',
      data: {
        term: termData
      },
      cache: false
    }).done(function(createTermResponse){

      var $submitButton = that.$containerElement.find('.add_authorized_term_form').find('.add_authorized_term_form_submit_button');
      $submitButton.html($submitButton.attr('data-original-html'));

      if (typeof(createTermResponse['errors']) !== 'undefined') {
        var errors = '<ul class="errors">';
        createTermResponse['errors'].forEach(function(errorMessage){
          errors += '<li>' + _.escape(errorMessage) + '</li>';
        });
        errors += '</ul>';

        that.$containerElement.find('.add_authorized_term_form').find('.errors').html('<div class="alert alert-danger">' + errors + '</div>');
      } else {
        //Success!
        that.$controlledTermUriFieldElement.val(createTermResponse['uri']);
        that.$controlledTermValueDisplayElement.html(createTermResponse['value']);
        Hyacinth.hideMainModal();
      }
    }).fail(function(){
      var $submitButton = that.$containerElement.find('.add_authorized_term_form').find('.add_authorized_term_form_submit_button');
      $submitButton.html($submitButton.attr('data-original-html'));
      alert(Hyacinth.unexpectedAjaxErrorMessage);
    });
  });

  //Focus needs to be set after a slight delay.  Won't trigger immeediately.
  setTimeout(function(){
    that.$containerElement.find('input.authorized_term_search_q').focus();
  }, 200);

  //Run an interval that updates the search text
  this.autoUpdateIntervalId = setInterval(function(){
    var newSearchPhrase = that.$containerElement.find('input.authorized_term_search_q').val();
    if (newSearchPhrase === that.latestSearchPhrase) {
      //No change.  Just return.
      return;
    } else {
      that.latestSearchPhrase = newSearchPhrase;
      that.currentPage = 1; //reset page because query has changed
    }
    that.updateSearchResults();
  }, 250);

};

Hyacinth.DigitalObjectsApp.AuthorizedTermSelector.prototype.generateAuthorizedTermFormFieldHtml = function() {
  
  var htmlToReturn = '';
  
  var defaultFields = {
    'value' : {
      'display_label' : 'Value'
    },
    'authority' : {
      'display_label' : 'Authority'
    },
    'uri' : {
      'display_label' : 'URI'
    }
  }
  
  var formFieldsToRender = Hyacinth.ObjectHelpers.merge(this.additionalFieldsForControlledVocabulary, defaultFields);
  var orderedFieldNames = ['value', 'authority', 'uri'].concat(_.keys(this.additionalFieldsForControlledVocabulary).sort());
  
  orderedFieldNames.forEach(function(field_name){
    
    var fieldClass = null;
    if(field_name == 'uri') {
        fieldClass = 'term-uri-field';
    } else if (field_name == 'value') {
        fieldClass = 'term-value-field';
    } else if (field_name == 'authority') {
        fieldClass = 'term-authority-field';
    } else {
        fieldClass = 'term-additional-field';
    }
    
    htmlToReturn += '<div class="row field ' + fieldClass + '">' +
      '<div class="col-md-2">' +
        formFieldsToRender[field_name]['display_label'] +
      '</div>' +
      '<div class="col-md-10">' +
        '<input type="text" name="' + field_name + '" class="form-control input-sm term-field-form-element" />' +
      '</div>' +
    '</div>';
  });
  
  return htmlToReturn;
};

Hyacinth.DigitalObjectsApp.AuthorizedTermSelector.prototype.updateSearchResults = function() {

  if (this.updateInProgress) {
    return; //Don't allow overlapping updates
  }

  this.updateInProgress = true;

  var $containerElement = this.$containerElement;

  var that = this;

  $.ajax({
    url: '/controlled_vocabularies/' + this.controlledVocabularyStringKey + '/terms.json',
    type: 'GET',
    data: {
      q: this.latestSearchPhrase,
      page: this.currentPage,
      per_page: parseInt(($(window).height()-200)/35) // This seems to be a good formula for a reasonable number of results on various screen sizes
    },
    cache: false
  }).done(function(termResponse){
    $containerElement.find('.authorized_term_search_results').html(
      Hyacinth.DigitalObjectsApp.renderTemplate('digital_objects_app/widgets/authorized_term_selector/_search_results.ejs', {
        authorizedTerms: termResponse['terms'],
        page: that.currentPage,
        moreAvailable: termResponse['more_available'],
        currentUserCanAddTerms: termResponse['current_user_can_add_terms'],
        additionalFieldsForControlledVocabulary: that.additionalFieldsForControlledVocabulary
      })
    );

    that.updateInProgress = false;
  }).fail(function(jqXHR, textStatus, errorThrown){
    this.updateInProgress = false;
    if (jqXHR.status == 404) {
      alert('Could not find Controlled Vocabulary with string_key: ' + that.controlledVocabularyStringKey);
    } else {
      alert(Hyacinth.unexpectedAjaxErrorMessage);
    }
  });
};

//Clean up event handlers
Hyacinth.DigitalObjectsApp.AuthorizedTermSelector.prototype.dispose = function() {
  this.$containerElement.removeData(Hyacinth.DigitalObjectsApp.AuthorizedTermSelector.SELECTOR_DATA_KEY) // Break this (circular) reference.  This is important!

  this.$containerElement.off('click');
  this.$containerElement.find('.add_authorized_term_form').off('submit');
  this.$containerElement.find('input.authorized_term_search_q').off('keydown');
  this.$containerElement = null;
  this.$authorizedTermValueElement = null;
  this.$authorizedTermCodeElement = null;
  this.$authorizedTermValueUriElement = null;
  this.$authorizedTermAuthorityElement = null;
  this.$authorizedTermAuthorityUriElement = null;
  clearInterval(this.autoUpdateIntervalId);
};
