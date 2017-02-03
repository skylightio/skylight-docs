$( document ).ready( function( ) {
  var $supportMenuDetailList = $('#support-menu-detail');

  // For each header, generate something that looks like this:
  // <li class="support-menu-detail-h#">
  //   <a href="#anchor">Header Text</a>
  // </li>
  $('.support-content').find('h2, h3').each(function(index, header) {
    $supportMenuDetailList.append(
      `<li class="support-menu-detail-${header.localName}">` +
        `<a href="#${header.id}" class="js-scroll-link support-menu-link">` +
          header.innerText.toLowerCase() +
        '</a>' +
      '</li>'
    );
  });

  $supportMenuDetailList.show();
});
