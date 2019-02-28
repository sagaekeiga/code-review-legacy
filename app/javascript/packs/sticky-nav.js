$(function () {
  var $body = $('body')
      $navTypeA = $('.sticky-menu'),
      navTypeAOffsetTop = $navTypeA.offset().top;
  
  $(window).on('scroll', function () {
    if($(this).scrollTop() > navTypeAOffsetTop) {
      $navTypeA.addClass('is-fixed');
      $body.css('margin-top',  '50px')
    } else {
      $navTypeA.removeClass('is-fixed');
      $body.css('margin-top', '0');
    }
  });
});