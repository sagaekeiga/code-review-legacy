import 'bootstrap'
$('.update-pull-button').on('click', function (e) {
  $(this).attr('disabled', true)
  var pullId = $(this).attr('pull-id')
  $.ajax({
    type: 'PUT',
    url: `/pulls/${pullId}`,
    dataType: 'JSON',
    data: {
      status: true
    },
    element: $(this),
    success: function (data) {
      $(this.element).attr('disabled', false)
      if (data.status !== 'request_reviewed' || data.review_requests_count > 0) { return }
      if ($('[class=custom-control-label]:checked').length > 5) {
        $('.complete').attr('disabled', true)
        $(`.counter${pullId}`).text('これ以上選択できません')
      } else {
        $('.complete').attr('disabled', false)
        $(`.counter${pullId}`).text(`あと ${5 - $('[class=custom-control-label]:checked').length} 人までリクエストすることができます`)
      }
      $(`.reviewers${pullId}`).empty()
      $.each(data.reviewers, function (index, reviewer) {
        $(`
          <tr class='reviewer'>
            <td class='avatar'>
              <img width='20' class='rounded-circle' src='${reviewer.avatar_url}'>
            </td>
            <td class='nickname'>
              <a target='_blank' href='https://github.com/${reviewer.nickname}'>
                ${reviewer.name}
              </a>
            </td>
            <td class='bio'>
              biobiobiobiobiobiobiobiobiobiobio
            </td>
            <td>
              <form>
                <div class='custom-control custom-switch'>
                  <input class='custom-control-input' id='switch${reviewer.id}' type='checkbox' value='${reviewer.id}' pull-id=${pullId}>
                  <label class='custom-control-label' for='switch${reviewer.id}'></label>
                </div>
              </form>
            </td>
          </tr>
        `).appendTo(`.reviewers${pullId}`)
      })
      $(`#reviewSubmitModal${pullId}`).modal('show')
    }
  })
})

$('#repositoryDropdown').on('click', function () {
  $('.repo-dropdown').toggle();
});

$('#settingsDropdown').on('click', function () {
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

$(document).on('click', '.custom-control-input', function () {
  var pullId = $(this).attr('pull-id')
  var checks = $('[class=custom-control-input]:checked').length
  if (checks > 4) {
    $(`.counter${pullId}`).text('これ以上選択できません')
  } else {
    $(`.counter${pullId}`).text(`あと ${5 - checks} 人までリクエストすることができます`)
  }
  if (checks > 5) {
    $('.complete').attr('disabled', true)
  } else {
    $('.complete').attr('disabled', false)
  }
})

$('.modal').on('hide.bs.modal', function (e) {
  var pullId = $(this).closest('tbody').attr('pull-id')
  $(`.reviewers${pullId}`).empty()
})

$(function () {
  $('.complete').on('click', function () {
    $(this).attr('disabled', true)
    var reviewer_ids = $('[type=checkbox]:checked').map(function () {
      return $(this).val() == 'on' ? '' : $(this).val()
    }).get()

    reviewer_ids = $.grep(reviewer_ids, function (e) { return e; })

    $.ajax({
      type: 'POST',
      url: `/review_requests`,
      dataType: 'JSON',
      data: {
        authenticity_token: $('meta[name="csrf-token"]').attr('content'),
        reviewer_ids: reviewer_ids,
        pull_id: $(this).closest('tbody').attr('pull-id')
      },
      element: $(this),
      success: function (data) {
        if (data.status) {
          $(this.element).closest('.modal').modal('hide')
        } else {
          $(this.element).closest('.modal').attr('disabled', false)
          $(this.element).closest('.modal').modal('hide')
        }
      }
    })
  })
})