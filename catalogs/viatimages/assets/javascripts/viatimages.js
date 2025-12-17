$(document).ready(function() {
  $("a#titreDetailLabel").click(function() {
    if($(this).attr('class') === 'inactive') {
      $(this).attr('class', 'active');
      $('#titreDetailTradLabel').attr('class', 'inactive');
      $('#titreDetailTrad').css('display', 'none');
      $('#titreDetail').css('display', 'inline');
    }
  });

  $("a#titreDetailTradLabel").click(function() {
    if ($(this).attr('class') === 'inactive') {
      $(this).attr('class', 'active');
      $('#titreDetailLabel').attr('class', 'inactive');
      $('#titreDetail').css('display', 'none');
      $('#titreDetailTrad').css('display', 'inline');
    }
  });
  
  $("a#caracteristiquesLabel").click(function(e) {
    e.preventDefault()
    var d = $('#caracteristiques').css('display');
    if (d === 'none') {
      document.getElementById('arrowCaracteristiquesExpand').classList.add('hidden')
      document.getElementById('arrowCaracteristiquesCollapse').classList.remove('hidden')
    } else {
      document.getElementById('arrowCaracteristiquesExpand').classList.remove('hidden')
      document.getElementById('arrowCaracteristiquesCollapse').classList.add('hidden')
    }
    $('#caracteristiques').animate({height: 'toggle'});
  });

  $("a#remarquesLabel").click(function(e) {
    e.preventDefault()
    var d = $('#remarques').css('display');
    if (d === 'none') {
      document.getElementById('arrowRemarquesExpand').classList.add('hidden')
      document.getElementById('arrowRemarquesCollapse').classList.remove('hidden')
    } else {
      document.getElementById('arrowRemarquesExpand').classList.remove('hidden')
      document.getElementById('arrowRemarquesCollapse').classList.add('hidden')
    }
    $('#remarques').animate({height: 'toggle'});
  });

  $("a#texteImageLabel").click(function() {
    var d = $('#texteImage').css('display');
    if (d === 'none') {
        $('#arrowtexteImage').attr('src', '/assets/arrow-collapse.gif');
    } else {
        $('#arrowtexteImage').attr('src', '/assets/arrow-expand.gif');
    }
    $('#texteImage').animate({height: 'toggle'});
  });

  $("#sel_texte_associe").change(function() {
    var path = this.value;
    $('#inlinePdfFrame').attr('src', path);
    $('#pdfLink a').each(function() {
        $(this).attr('href', path);
    });
  });

  replaceLineBreakBy($("#caracteristiquesGenerales"), ', ');
  replaceLineBreakBy($("#ouvrageSource"), ', ');
  replaceLineBreakBy($("#etablissementImage"), ', ');
  replaceLineBreakBy($("#chercheur"), ', ');
  replaceLineBreakBy($("#enLigne"), ', ');
  replaceLineBreakBy($("#etablissementCorpus"), ' - ');
  replaceLineBreakBy($("#caracteristiquesEmplacement"), ' - ');
});

function replaceLineBreakBy(selector, replaceBy) {
  if (selector.html() == null) { return false; }
  if (selector.html().trim()) {
    var str = selector.html().trim().replace(/[\t\n]+/g, replaceBy);
    selector.html(str);
  }
}

// Create a new lightbox observer instance, this will watch for changes in the DOM
// and add the image legend to the lightbox when it is opened
new MutationObserver(function(mutations) {
  mutations.forEach(function(mutation) {
    // If the addedNodes property has one or more nodes
    if (mutation.addedNodes.length) {
      $(mutation.addedNodes).each(function() {
        var $this = $(this);
        // Check if the added element has the class 'ReactModalPortal'
        if ($this.hasClass('ReactModalPortal')) {
          // Add the image legend to the lightbox using safe DOM methods
          var contentParts = [];

          if ($('#imageLegendEtablissment').length) {
            contentParts.push('© ' + $('#imageLegendEtablissment').text() + '.');
          }

          if ($('#imageLegendDroits').length) {
            contentParts.push($('#imageLegendDroits').text());
          }

          if (contentParts.length > 0) {
            // Create DOM elements safely using jQuery methods
            var $caption = $('<div></div>')
              .addClass('ril-caption ril__caption');

            var $captionContent = $('<div></div>')
              .addClass('ril-caption-content ril__captionContent')
              .text(contentParts.join(' ')); // .text() safely escapes HTML entities

            $caption.append($captionContent);
            $(".ril-toolbar").after($caption);
          }
        }
      });
    }
  });
}).observe(document, {
  attributes: true,
  childList: true,
  characterData: true,
  subtree: true
});
