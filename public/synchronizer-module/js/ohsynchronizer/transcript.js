/* Columbia University Library
   Project: Synchronizer Module
   File: transcript.js
	 Description: Web Worker for Manipulating Transcript File Data
   Author: Ashley Pressley
   Date: 02/15/2018
	 Version: 1.1
*/

onmessage = function(e) {
  var first = false;
  var nextSync = false;
  var workerResult = '';
  for (var i = 0; i < e.data.length; i++) {
    // If we don't have timestamps yet, we need to skip any metadata and find the actual transcript
    if (/(<v)+/.test(e.data[i])) first = true;

    // We don't save any interview-level data from the transcript, so we ignore everything until the first timestamp
    if (/(([0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9][0-9][0-9]\s-->\s[0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9][0-9][0-9]))+/.test(e.data[i])) {
      if (!first) first = true;
      var timestamp = e.data[i][3] !== "0" ? (e.data[i][3] + e.data[i][4]) : e.data[i][4];
      if (timestamp !== "0") {
        workerResult += '<span class="transcript-timestamp">{' + timestamp + ':00}&nbsp;</span>';
        nextSync = true;
      }
      continue;
    }
    else if (first) {
      if (e.data[i] == "" && e.data[i-1] == "") continue;
      e.data[i] = e.data[i].replace("<v ", '');
      e.data[i] = e.data[i].replace("</v>", '');
      e.data[i] = e.data[i].replace(/((>\s))+/, ": ");
      var words = e.data[i].split(/\s/);

      for (var j = 0; j < words.length; j++) {
        if (nextSync) workerResult += '<span class="transcript-word transcript-clicked">' + words[j] + '</span>&nbsp;';
        else workerResult += '<span class="transcript-word">' + words[j] + '</span>&nbsp;';
        nextSync = false;
      }
      workerResult += '\r\n';
    }
  }
  postMessage(workerResult);
}
