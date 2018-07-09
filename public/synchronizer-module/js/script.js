// Document Ready
(function($){
	// Don't show the A/V controls, errorBar, or Tag button
	$("#video").hide();
	$("#audio").hide();
	$("#tag-segment-btn").hide();
	$("#tag-controls").hide();
	$("#sync-controls").hide();
	$("#finish-area").hide();
	$("#transcript-preview").hide();

	// Initialize close buttons, tabs, and accordion
	OHSynchronizer.Index.closeButtons();

	$("#text-tabs").tabs({
		active: 0
	});

	// If the Index tab is clicked, ensure transcript looping is deactivated
	$('a[href$="tabs-index"]').click(function () {
		OHSynchronizer.looping = -1;
	});

	// Disallow non-numerical values in transcript controls
	// Only allow 0-9, backspace, and delete
	$('#sync-roll').keypress(function (event) {
		if (event.shiftKey == true) { event.preventDefault(); }
		if ((event.charCode >= 48 && event.charCode <= 57) || event.keyCode == 8 || event.keyCode == 46 || event.keyCode == 37 || event.keyCode == 39) { }
		else { event.preventDefault(); }
	});

	// Never let the transcript roll control be empty
	$('#sync-roll').blur(function () {
		if(!$(this).val()) { $(this).val('0'); }
	});

	// If the dropdown list is changed, change the active tab to the selected dropdown item
	$("#file-type, #input-text").click(function() {
		var selected = "#tabs-" + $("#file-type").val();
		$('#text-tabs a[href="' + selected + '"]').trigger('click');
		$('.preview-button').on('click', function() {
			OHSynchronizer.Export.previewWork($("#file-type").val());
		});
	});

	// Load YouTube Frame API
	var tag = document.createElement('script');
	tag.src = "https://www.youtube.com/iframe_api";
	var firstScriptTag = document.getElementsByTagName('script')[0];
	firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

	// Scroll to top function
	$('#working-area').scroll(function() {
		$('#media-playback').css('top', $(this).scrollTop());
	});
	// Here we post success messages for uploaded files
	OHSynchronizer.Events.uploadsuccess = function(event) {
		var file = event.detail;
		var success = "";
		success += '<div class="col-md-6"><i class="fa fa-times-circle-o close"></i><p class="success-bar"><strong>Upload Successful</strong><br />File Name: ' + file.name + "<br />File Size: " + parseInt(file.size / 1024, 10) + "<br />File Type: " + file.type + "<br />Last Modified Date: " + new Date(file.lastModified) + "</div>";
		$("#messagesBar").append(success);
	};
	// Here we post success messages for streaming/hls links
	OHSynchronizer.Events.hlssuccess = function(event) {
		var url = event.detail;
		var success = "";
		success += '<div class="col-md-6"><i class="fa fa-times-circle-o close"></i><p class="success-bar"><strong>Upload Successful</strong><br />The Wowza URL ' + url + " was successfully ingested.</div>";
		$("#messagesBar").append(success);
	};
}(jQuery));
