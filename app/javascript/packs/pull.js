$('.update-pull-button').on('click', function (e) {
  $(this).attr('disabled', true)
  $.ajax({
    type: 'PUT',
    url: `/pulls/${$(this).attr('pull-id')}`,
    dataType: 'JSON',
    data: {
      status: true
    },
    element: $(this),
    success: function (data) {
      $(this.element).attr('disabled', false)
    }
  })
})

$(function () {
  $('select').change(function () {
    $.ajax({
      type: 'PUT',
      url: `/pull_tags/${$(this).attr('pull-tag-id')}`,
      dataType: 'JSON',
      data: {
        tag_id: $(this).val(),
      },
      element: $(this),
      success: function (data) {
        $(this.element).attr('disabled', false)
      }
    })
  })
})