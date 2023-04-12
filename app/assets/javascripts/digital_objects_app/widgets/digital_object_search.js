Hyacinth.DigitalObjectsApp.DigitalObjectSearch = function(containerElementId, options) {
  this.$containerElement = $('#' + containerElementId);
  this.currentFacetSelector = null;
  this.searchCounter = 1;   // Search counter is just used for invalidating old result sets when paging through results.
                            // A new search updates the search counter and invalidates the previous "current search".

  this.init();
};
/*******************************
 *******************************
 * Class methods and variables *
 *******************************
 *******************************/

Hyacinth.DigitalObjectsApp.DigitalObjectSearch.DIGITAL_OBJECT_SEARCH_ELEMENT_CLASS = 'digital-object-search';
Hyacinth.DigitalObjectsApp.DigitalObjectSearch.DIGITAL_OBJECT_SEARCH_DATA_KEY = 'digital_object_search';

Hyacinth.DigitalObjectsApp.DigitalObjectSearch.getInstanceForElement = function(element) {
  return $(element).closest('.' + Hyacinth.DigitalObjectsApp.DigitalObjectSearch.DIGITAL_OBJECT_SEARCH_ELEMENT_CLASS).data(Hyacinth.DigitalObjectsApp.DigitalObjectSearch.DIGITAL_OBJECT_SEARCH_DATA_KEY);
};

Hyacinth.DigitalObjectsApp.DigitalObjectSearch.facetValueExistsInParams = function(facetFieldName, facetValue) {
  if( ! Hyacinth.DigitalObjectsApp.DigitalObjectSearch.facetFieldExistsInParams(facetFieldName) ) {
    return false;
  }

  if(Hyacinth.DigitalObjectsApp.params['search']['f'][facetFieldName].indexOf(facetValue) == -1) {
    return false;
  }
  return true;
};

Hyacinth.DigitalObjectsApp.DigitalObjectSearch.facetFieldExistsInParams = function(facetFieldName) {
  if ( ! Hyacinth.DigitalObjectsApp.DigitalObjectSearch.facetsExistInParams() ) {
    return false;
  }

  if(typeof(Hyacinth.DigitalObjectsApp.params['search']['f'][facetFieldName]) == 'undefined') {
    return false;
  }
  return Hyacinth.DigitalObjectsApp.params['search']['f'][facetFieldName].length > 0;
};

Hyacinth.DigitalObjectsApp.DigitalObjectSearch.getFacetFieldValuesFromParams = function(facetFieldName) {
  if ( ! Hyacinth.DigitalObjectsApp.DigitalObjectSearch.facetFieldExistsInParams(facetFieldName) ) {
    return [];
  }

  return Hyacinth.DigitalObjectsApp.params['search']['f'][facetFieldName];
};

Hyacinth.DigitalObjectsApp.DigitalObjectSearch.facetsExistInParams = function() {
  if(typeof(Hyacinth.DigitalObjectsApp.params['search']['f']) == 'undefined') {
    return false;
  }

  var facetFieldsInParams = Object.keys(Hyacinth.DigitalObjectsApp.params['search']['f']);
  if (facetFieldsInParams.length > 0) {
    for(var i = 0; i < facetFieldsInParams.length; i++) {
      if(Hyacinth.DigitalObjectsApp.params['search']['f'][facetFieldsInParams[i]].length > 0) {
        return true;
      }
    }
  }

  return false;
};

/**************************
 * Facet Selection Dialog *
 **************************/

Hyacinth.DigitalObjectsApp.DigitalObjectSearch.showFacetSelectorModal = function(showMoreButton) {

  var $showMoreButton = $(showMoreButton);

  var searchWidget = Hyacinth.DigitalObjectsApp.DigitalObjectSearch.getInstanceForElement($showMoreButton);

  if (searchWidget.currentFacetSelector != null) {
    searchWidget.currentFacetSelector.dispose(); //Always clean up the old instance and any event bindings it might have
    searchWidget.currentFacetSelector = null;
  }

  Hyacinth.showMainModal(
    $showMoreButton.attr('data-facet-display-label'),
    '<div id="facet-selector"></div>',
    '<button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>'
  );

  searchWidget.currentFacetSelector = new Hyacinth.DigitalObjectsApp.FacetSelector('facet-selector', $showMoreButton.attr('data-facet-field-name'), searchWidget);
};

/**********************************
 **********************************
 * Instance methods and variables *
 **********************************
 **********************************/

/*******************
 * Setup / Cleanup *
 *******************/

Hyacinth.DigitalObjectsApp.DigitalObjectSearch.prototype.init = function() {

  var that = this;

  this.$containerElement.addClass(Hyacinth.DigitalObjectsApp.DigitalObjectSearch.DIGITAL_OBJECT_SEARCH_ELEMENT_CLASS); //Add class to container element
  this.$containerElement.data(Hyacinth.DigitalObjectsApp.DigitalObjectSearch.DIGITAL_OBJECT_SEARCH_DATA_KEY, this); //Assign this editor object as data to the container element so that we can access it later

  //If the current params hash doesn't contain a 'search' key, add it now.  We depend on this being present in later JS code.
  if(typeof(Hyacinth.DigitalObjectsApp.params['search']) == 'undefined' ) {
    Hyacinth.DigitalObjectsApp.params['search'] = {'search' : 'true'};
  }

  //Update mostRecentSearchParams with a copy of the current search params.  This will be used for:
  // 1) Returning to the last set of search results
  // 2) Paging through results, one by one.
  Hyacinth.DigitalObjectsApp.mostRecentSearchParams = Hyacinth.ObjectHelpers.deepClone(Hyacinth.DigitalObjectsApp.params['search']);

  //Load search results for current params
  $.ajax({
    url: '/digital_objects/search.json',
    type: 'POST',
    data: {
      search: Hyacinth.DigitalObjectsApp.params['search'],
      facet: {defaults: true}, // Note: It doesn't actually matter what value is passed into the facets value object, as long as at least one key-value pair is present.
      include_single_field_searchable_field_list: true
    },
    cache: false
  }).done(function(searchResponse){

    // If there are zero results, no facets will show up because no facets apply to a search with zero results.
    // If we don't handle this case, this would be a problem because currently-applied facets wouldn't show up
    if(Hyacinth.DigitalObjectsApp.DigitalObjectSearch.facetsExistInParams()) {
      $.each(searchResponse['facets'], function(i, facet){
        if (facet['values'].length == 0 && Hyacinth.DigitalObjectsApp.DigitalObjectSearch.facetFieldExistsInParams(facet['facet_field_name'])) {
          Hyacinth.DigitalObjectsApp.DigitalObjectSearch.getFacetFieldValuesFromParams(facet['facet_field_name']).forEach(function(value){
            facet['values'].push({value: value, count: 0});
          });
        }
      });
    }

    //Setup base html from template
    that.$containerElement.html(
      Hyacinth.DigitalObjectsApp.renderTemplate('digital_objects_app/widgets/digital_object_search/index.ejs', {searchResponse: searchResponse})
    );

    //Hide facets
    $('.facet-group .facet-value-list.collapsed, .facet-group .facet-value-list.collapsed .count').hide();
    //Bind facet hide/show toggle
    that.$containerElement.find('.facet-group .toggle-facet-view').on('click', function(e){
      e.preventDefault();
      var $facetViewList = $(this).closest('.facet-group').find('.facet-value-list');
      if ($facetViewList.is(':visible')) {
        $facetViewList.find('.count').hide();
        $facetViewList.slideUp(200);
        $(this).closest('.facet-group').find('button span').removeClass('glyphicon-chevron-down').addClass('glyphicon-chevron-right');
      } else {
        $(this).closest('.facet-group').find('button span').removeClass('glyphicon-chevron-right').addClass('glyphicon-chevron-down');
        $facetViewList.slideDown(200, function(){
          $facetViewList.find('.count').show();
        });
      }

      $(this).blur();
    });

    //Bind facet add handlers
    that.$containerElement.find('.facet-group .add-facet-link').on('click', function(e){
      e.preventDefault();
      that.addFacetToCurrentSearch($(this).attr('data-facet-field-name'), decodeURIComponent($(this).attr('data-uri-encoded-value')));
    });

    //Bind facet removal handlers
    that.$containerElement.find('.facet-group .remove-facet-link, .query-constraints .remove-facet-link').on('click', function(e){
      e.preventDefault();
      that.removeFacetFromCurrentSearch($(this).attr('data-facet-field-name'), decodeURIComponent($(this).attr('data-uri-encoded-value')));
    });

    //Bind filter removal handlers
    that.$containerElement.find('.query-constraints .remove-filter-link').on('click', function(e){
      e.preventDefault();
      that.removeFilterFromCurrentSearch($(this).attr('data-filter-field-name'), decodeURIComponent($(this).attr('data-uri-encoded-operator')), decodeURIComponent($(this).attr('data-uri-encoded-value')));
    });

    //Setup More Facets Dialog
    that.$containerElement.find('.show-facet-selector').on('click', function(){
      Hyacinth.DigitalObjectsApp.DigitalObjectSearch.showFacetSelectorModal($(this));
    });

    //Bind custom filter handler
    that.$containerElement.find('.custom-filter-form').on('submit', function(e){
      e.preventDefault();
      var field = $(this).find('[name="custom_filter_field"]').val();
      var operator = $(this).find('[name="custom_filter_operator"]').val();
      var value = $(this).find('[name="custom_filter_value"]').val();
      
      if (field == '') {
        return;
      }
      
      if (operator == 'present' || operator == 'absent') {
        value = ''; //Value doesn't make sense to send if we choose the present or absent operators
      }
      that.addFilterToCurrentSearch(field, operator, value);
    });

    //Swap front / back image handler
    that.$containerElement.find('.swap-front-back').on('click', function(){

      var $thumbnailImg = $(this).closest('.thumbnail-wrapper').find('img.thumbnail');
      var pid = $thumbnailImg.attr('data-pid');
      Hyacinth.addAlert('Swapping front and back images...', 'info');
      $.ajax({
        url: '/digital_objects/' + pid + '/swap_order_of_first_two_child_assets',
        type: 'POST',
        cache: false
      }).done(function(swapResponse){
        if (swapResponse['success']) {
          $thumbnailImg.attr('src', $thumbnailImg.attr('src').replace(/(.+\/images\/)([^\/]+)(\/.+)/, '$1' + swapResponse['ordered_child_digital_object_pids'][0] + '$3'));
          Hyacinth.addAlert('Images swapped.', 'info');
        } else {
          Hyacinth.addAlert('An error occurred during the rotation attempt:<br />' + swapResponse['errors'].join(', '), 'danger');
        }
      });
    });

    //Bind image rotate handlers
    $('.rotate-dropdown-options li a').on('click', function(e){
      e.preventDefault();
      var rotateBy = parseInt($(this).attr('data-rotate-by'));
      var $thumbnailImg = $(this).closest('.thumbnail-wrapper').find('img.thumbnail');
      var pid = $thumbnailImg.attr('data-pid');
      $thumbnailImg.css('opacity', '.3');
      Hyacinth.addAlert('Rotating image...', 'info');
      $.ajax({
        url: '/digital_objects/' + pid + '/rotate_image',
        type: 'POST',
        data: {
          rotate_by: rotateBy
        },
        cache: false
      }).done(function(rotationResponse){
        $thumbnailImg.css('opacity', '1');
        if (rotationResponse['success']) {
          // Re-fetch the image with {cache: 'reload'} to bust the local browser cache
          fetch($thumbnailImg.attr('src'), {method:'GET', cache: 'reload'}).then(function(){
            $thumbnailImg.attr('src', $thumbnailImg.attr('src'));
            Hyacinth.addAlert('Image has been rotated and queued for derivative regeneration.<br /><br /><strong>Note:</strong> A hard page might be required to view the change globally (because of browser caching).', 'info');
          });
        } else {
          Hyacinth.addAlert('An error occurred during the rotation attempt:<br />' + rotationResponse['errors'].join(', '), 'danger');
        }
      }).fail(function(){
        alert(Hyacinth.unexpectedAjaxErrorMessage);
      });
    });

    //Pre-populate form values based on params
    var $searchForm = that.$containerElement.find('.digital-object-search-form');

    if(Hyacinth.DigitalObjectsApp.params['search']['search_field']) {
      $searchForm.find('[name="search_field"]').val(Hyacinth.DigitalObjectsApp.params['search']['search_field']);
    }
    if(Hyacinth.DigitalObjectsApp.params['search']['q']) {
      $searchForm.find('[name="q"]').val(Hyacinth.DigitalObjectsApp.params['search']['q']);
    }
    if(Hyacinth.DigitalObjectsApp.params['search']['sort']) {
      $searchForm.find('[name="sort"]').val(Hyacinth.DigitalObjectsApp.params['search']['sort']);
    }
    if(Hyacinth.DigitalObjectsApp.params['search']['per_page']) {
      $searchForm.find('[name="per_page"]').val(Hyacinth.DigitalObjectsApp.params['search']['per_page']);
    }

    //Bind search form submit handler
    that.$containerElement.on('submit', 'form.digital-object-search-form', function(e){
      e.preventDefault();
      that.submitSearchForm(1);
    });
    
    //Bind CSV export button
    that.$containerElement.on('click', '.csv_export_button', function(e){
      e.preventDefault();
      that.exportSearchResultsToCsv();
    });

    //Bind sort change handler
    that.$containerElement.on('change', '[name="sort"]', function(e){
      e.preventDefault();
      that.submitSearchForm(1);
    });

    //Bind sort change handler
    that.$containerElement.on('change', '[name="per_page"]', function(e){
      e.preventDefault();
      that.submitSearchForm(1);
    });

    //Bind page change handler
    that.$containerElement.find('.pagination').find('.goto-page').on('click', function(e){
      e.preventDefault();
      that.submitSearchForm(parseInt($(this).attr('data-page')));
    });

  }).fail(function(){
    alert(Hyacinth.unexpectedAjaxErrorMessage);
  });

};

Hyacinth.DigitalObjectsApp.DigitalObjectSearch.prototype.submitSearchForm = function(page) {
  currentSearchFormParams = this.getCurrentSearchFormParams();
  currentSearchFormParams['search']['page'] = page;
  this.searchCounter++;
  document.location.hash = Hyacinth.DigitalObjectsApp.paramsToHashValue(currentSearchFormParams);
}

Hyacinth.DigitalObjectsApp.DigitalObjectSearch.prototype.exportSearchResultsToCsv = function() {
  $.ajax({
    url: '/digital_objects/search_results_to_csv.json',
    type: 'POST',
    data: {
      search: Hyacinth.DigitalObjectsApp.params['search']
    },
    cache: false
  }).done(function(exportResponse){
    Hyacinth.addAlert('Export has been queued as a background job. <a target="_blank" href="/csv_exports?highlight=' + exportResponse['csv_export_id'] + '">Click here</a> to monitor the job status.', 'success', 10000);
  }).fail(function(){
    alert(Hyacinth.unexpectedAjaxErrorMessage);
  });
}

Hyacinth.DigitalObjectsApp.DigitalObjectSearch.prototype.getCurrentSearchFormParams = function() {
    var $searchForm = this.$containerElement.find('.digital-object-search-form');

    //Merge form values into params
    var currentSearchFormParams = Hyacinth.ObjectHelpers.deepClone(Hyacinth.DigitalObjectsApp.params);
    currentSearchFormParams['search']['search_field'] = $searchForm.find('[name="search_field"]').val();
    currentSearchFormParams['search']['q'] = $searchForm.find('[name="q"]').val();
    currentSearchFormParams['search']['sort'] = $searchForm.find('[name="sort"]').val();
    currentSearchFormParams['search']['per_page'] = $searchForm.find('[name="per_page"]').val();
    currentSearchFormParams['search']['search_counter'] = this.searchCounter;
    
    return currentSearchFormParams;
}

Hyacinth.DigitalObjectsApp.DigitalObjectSearch.prototype.addFacetToCurrentSearch = function(facetFieldName, facetValue) {
  var newParams = Hyacinth.ObjectHelpers.deepClone(Hyacinth.DigitalObjectsApp.params);
  if(typeof(newParams['search']['f']) == 'undefined') {
    newParams['search']['f'] = {};
  }
  if(typeof(newParams['search']['f'][facetFieldName]) == 'undefined') {
    newParams['search']['f'][facetFieldName] = [];
  }
  newParams['search']['f'][facetFieldName].push(facetValue);
  newParams['search']['page'] = 1;
  document.location.hash = Hyacinth.DigitalObjectsApp.paramsToHashValue(newParams);
};

Hyacinth.DigitalObjectsApp.DigitalObjectSearch.prototype.removeFacetFromCurrentSearch = function(facetFieldName, facetValue) {
  var newParams = Hyacinth.ObjectHelpers.deepClone(Hyacinth.DigitalObjectsApp.params);
  if(typeof(newParams['search']['f']) == 'undefined') {
    return;
  }
  if(typeof(newParams['search']['f'][facetFieldName]) == 'undefined') {
    return;
  }
  var indexOfValue = newParams['search']['f'][facetFieldName].indexOf(facetValue);
  if(indexOfValue == -1) {
    return;
  }

  //Remove item from array
  newParams['search']['f'][facetFieldName].splice(indexOfValue, 1); //Splice acts directly on the array
  newParams['search']['page'] = 1;
  document.location.hash = Hyacinth.DigitalObjectsApp.paramsToHashValue(newParams);
};

Hyacinth.DigitalObjectsApp.DigitalObjectSearch.prototype.addFilterToCurrentSearch = function(filterFieldName, filterOperator, filterValue) {
  var newParams = Hyacinth.ObjectHelpers.deepClone(Hyacinth.DigitalObjectsApp.params);
  if(typeof(newParams['search']['fq']) == 'undefined') {
    newParams['search']['fq'] = {};
  }
  if(typeof(newParams['search']['fq'][filterFieldName]) == 'undefined') {
    newParams['search']['fq'][filterFieldName] = [];
  }
  var valToSend = {};
  valToSend[filterOperator] = filterValue;
  newParams['search']['fq'][filterFieldName].push(valToSend);
  newParams['search']['page'] = 1;
  document.location.hash = Hyacinth.DigitalObjectsApp.paramsToHashValue(newParams);
};

Hyacinth.DigitalObjectsApp.DigitalObjectSearch.prototype.removeFilterFromCurrentSearch = function(filterFieldName, filterOperator, filterValue) {
  var newParams = Hyacinth.ObjectHelpers.deepClone(Hyacinth.DigitalObjectsApp.params);
  if(typeof(newParams['search']['fq']) == 'undefined') {
    return;
  }
  if(typeof(newParams['search']['fq'][filterFieldName]) == 'undefined') {
    return;
  }
  var indexOfValue = -1;
  newParams['search']['fq'][filterFieldName].forEach(function(operatorAndValue, index){
    $.each(operatorAndValue, function(operator, existingValue){
      if (operator == filterOperator && existingValue == filterValue) {
        indexOfValue = index;
      }
    });
  });

  if(indexOfValue == -1) {
    return;
  }

  //Remove item from array
  newParams['search']['fq'][filterFieldName].splice(indexOfValue, 1); //Splice acts directly on the array
  newParams['search']['page'] = 1;
  document.location.hash = Hyacinth.DigitalObjectsApp.paramsToHashValue(newParams);
};

//Clean up event handlers
Hyacinth.DigitalObjectsApp.DigitalObjectSearch.prototype.dispose = function() {
  this.$containerElement.removeData(Hyacinth.DigitalObjectsApp.DigitalObjectSearch.DIGITAL_OBJECT_SEARCH_DATA_KEY) // Break this (circular) reference.  This is important!
  this.$containerElement.on('click');
  this.$containerElement.off('submit');
  this.$containerElement.off('change');
  this.$containerElement.find('.facet-group .toggle-facet-view').off('click');
  this.$containerElement.find('.facet-group .add-facet-link').off('click');
  this.$containerElement.find('.facet-group .remove-facet-link, .query-constraints .remove-facet-link').off('click');
  this.$containerElement.find('.custom-filter-form').off('submit');
  this.$containerElement.find('.query-constraints .remove-filter-link').off('click');
  this.$containerElement.find('.pagination').find('.goto-page').off('click');
  this.$containerElement.find('.show-facet-selector').off('click');
  this.$containerElement.find('.swap-front-back').off('click');
  this.$containerElement.find('.rotate-dropdown-options li a').off('click');
  if (this.currentAuthorizedTermSelector != null) {
    this.currentFacetSelector.dispose(); //Always clean up the old instance and any event bindings it might have
    this.currentFacetSelector = null;
  }
};
