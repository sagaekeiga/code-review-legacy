const hidden = 'd-none'

$(function () {
  $('.empty').on('click', function (e) {
    e.preventDefault()
    $(this).addClass(hidden)
    $(this).nextAll(`.${hidden}`).removeClass(hidden)
    $(this).prevAll('.saved').addClass(hidden)
  })
})

$(function () {
  $('.update').on('click', function (e) {
    $(this).attr('disabled', true)
    $.ajax({
      type: 'PUT',
      url: `/repos/${$('.main').attr('repo-id')}`,
      dataType: 'JSON',
      data: {
        authenticity_token: $('meta[name="csrf-token"]').attr('content'),
        description: $('.description').val(),
        homepage: $('.homepage').val()
      },
      element: $(this),
      success: function (data) {
        const elem = $(this.element)
        const form = elem.closest('.form')
        const saved = form.prevAll('.saved')
        const message = form.prevAll('.message')
        const targetForm = elem.closest('.buttons').prevAll('.target-form')
        if (data.success) {
          const targetData = targetForm.hasClass('homepage') ? data.repo.homepage : data.repo.description
          form.addClass(hidden)
          saved.text(targetData).removeClass(hidden)
          form.prevAll('.empty').removeClass(hidden)
          targetForm.val(targetData)
        } else {
          message.text('更新に失敗しました').fadeOut(5000)
        }
        $(this.element).attr('disabled', false)
      }
    })
  })
})

$(function () {
  $('.cancel').on('click', function (e) {
    cancel(e, $(this))
  })
})

$(function () {
  $('#preview').on('click', function (e) {
    $('#fileField').click()
  })
})

$(function () {
  $('#fileField').on('change', function (e) {
    const file = this.files[0]
    let formdata = new FormData()
    formdata.append('image', file)
    formdata.append('authenticity_token', $('meta[name="csrf-token"]').attr('content'))
    $.ajax({
      type: 'PUT',
      url: `/repos/${ $('.main').attr('repo-id') }`,
      data: formdata,
      processData: false,
      contentType: false,
      element: this,
    }).done(function (response) {
      reader = new FileReader(),
        $preview = $('#preview')

      reader.onload = (function (file) {
        return function (e) {
          $preview.empty();
          $preview.attr({
            src: e.target.result,
            title: file.name
          })
        };
      })(file);
      reader.readAsDataURL(file)
    }).fail(function () {
      window.alert('ファイルは5MB以下のサイズにしてください')
    });
    return false;
  })
})

function cancel(e, elem) {
  e.preventDefault()
  const form = elem.closest('.form')
  form.prevAll('.saved').removeClass(hidden)
  form.prevAll('.empty').removeClass(hidden)
  form.addClass(hidden)
}