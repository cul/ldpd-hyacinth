Hyacinth.defineNamespace('Hyacinth.Term');

$(document).ready(function(){
  if ($('#add-or-edit-term-form').length > 0) {
    Hyacinth.Term.hideAndShowFields();
    $('#term-type-selector').bind('change', Hyacinth.Term.hideAndShowFields);
  }
});

Hyacinth.Term.hideAndShowFields = function(){
  var type = $('#term-type-selector').val();
  var $addOrEditTermForm = $('#add-or-edit-term-form');
  
  if (type == 'external') {
    $addOrEditTermForm.find('.term-authority-field').show();
    $addOrEditTermForm.find('.term-uri-field').show();
    $addOrEditTermForm.find('.term-additional-field').show();
  } else if (type == 'local') {
    $addOrEditTermForm.find('.term-authority-field').show();
    $addOrEditTermForm.find('.term-uri-field').hide();
    $addOrEditTermForm.find('.term-uri-field').find('input').val(''); // clear value of uri input
    $addOrEditTermForm.find('.term-additional-field').show();
  } else if (type == 'temporary') {
    $addOrEditTermForm.find('.term-authority-field').hide();
    $addOrEditTermForm.find('.term-uri-field').hide().val('');
    $addOrEditTermForm.find('.term-uri-field').find('input').val(''); // clear value of uri input
    $addOrEditTermForm.find('.term-additional-field').hide();
    $addOrEditTermForm.find('.term-additional-field').find('input').val(''); // clear values of child inputs
  }
};