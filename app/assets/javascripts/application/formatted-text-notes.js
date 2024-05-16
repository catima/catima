$(document).ready(function(){
  var ftFields = $('div.formatted-text');
  for (var i=0; i < ftFields.length; i++){
    prepareFootnotesForTextField(ftFields[i]);
    prepareEndnotesForTextField(ftFields[i]);
  }
});

function prepareFootnotesForTextField(fld){
  var footnotes = fld.querySelectorAll('span.footnote');
  for (var i=0; i < footnotes.length; i++){
    var fn = footnotes[i];
    var fnRef = document.createElement('sup');
    fnRef.className = 'footnote-ref';
    fnRef.setAttribute('data-bs-content', fn.getAttribute('data-note'));
    fnRef.setAttribute('data-bs-toggle', 'popover');
    fnRef.setAttribute('data-bs-trigger', 'focus');
    fnRef.setAttribute('data-bs-placement', "bottom");
    fnRef.setAttribute('title', '');
    fnRef.setAttribute('role', 'button');
    fnRef.setAttribute('tabIndex', '0');
    fnRef.innerText = '' + (i+1);
    fn.parentNode.insertBefore(fnRef, fn);
  }
}

function prepareEndnotesForTextField(fld){
  var endnotes = fld.querySelectorAll('span.endnote');
  var endnoteHtml = [];
  for (var i=0; i < endnotes.length; i++){
    var en = endnotes[i];
    var enRef = document.createElement('sup');
    enRef.className = 'endnote-ref';
    enRef.innerText = '['+(i+1)+']';
    endnoteHtml.push('<tr><td><sup>['+(i+1)+']</sup></td><td>' + en.getAttribute('data-note') + '</td></tr>');
    en.parentNode.insertBefore(enRef, en);
  }
  var endnoteDiv = document.createElement('table');
  endnoteDiv.className = 'endnotes'
  endnoteDiv.innerHTML = endnoteHtml.join('');
  fld.parentNode.append(endnoteDiv);
}
