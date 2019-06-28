import 'bootstrap'
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
      $('#reviewSubmitModal').modal('show')
    }
  })
})

$('#repositoryDropdown').on("click", function () {
  $('.repo-dropdown').toggle();
});

$('#settingsDropdown').on("click", function () {
  $('.settings-dropdown').toggle();
});


$(function () {
  $('select').change(function () {
    $.ajax({
      type: 'PUT',
      url: `/pull_tags/${$(this).attr('pull-tag-id')}`,
      dataType: 'JSON',
      data: {
        pull_id: $(this).attr('pull-id'),
        tag_id: $(this).val()
      },
      element: $(this),
      success: function (data) {
        $(this.element).attr('disabled', false)
      }
    })
  })
})

$(function () {
  $('label').on('click', function () {
    var checkbox = $(this).prevAll('.custom-control-input')
    if (checkbox.prop('checked')) {
      checkbox.prop('checked', true)
    } else {
      checkbox.prop('checked', false)
    }
  })
})