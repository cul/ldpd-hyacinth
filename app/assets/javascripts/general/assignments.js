Hyacinth.defineNamespace('Hyacinth.Assignment');

$(document).ready(function(){
  if ($('.assignment-note-toggle').length > 0) {
    $('.assignment-note-toggle').on('click', function(e){
      $assignmentNote = $(this).closest('.assignment-note');
      if($assignmentNote.find('.assignment-note-short').is(':visible')) {
        $assignmentNote.find('.assignment-note-short').hide();
        $assignmentNote.find('.assignment-note-full').show();
      } else {
        $assignmentNote.find('.assignment-note-full').hide();
        $assignmentNote.find('.assignment-note-short').show();
      }
      //Swap toggle text
      var toggleText = $(this).attr('data-alt-toggle-text');
      $(this).attr('data-alt-toggle-text', $(this).html());
      $(this).html(toggleText);
      $(this).blur(); //do not keep button selected after click
    });
  }
});
