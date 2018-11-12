/* Columbia University Library
   Project: Synchronizer Module
   File: transcript-preview.js
	 Description: Web Worker for Displaying Transcript File Data
   Authors: Ashley Pressley, Benjamin Armintor
   Date: 07/09/2018
	 Version: 1.1
*/

onmessage = function(e) {
  var first = false;
  var nextSync = false;
  var workerResult = '<p>';
  var text = e.data;
  var timestampRegex = /^(\d{2}):(\d{2}):\d{2}\..+/;
  for (var i = 0; i < text.length; i++) {
    if (/(([0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]{3}\s-->\s[0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]{3}))+/.test(text[i])) {
      if (!first) first = true;
      var timestamp = timestampRegex.exec(text[i]);
      var timestampHour = timestamp[1];
      var timestampMinute = timestamp[2];
      var minute = parseInt(timestampHour) * 60 + parseInt(timestampMinute);
      if (minute !== 0) {
        workerResult += '<span class="preview-minute">[' + minute + ':00]&nbsp;</span>';
      }
      continue;
    } else if (first) {
      workerResult += text[i] + '<br />';
    }
  }
  workerResult += "</p>"
  postMessage(workerResult);
}
