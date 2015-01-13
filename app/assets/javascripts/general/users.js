// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function(){
  Hyacinth.Users.setupNewUserFormRandomPasswordFeature();
});

Hyacinth.Users = {};

Hyacinth.Users.PasswordGenerator = {};

Hyacinth.Users.PasswordGenerator.getRandomPassword = function(length) {
  // From: http://stackoverflow.com/questions/10726909/random-alpha-numeric-string-in-javascript

  var chars = '01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  var result = '';
  for (var i = length; i > 0; --i) result += chars[Math.round(Math.random() * (chars.length - 1))];

  return result;
};

Hyacinth.Users.setupNewUserFormRandomPasswordFeature = function() {

  if ($('#generate_random_password_button').length == 0) {
    return;
  }

  var generateButton = $('#generate_random_password_button');
  var passwordPreviewTextField = $('#generated_random_password');
  var passwordTextField = $('#user_password');
  var confirmPasswordTextField = $('#user_password_confirmation');

  generateButton[0].onclick = function(){
    var randomPassword = Hyacinth.Users.PasswordGenerator.getRandomPassword(14);
    passwordPreviewTextField.val(randomPassword);
    passwordTextField.val(randomPassword);
    confirmPasswordTextField.val(randomPassword);
  };
};
