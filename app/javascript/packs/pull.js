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
  });
});