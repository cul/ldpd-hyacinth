/* Columbia University Library
   Project: Synchronizer Module
   File: index.js
	 Description: Web Worker for Manipulating Index File Data
   Author: Ashley Pressley
   Date: 02/21/2018
	 Version: 1.0

   Comments: No longer utilized
*/

onmessage = function(e) {
  var panel = '';
  var timestamp = '';
  var title = '';
  var transcript = '';
  var synopsis = '';
  var keywords = '';
  var subjects = '';

  for (var i = 0; i < e.data.length; i++) {
    // We are only concerned with timestamped segments at this point of the parsing
    if (/(([0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9][0-9][0-9]\s-->\s[0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9][0-9][0-9]))+/.test(e.data[i])) {
      timestamp = e.data[i].substring(0, 12);

      while (e.data[i] !== "}" && i < e.data.length) {
        if (/("title":)+/.test(e.data[i])) {
          title = e.data[i];
          while (!/("partial_transcript":)+/.test(e.data[i + 1]) &&  i < e.data.length) {
            i++;
            title += e.data[i];
          }
        }

        if (/("partial_transcript":)+/.test(e.data[i])) {
          transcript = e.data[i];
          while (!/("description":)+/.test(e.data[i + 1]) &&  i < e.data.length) {
            i++;
            transcript += e.data[i];
          }
        }

        if (/("description":)+/.test(e.data[i])) {
          synopsis = e.data[i];
          while (!/("keywords":)+/.test(e.data[i + 1]) &&  i < e.data.length) {
            i++;
            synopsis += e.data[i];
          }
        }

        if (/("keywords":)+/.test(e.data[i])) {
          keywords = e.data[i];
          while (!/("subjects":)+/.test(e.data[i + 1]) &&  i < e.data.length) {
            i++;
            keywords += e.data[i];
          }
        }

        if (/("subjects":)+/.test(e.data[i])) {
          subjects = e.data[i];
          while (e.data[i + 1] !== "}" &&  i < e.data.length) {
            i++;
            subjects += e.data[i];
          }
        }

        i++;
      }

      // Now that we've gathered all the data for the variables, we build a panel
  		panel += '<div id="' + timestamp + '" class="segment-panel">';
  		panel += '<h3>' + timestamp + "-" + title + '</h3>';
  		panel += '<div>';
  		panel += '<div class="col-md-2 pull-right"><button class="btn btn-xs btn-secondary tag-edit">Edit</button> ';
  		panel += '<button class="btn btn-xs btn-primary tag-delete">Delete</button></div>';
  		panel += '<p>Synopsis: <span class="tag-segment-synopsis">' + synopsis + "</span></p>";
  		panel += '<p>Keywords: <span class="tag-keywords">' + keywords + "</span></p>";
  		panel += '<p>Subjects: <span class="tag-subjects">' + subjects + "</span></p>";
  		panel += '<p>Partial Transcript: <span class="tag-partial-transcript">' + transcript + "</span></p>";
  		panel += '</div></div>';
    }
  }

  postMessage(panel);
}
