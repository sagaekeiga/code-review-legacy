$(function () {
  var $body = $('body')
      $stickyMenu = $('.sticky-menu'),
      stickyMenuOffsetTop = $stickyMenu.offset().top
      $title = $('#title');

  $(window).on('scroll', function () {
    if($(this).scrollTop() > stickyMenuOffsetTop) {
      if ($stickyMenu.hasClass('is-fixed')) { return; }
      $stickyMenu.addClass('is-fixed');
      $body.css('margin-top', '40px')
      $title.removeClass('hidden');
    } else {
      if (!$stickyMenu.hasClass('is-fixed')) { return; }
      $stickyMenu.removeClass('is-fixed')
      $body.css('margin-top', '0')
      $title.addClass('hidden');
    }
  });
});