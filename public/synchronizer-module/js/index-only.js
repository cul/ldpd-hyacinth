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

	// Update the Tag Segment timestamp when the modal opens from Add Segment
	$('.tag-add-segment').click(function () {
		$(".tag-controls").show();
		OHSynchronizer.playerControls.updateTimestamp();
	});

	$('.preview-button').bind('click', function() {
		OHSynchronizer.Export.previewWork('index');
	});

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
	var info = {
		media: "https://ldpd-wowza-test1.svc.cul.columbia.edu:8443/vod/mp4:CARN27_v_1_READY_TO_EXPORT.mp4/playlist.m3u8",
		index: "./assets/OHMS-Sample-003.metadata.vtt",
		transcript: "./assets/OHMS-Sample-003.captions.vtt"
	};
	OHSynchronizer.Import.mediaFromUrl(info.media);
	var previewOnly = false;
	var widget = new OHSynchronizer.Index('input-index', previewOnly);
	var xhr = new XMLHttpRequest();
	xhr.open('GET', info.index, true);
	xhr.responseType = 'blob';
	xhr.onload = function(e) {
		var blob = new Blob([xhr.response], {type: 'text/vtt'});
		widget.renderText(blob, 'vtt');
	};
	xhr.send();
}(jQuery));