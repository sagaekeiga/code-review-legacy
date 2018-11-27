$(document).on('click', '.tab', function (e) {
  if (!$(this).hasClass('repo')) {
    e.preventDefault()
  }
  $('li').each(function (index, element) {
    if ($(element).hasClass('active')) {
      $(element).removeClass('active')
    }
  })
  $('.tab').each(function (index, element) {
    if ($(element).hasClass('active')) {
      $(element).removeClass('active')
    }
  })
  $(this).addClass('active')
  $(this).closest('li').addClass('active')
  var href = $(this).attr('href')
  $('.tab-content').each(function (index, element) {
    if (!$(element).hasClass('hidden')) {
      $(element).addClass('hidden')
    }
  })
  $(href).removeClass('hidden')
})