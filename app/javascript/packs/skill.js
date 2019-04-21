$(document).on('click', '#addButton', function () {
  addForm($(this));
})

$(document).on('input', '.autocomplete', function () {
  autoComplete($(this))
})
$(document).on('click', '.remove-icon', function () {
  removeForm($(this))
})
$(document).on('click', '.delete-icon', function () {
  deleteForm($(this))
})

function addForm(elem) {
  $('#addForm').append(
    `
      <tr class='add-form'>
        <td>
          <input type='text' class='form-control autocomplete' name='reviewer[tags][][name]' autocomplete='off' />
        </td>
        <td>
          <select class='form-control' name='reviewer[tags][][year]'>
            <option value='0'>1年未満</option>
            <option value='1'>1年</option>
            <option value='2'>2年</option>
            <option value='3'>3年</option>
            <option value='4'>4年</option>
            <option value='5'>5年</option>
            <option value='6'>6年</option>
            <option value='7'>7年</option>
            <option value='8'>8年</option>
            <option value='9'>9年</option>
            <option value='10'>10年以上</option>
          </select>
        </td>
        <td>
          <i class='fa fa-times remove-icon' aria-hidden='true'></i>
        </td>
      </tr>
    `
  )
}


function removeForm(elem) {
  elem.closest('tr').remove()
}

function deleteForm(elem) {
  $.ajax({
    type: 'DELETE',
    headers: {
      'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
    },
    url: `/reviewers/reviewer_tags/${elem.attr('data-reviewer-tag-id')}`,
    dataType: 'JSON',
    data: {
      reviewer_tag_id: elem.nextAll('.path').val()
    },
    element: elem,
    success: function(data) {
    }
  });
  elem.closest('tr').remove()
}

function autoComplete(elem) {
  elem.autocomplete({
    source: '/tags/autocomplete',
    minLength: 2,
    focus: function(event, ui) {
      elem.val(ui.item.name);
      return false;
    },
    select: function(event, ui) {
      elem.val(ui.item.name);
      return false;
    }
  }).data("ui-autocomplete")._renderItem = function(ul, item) {
    return $("<li>").attr("data-value", item.name).data("ui-autocomplete-item", item).append("<a>" + item.name + "</a>").appendTo(ul);
  };
}