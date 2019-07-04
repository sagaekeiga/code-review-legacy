import 'jquery-ui-dist/jquery-ui'
import { tag } from 'postcss-selector-parser';

$(document).on('input', '#tagInput', function () {
  if ($(this).val() == '') {
    $('#addTag').attr('disabled', true)
  } else {
    $('#addTag').attr('disabled', false)
  }
  $('#tagInput').autocomplete({
    source: '/tags',
    delay: 100,
    minLength: 1,
    focus: function (event, ui) {
      $('#tagInput').val(ui.item.name)
      return false
    },
    select: function (event, ui) {
      $('#tagInput').val(ui.item.name)
      return false
    }
  }).data('ui-autocomplete')._renderItem = function (ul, item) {
    return $('<li>').attr('data-value', item.name).data('ui-autocomplete-item', item.name).append(`<a>` + item.name + '</a>').appendTo(ul)
  }
})

$(document).on('click', '#addTag', function () {
  $.ajax({
    type: 'POST',
    url: `/user_tags`,
    dataType: 'JSON',
    data: {
      authenticity_token: $('meta[name="csrf-token"]').attr('content'),
      name: $('#tagInput').val()
    },
    element: $(this),
    success: function (data) {
      if(data.success) {
        $(`
          <li>
            <a href="#">
              <span>${data.tag.name}</span>
            </a>
          </li>
        `).appendTo('ul#myTag')
        $('#tagInput').val('')
      } else {
        $('#tagErrorMessage').text('タグを登録できませんでした')
      }
    }
  })
})

$(document).on('click', '.edit', function () {
  if ($(this).hasClass('fa-times')) {
    $('#edit').addClass('d-none')
    $(this).removeClass('fas fa-times').addClass('far fa-edit')
  } else {
    $('#edit').removeClass('d-none')
    $(this).addClass('fas fa-times').removeClass('far fa-edit')
  }
})