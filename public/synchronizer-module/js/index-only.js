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
		// media: "https://www.rmp-streaming.com/media/bbb-360p.mp4",
		media: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8",
		index: "./assets/empty.vtt",
		transcript: "./assets/OHMS-Sample-003.captions.vtt"
	};

	var widgetOptions = { previewOnly: false };
	var player = {
		type: 'video',
		url: info.media
	}
	var index = {
		id: 'input-index',
		url: info.index
	}
	var widget = new OHSynchronizer({player: player, index: index, options: widgetOptions});

	if (widgetOptions.previewOnly) {
		widget.hideFinishingControls();
	} else {
		$('.preview-button').on('click', function() {
			widget.index.preview();
		});
	}
}(jQuery));