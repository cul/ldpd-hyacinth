Hyacinth.DigitalObjectsApp.FacetSelector = function(containerElementId, facetFieldName, searchWidget) {

  this.$containerElement = $('#' + containerElementId);
  this.facetFieldName = facetFieldName;
  this.searchWidget = searchWidget;

  this.currentPage = 1;
  this.facetPrefix = '';
  this.sort = null;

  this.init();
};

/*******************************
 *******************************
 * Class methods and variables *
 *******************************
 *******************************/

Hyacinth.DigitalObjectsApp.FacetSelector.SELECTOR_ELEMENT_CLASS = 'facet_selector';
Hyacinth.DigitalObjectsApp.FacetSelector.SELECTOR_DATA_KEY = 'facet_selector';

Hyacinth.DigitalObjectsApp.FacetSelector.getFacetSelectorInstanceForElement = function(element) {
  return $(element).closest('.' + Hyacinth.DigitalObjectsApp.FacetSelector.SELECTOR_ELEMENT_CLASS).data(Hyacinth.DigitalObjectsApp.FacetSelector.SELECTOR_DATA_KEY);
};

/*********************
 *********************
 * Instamnce methods *
 *********************
 *********************/

Hyacinth.DigitalObjectsApp.FacetSelector.prototype.init = function(){

  var that = this;

  //Add class to container element and add object reference to the container element
  this.$containerElement.addClass(Hyacinth.DigitalObjectsApp.FacetSelector.SELECTOR_ELEMENT_CLASS); //Add class to container element
  this.$containerElement.data(Hyacinth.DigitalObjectsApp.FacetSelector.SELECTOR_DATA_KEY, this); //Assign this editor object as data to the container element so that we can access it later

  this.$containerElement.html(Hyacinth.DigitalObjectsApp.renderTemplate('digital_objects_app/widgets/facet_selector/index.ejs'));

  this.$containerElement.on('click', '.add-facet-link', function(e){
    e.preventDefault();

    var facetValue = decodeURIComponent($(this).attr('data-facet-value'));

    Hyacinth.hideMainModal();
    that.searchWidget.addFacetToCurrentSearch(that.facetFieldName, facetValue);

  });

  this.$containerElement.on('click', '.remove-facet-link', function(e){
    e.preventDefault();

    var facetValue = decodeURIComponent($(this).attr('data-facet-value'));

    Hyacinth.hideMainModal();
    that.searchWidget.removeFacetFromCurrentSearch(that.facetFieldName, facetValue);
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

  this.$containerElement.on('click', '.switch-sort-link', function(e){
    e.preventDefault();
    that.sort = $(this).attr('data-new-sort');
    that.currentPage = 1;
    that.updateSearchResults();
  });

  this.updateSearchResults(); //Immediately update the search results

};

Hyacinth.DigitalObjectsApp.FacetSelector.prototype.updateSearchResults = function() {

  var $containerElement = this.$containerElement;

  var that = this;

  $.ajax({
    url: '/digital_objects/search.json',
    type: 'GET',
    data: {
      search: Hyacinth.ObjectHelpers.merge(Hyacinth.DigitalObjectsApp.params['search'], {rows: 0}),
      facet: {
        prefix: this.facetPrefix,
        field: this.facetFieldName,
        page: this.currentPage,
        sort: this.sort,
        per_page: parseInt(($(window).height()-200)/35) // This seems to be a good formula for a reasonable number of results on various screen sizes
      }
    },
    cache: false
  }).done(function(facetResponse){
    $containerElement.find('.facet_search_results').html(
      Hyacinth.DigitalObjectsApp.renderTemplate('digital_objects_app/widgets/facet_selector/_search_results.ejs', {
        facetFieldName: that.facetFieldName,
        facetValues: facetResponse['facets'][0]['values'],
        page: that.currentPage,
        moreAvailable: facetResponse['facets'][0]['more_available'],
        sort: facetResponse['facets'][0]['sort']
      })
    );

  }).fail(function(){
    alert(Hyacinth.unexpectedAjaxErrorMessage);
  });
};

//Clean up event handlers
Hyacinth.DigitalObjectsApp.FacetSelector.prototype.dispose = function() {
  this.$containerElement.removeData(Hyacinth.DigitalObjectsApp.FacetSelector.SELECTOR_DATA_KEY) // Break this (circular) reference.  This is important!

  this.$containerElement.off('click');
  this.$containerElement.find('.add_authorized_term_form').off('submit');
  this.$containerElement.find('input.authorized_term_search_q').off('keydown');
  this.$containerElement = null;
  this.searchWidget = null;
};
