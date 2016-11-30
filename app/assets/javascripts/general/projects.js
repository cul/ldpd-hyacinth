Hyacinth.defineNamespace('Hyacinth.Project');

$(document).ready(function(){
  if ($('.chosen-select').length > 0) {
    $('.chosen-select').chosen({
      allow_single_deselect: true,
      no_results_text: 'No results matched',
      width: '100%'
    });
  }
});