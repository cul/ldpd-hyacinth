Hyacinth.DigitalObjectsApp.AuthorizedTermSelector = function(containerElementId, $controlledTermUriFieldElement, $controlledTermValueDisplayElement) {

  this.$containerElement = $('#' + containerElementId);
  this.$controlledTermUriFieldElement = $($controlledTermUriFieldElement);
  this.$controlledTermValueDisplayElement = this.$controlledTermUriFieldElement.closest('.controlled_term_field').find('.controlled_term_value_display')
  this.$clearButtonElement = this.$controlledTermUriFieldElement.closest('.controlled_term_field').find('.controlled_term_clear_button');

  this.controlledVocabularyStringKey = this.$controlledTermUriFieldElement.attr('data-controlled-vocabulary-string-key');
  this.controlledVocabularyDisplayLabel = this.$controlledTermUriFieldElement.attr('data-controlled-vocabulary-display-label');
  
  this.latestSearchPhrase = null;
  this.currentPage = 1;
  this.autoUpdateIntervalId = null;
  this.updateInProgress = false;

  this.init();
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

  this.$containerElement.find('.add_authorized_term_form').on('submit', function(e){
    e.preventDefault();

    var $submitButton = that.$containerElement.find('.add_authorized_term_form').find('.add_authorized_term_form_submit_button');
    $submitButton.attr('data-original-html', $submitButton.html()).html('Adding term...');

    $.ajax({
      url: '/terms.json',
      type: 'POST',
      data: {
        authorized_term: {
          value: $(this).find('input[name="value"]').val(),
          value_uri: $(this).find('input[name="value_uri"]').val(),
          controlled_vocabulary_string_key: that.controlledVocabularyStringKey
        }
      },
      cache: false
    }).done(function(createAuthorizedTermResponse){

      var $submitButton = that.$containerElement.find('.add_authorized_term_form').find('.add_authorized_term_form_submit_button');
      $submitButton.html($submitButton.attr('data-original-html'));

      if (typeof(createAuthorizedTermResponse['errors']) !== 'undefined') {
        var errors = '<ul class="errors">';

        fields_and_display_labels = [
          {name: 'value', display_label: 'Value (required)'},
          {name: 'uri', display_label: 'URI (leave blank for local term)'}
        ]

        for (var i = 0; i < fields_and_display_labels.length; i++) {
          if(typeof(createAuthorizedTermResponse['errors'][fields_and_display_labels[i]['name']]) !== 'undefined') {
            errors += '<li><strong>' + fields_and_display_labels[i]['display_label'] + '</strong> ' + createAuthorizedTermResponse['errors'][fields_and_display_labels[i]['name']].join('</li><li><strong>' + fields_and_display_labels[i]['display_label'] + '</strong> ') + '</li>';
          }
        }

        errors += '</ul>';

        that.$containerElement.find('.add_authorized_term_form').find('.errors').html('<div class="alert alert-danger">' + errors + '</div>');
      } else {
        //Success!

        that.$authorizedTermValueElement.val(createAuthorizedTermResponse['value_uri']);
        that.$authorizedTermValueElement.attr('data-display-value', createAuthorizedTermResponse['value']);

        that.$authorizedTermValueElement.val(createAuthorizedTermResponse['value']);
        if (that.$authorizedTermCodeElement != null) { that.$authorizedTermCodeElement.val(createAuthorizedTermResponse['code']); }
        if (that.$authorizedTermValueUriElement != null) { that.$authorizedTermValueUriElement.val(createAuthorizedTermResponse['value_uri']); }
        if (that.$authorizedTermAuthorityElement != null) { that.$authorizedTermAuthorityElement.val(createAuthorizedTermResponse['authority']); }
        if (that.$authorizedTermAuthorityUriElement != null) { that.$authorizedTermAuthorityUriElement.val(createAuthorizedTermResponse['authority_uri']); }


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
        currentUserCanAddTerms: termResponse['current_user_can_add_terms']
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
