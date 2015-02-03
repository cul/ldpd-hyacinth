// This is a manifest file that'll be compiled into digital_objects_app.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
// Load certain files in a particular order (because of dependencies)
//= require './digital_objects_app/digital_objects_app.js'
//= require_tree './digital_objects_app/core'
// Need to load base digital object model before subclasses
//= require './digital_objects_app/models/digital_object/base.js'
// And then load everything else
//= require_tree './digital_objects_app'
