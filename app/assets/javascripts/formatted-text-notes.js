$(document).on('ready', function(){
  var ftFields = $('div.formatted-text');
  for (var i=0; i < ftFields.length; i++){
    prepareFootnotesForTextField(ftFields[i]);
  }
  $('sup.footnote-ref').popover();
});

function prepareFootnotesForTextField(fld){
  var footnotes = fld.querySelectorAll('span.footnote');
  for (var i=0; i < footnotes.length; i++){
    var fn = footnotes[i];
    var fnRef = document.createElement('sup');
    fnRef.className = 'footnote-ref'
    fnRef.setAttribute('data-content', fn.innerHTML);
    fnRef.setAttribute('data-toggle', 'popover');
    fnRef.setAttribute('data-trigger', 'focus');
    fnRef.setAttribute('title', '');
    fnRef.setAttribute('role', 'button');
    fnRef.setAttribute('tabIndex', '0');
    fnRef.innerText = '' + (i+1);
    fn.parentNode.insertBefore(fnRef, fn);
  }
}
