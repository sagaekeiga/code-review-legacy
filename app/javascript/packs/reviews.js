hoverColor();

hoverComment();

$('.markdown-highlight').click(function() {
  addForm($(this));
})

$(document).on('click', '.cancel-trigger', function () {
  removeForm($(this));
})

$(document).on('click', '.review-trigger', function () {
  createReviewComment($(this));
})

$(document).on('click', '.destroy-trigger', function () {
  destroyReviewComment($(this));
})

$(document).on('click', '.edit-trigger', function () {
  editReviewCommentForm($(this));
})

$(document).on('click', '.update-trigger', function () {
  updateReviewComment($(this));
})

$(document).on('click', '.cancel-update-trigger', function () {
  cancelUpdateReviewComment($(this));
})

$(document).on('click', '#submit_review_button', function () {
  $(this).hide();
  $('.loading').removeClass('hidden');
})

$(document).on('click', '.close-left-side', function () {
  $('.col-sm-4.p-l-0').addClass('hidden')
  $('.col-sm-3.p-r-0').removeClass('hidden')
  $('#code_note').removeClass('col-sm-8').addClass('col-sm-9');
  $('.open-left-side').removeClass('hidden')
})

$(document).on('click', '.open-left-side', function () {
  $('.col-sm-4.p-l-0').removeClass('hidden')
  $('.col-sm-3.p-r-0').addClass('hidden')
  $('#code_note').removeClass('col-sm-12').addClass('col-sm-8');
  $('.open-left-side').addClass('hidden')
})

function hoverColor() {
  $('.file-code').each(function(i, elem) {
    $(elem).css('cursor','pointer');
    var color = $(elem).css("background-color");
    $(elem).hover(
      function(){
        $(this).css({ 'background-color':'#f0f0f0', 'text-decoration':'none' });
      },
      function(){
        $(this).css({ 'background-color': color, 'text-decoration':'none' });
      }
    )
  })
};

function hoverComment() {
 $('.comment-card').hover(
   function(){
     self_review_position = $(this).attr('comment-position');
     code_position = `tr[data-line-number=${self_review_position}]`

     if ($(`tr[data-line-number=${self_review_position}]`).children($('td')).hasClass('bg-success')){
        bg_class = 'bg-success'
     }else{
        bg_class = 'bg-danger'
     };

     $(code_position).children('td').removeClass(bg_class).addClass('bg-warning');
     $(this).children('div').addClass('bg-warning');
   },
   function(){
     $(this).children('div').removeClass('bg-warning');
     $(code_position).children('td').removeClass('bg-warning').addClass(bg_class);
   }
 );
};

function addForm(elem) {
  if (!$(elem).hasClass('add-form')) {
    var position = $(elem).closest('.code-tr').attr('data-line-number');
    var path = $(elem).closest('.changed-file-list-wrapper').find('.changed-file-name').text();
    var changed_file_id = $(elem).closest('.file-border').attr('changed-file-id');
    positionHiddenField = $('<input>').attr({
        type: 'hidden',
        name: 'reviews[position][]',
        value: position,
        class: 'position'
    });
    pathHiddenField = $('<input>').attr({
        type: 'hidden',
        name: 'reviews[path][]',
        value: path,
        class: 'path'
    });
    changedFileIdHiddenField = $('<input>').attr({
        type: 'hidden',
        name: 'reviews[changed_file_ids][]',
        value: changed_file_id,
        class: 'changed_file_id'
    });
    // input追加
    addingButtons = $(`
      <div class='flex-row text-right'>
        <button class='btn btn-default cancel-trigger' type='button'>キャンセル</button>
        <button class='btn btn-primary review-trigger' type='button'>コメントする</button>
        ${positionHiddenField.prop('outerHTML')}
        ${pathHiddenField.prop('outerHTML')}
        ${changedFileIdHiddenField.prop('outerHTML')}
      </div>
    `)

    addingPanelBody = $(`
      <tr>
        <td colspan='3' style='padding: 10px; border: 1px solid #ccc;'>
          <div class='panel panel-default new-review-comments' style='max-width: 780px;'>
            <div class='panel-body'>
              <textarea
                name='reviews[body][]'
                class='form-control md-textarea body'
                rows='5'
              >* 提案\n\n* 理由\n\n* 参考（リンク・サンプルコード）</textarea>
              ${addingButtons.prop('outerHTML')}
            </div>
          </div>
        </td>
      </tr>
    `)

    addingPanelBody.insertAfter($(elem).closest('.code-tr'));
    $(elem).addClass('add-form');
  }
};

function removeForm(elem) {
  elem.closest('.panel').prevAll('tr').find('.add-form').removeClass('add-form');
  elem.closest('tr').remove();
};

function createReviewComment(elem) {
  elem.prop('disabled', true);
  $.ajax({
    type: 'POST',
    headers: {
      'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
    },
    url: `/reviewers/review_comments`,
    dataType: 'JSON',
    data: {
      path: elem.nextAll('.path').val(),
      position: elem.nextAll('.position').val(),
      changed_file_id: elem.nextAll('.changed_file_id').val(),
      body: elem.closest('.flex-row').prevAll('textarea').val(),
      reviewer_id: $('.data_id').attr('reviewer-id')
    },
    element: elem,
    success: function(data) {
      marked.setOptions({ breaks : true });
      if (data.status === 'success') {
        panel = elem.closest('.panel');
        panel.empty();
        panel.wrap(`<div class='review-comments-wrapper' />`);
        panel.prepend(`
          <div class='panel-heading'>
            <span class='label label-warning'>下書き</span>
          </div>
          <div class='panel-body'>
            <p class="panel-text" review-comment-id=${data.review_comment_id} />
            <div class='flex-row text-right'></div>
          </div>
        `);
        panelText = panel.find('.panel-text')
        buttonSpace = panelText.nextAll('.flex-row')
        panelText.wrapInner(marked(data.body));
        $(buttonSpace).insertAfter(panelText);
        editButton = $(`
          <button class='btn btn-primary edit-trigger circle' type='button'>
            <span class='glyphicon glyphicon-pencil'></span>
          </button>
        `)
        buttonSpace.prepend(editButton);
        cancelButton = $(`
          <button
            class='btn btn-danger destroy-trigger circle'
            type='button'
            data-confirm='本当にキャンセルしてよろしいですか？'
          >
            <span class='glyphicon glyphicon-trash'></span>
          </button>
        `)
        buttonSpace.prepend(cancelButton.prop('outerHTML'));
      }
      elem.prop('disabled', false);
    }
  });
};

function destroyReviewComment(elem) {
  // 「OK」時の処理開始 ＋ 確認ダイアログの表示
	if(window.confirm('本当に削除してよろしいですか？')){
    elem.prop('disabled', true);
    $.ajax({
      type: 'DELETE',
      headers: {
        'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
      },
      url: `/reviewers/review_comments/${elem.closest('.panel-body').find('.panel-text').attr('review-comment-id')}`,
      dataType: 'JSON',
      element: elem,
      success: function(data) {
        if (data.status === 'success') {
          elem.closest('.panel').prevAll('tr').find('.add-form').removeClass('add-form');
          elem.closest('tr').remove();
          elem.prop('disabled', false);
        }
      }
    });
	}
};

function editReviewCommentForm(elem) {
  reviewCommentId = elem.closest('.flex-row').prevAll('.panel-text').attr('review-comment-id')
  elem.prop('disabled', true);
  $.ajax({
    type: 'GET',
    headers: {
      'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
    },
    url: `/reviewers/review_comments/${reviewCommentId}`,
    dataType: 'JSON',
    element: elem,
    success: function (data) {
      textarea = $('<textarea>').attr({
        name: 'reviews[body][]',
        class: 'form-control md-textarea',
        'review-comment-id': reviewCommentId
      });
      destroyButton = elem.prevAll('.destroy-trigger')
      destroyButton.remove();
      buttonSpace = elem.closest('.flex-row')
      cancelButton = $(`<button class='btn btn-default cancel-update-trigger' type='button'>キャンセル</button>`)
      buttonSpace.prepend(cancelButton);
      elem.removeClass('edit-trigger').removeClass('circle').addClass('update-trigger').text('更新');
      elem.closest('.flex-row').prevAll('.markdown-review-comment').remove();
      elem.closest('.flex-row').prevAll('.panel-text').remove();
      elem.prop('disabled', false);
      elem.closest('.panel-body').prepend(textarea.text(data.body));
    }
  });
};

function cancelUpdateReviewComment(elem) {
  buttonSpace = elem.closest('.flex-row')
  reviewCommentId = buttonSpace.prevAll('textarea').attr('review-comment-id')
  $.ajax({
    type: 'GET',
    url: `/reviewers/review_comments/${reviewCommentId}`,
    dataType: 'JSON',
    element: elem,
    success: function (data) {
      panelBody = elem.closest('.panel-body')
      updatingBody = $(`
        <p
          class='panel-text'
          review-comment-id=${reviewCommentId}
        >
        </p>
      `)
      elem.removeClass('cancel-update-trigger btn-default').addClass('destroy-trigger btn-danger circle');
      elem.text('');
      trashIcon = $(`<span class='glyphicon glyphicon-trash'></span>`)
      $(elem).wrapInner(trashIcon);
      pencilIcon = $(`<span class='glyphicon glyphicon-pencil'></span>`)
      editButton = elem.nextAll('.update-trigger')
      editButton.removeClass('update-trigger').addClass('edit-trigger circle').text('').wrapInner(pencilIcon);
      panelBody.prepend(updatingBody);
      panelBody.find('.panel-text').wrapInner(marked(data.body));
      buttonSpace.prevAll('textarea').remove();
      elem.closest('.panel').find('span.label-primary').remove();
    }
  });
};

function updateReviewComment(elem) {
  elem.prop('disabled', true);
  reviewCommentId = elem.closest('.panel-body').find('textarea').attr('review-comment-id')
  updatingBody = elem.closest('.panel-body').find('textarea').val()
  $.ajax({
    type: 'PUT',
    url: `/reviewers/review_comments/${reviewCommentId}`,
    headers: { 'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content') },
    dataType: 'JSON',
    data: { body: updatingBody },
    element: elem,
    success: function(data) {
      if (data.status === 'success') {
        pencilIcon = $(`<span class='glyphicon glyphicon-pencil'></span>`)
        $(elem).text('').wrapInner(pencilIcon);
        cancelButton = elem.prevAll('.cancel-update-trigger')
        cancelButton.removeClass('cancel-update-trigger btn-default').addClass('destroy-trigger btn-danger circle').text('');
        trashIcon = $(`<span class='glyphicon glyphicon-trash'></span>`)
        cancelButton.wrapInner(trashIcon);
        elem.removeClass('update-trigger').addClass('edit-trigger circle').text('').wrapInner(pencilIcon);
        panelBody = elem.closest('.panel-body')
        panelBody.prepend(`<p class='panel-text' review-comment-id=${reviewCommentId}></p>`);
        panelBody.find('p.panel-text').wrapInner(marked(data.body));
        panelBody.find('textarea').remove();
        elem.closest('.panel').find('span.label-primary').remove();
        elem.prop('disabled', false);
      }
    }
  });
};
