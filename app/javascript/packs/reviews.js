hoverColor();

hoverCode();

hoverComment();

$('.hljs-addition').click(function() {
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
  $('.hljs-addition').each(function(i, elem) {
    $(elem).css('cursor','pointer');
    var color = $(elem).css("color");
    $(elem).hover(
      function(){
        $(this).css({ 'color':'#FFFFFF', 'text-decoration':'none' });
      },
      function(){
        $(this).css({ 'color': color, 'text-decoration':'none' });
      }
    )
  })
};

function hoverCode() {
 $('.code-tr').hover(
   function(){
     self_review_num = $(this).attr('data-line-number');
     comment_position = `div[comment-position=${self_review_num}]`

     if ($(this).children($('td')).hasClass('bg-success')){
        bg_class = 'bg-success'
     } else {
        bg_class = 'bg-danger'
     };

     $(this).children($('td')).addClass('bg-warning').removeClass(bg_class);
     $(comment_position).children('div').addClass('bg-warning')
   },
   function(){
     $(this).children($('td')).addClass(bg_class).removeClass('bg-warning');
     $(comment_position).children('div').removeClass('bg-warning')
   }
  );
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
    var textarea = $('<textarea>').attr({
        name: 'reviews[body][]',
        class: 'form-control md-textarea body',
        rows: '5'
    });
    textarea.val('* 指摘事項\n\n* 理由\n\n* 参考（リンク・サンプルコード）')
    var positionHiddenField = $('<input>').attr({
        type: 'hidden',
        name: 'reviews[position][]',
        value: position,
        class: 'position'
    });
    var pathHiddenField = $('<input>').attr({
        type: 'hidden',
        name: 'reviews[path][]',
        value: path,
        class: 'path'
    });
    var changedFileIdHiddenField = $('<input>').attr({
        type: 'hidden',
        name: 'reviews[changed_file_ids][]',
        value: changed_file_id,
        class: 'changed_file_id'
    });
    // input追加
    $('<div class="panel panel-default new-review-comments"><div class="panel-body"></div></div>').insertAfter($(elem).closest('.code-tr'));
    $(elem).closest('.code-tr').nextAll('.panel').find('.panel-body').prepend(textarea);
    $('<div class="flex-row text-right"></div>').insertAfter($(elem).closest('.code-tr').nextAll('.panel').find('textarea'));
    $(elem).closest('.code-tr').nextAll('.panel').find('.flex-row').prepend('<button class="btn btn-primary review-trigger" type="button">Add Review Comment</button>');
    $(elem).closest('.code-tr').nextAll('.panel').find('.flex-row').prepend('<button class="btn btn-default cancel-trigger" type="button">Cancel</button>');
    positionHiddenField.insertAfter($(elem).closest('.code-tr').nextAll('.panel').find('.review-trigger'));
    pathHiddenField.insertAfter($(elem).closest('.code-tr').nextAll('.panel').find('.review-trigger'));
    changedFileIdHiddenField.insertAfter($(elem).closest('.code-tr').nextAll('.panel').find('.review-trigger'));
    $(elem).addClass('add-form');
  }
};

function removeForm(elem) {
  elem.closest('.panel').prevAll('tr').find('.add-form').removeClass('add-form');
  elem.closest('.panel').remove();
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
        var panel = elem.closest('.panel');
        panel.empty();
        panel.prepend(`<div class="panel-heading"><span class="label label-warning">Pending</div>
          <div class="panel-body"><p class="panel-text" review-comment-id=${data.review_comment_id} /></div>`);
        var panelText = panel.find('.panel-text')
        panelText.wrapInner(marked(data.body));
        $('<div class="flex-row text-right"></div>').insertAfter(panelText);
        panelText.nextAll('.flex-row').prepend('<button class="btn btn-primary edit-trigger" type="button"><span class="glyphicon glyphicon-pencil"></span></button>');
        panelText.nextAll('.flex-row').prepend('<button class="btn btn-danger destroy-trigger" type="button" data-confirm="本当にキャンセルしてよろしいですか？"><span class="glyphicon glyphicon-trash"></span></button>');
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
          elem.closest('.panel').remove();
          elem.prop('disabled', false);
        }
      }
    });
	}
};

function editReviewCommentForm(elem) {
  elem.prop('disabled', true);
  var reviewCommentId = elem.closest('.flex-row').prevAll('.panel-text').attr('review-comment-id')
  var textarea = $('<textarea>').attr({
    name: 'reviews[body][]',
    class: 'form-control md-textarea',
    'review-comment-id': reviewCommentId
  });
  $('<span class="label label-primary">編集中</span>').insertAfter(elem.closest('.panel').find('.panel-heading').find('span'));
  elem.prevAll('.destroy-trigger').remove();
  elem.closest('.flex-row').prepend('<button class="btn btn-default cancel-update-trigger" type="button">Cancel</button>');
  elem.removeClass('edit-trigger').addClass('update-trigger').text('Update');
  elem.closest('.flex-row').prevAll('.markdown-review-comment').remove();
  elem.closest('.flex-row').prevAll('.panel-text').remove();
  elem.prop('disabled', false);
  $.ajax({
    type: 'GET',
    headers: {
      'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
    },
    url: `/reviewers/review_comments/${reviewCommentId}`,
    dataType: 'JSON',
    element: elem,
    success: function(data) {
      elem.closest('.panel-body').prepend(textarea.text(data.body));
    }
  });
};

function cancelUpdateReviewComment(elem) {
  $.ajax({
    type: 'GET',
    url: `/reviewers/review_comments/${elem.closest('.flex-row').prevAll('textarea').attr('review-comment-id')}`,
    dataType: 'JSON',
    element: elem,
    success: function(data) {
      elem.removeClass('cancel-update-trigger btn-default').addClass('destroy-trigger btn-danger');
      elem.text('');
      $(elem).wrapInner('<span class="glyphicon glyphicon-trash"></span>');
      elem.nextAll('.update-trigger').removeClass('update-trigger').addClass('edit-trigger');
      elem.closest('.panel-body').prepend(`<p class="panel-text" review-comment-id=${elem.closest('.flex-row').prevAll('textarea').attr('review-comment-id')}></p>`);
      elem.closest('.panel-body').find('.panel-text').wrapInner(marked(data.body));
      elem.closest('.flex-row').prevAll('textarea').remove();
      elem.closest('.panel').find('span.label-primary').remove();
    }
  });
};

function updateReviewComment(elem) {
  elem.prop('disabled', true);
  $.ajax({
    type: 'PUT',
    url: `/reviewers/review_comments/${elem.closest('.panel-body').find('textarea').attr('review-comment-id')}`,
    headers: { 'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content') },
    dataType: 'JSON',
    data: { body: elem.closest('.panel-body').find('textarea').val() },
    element: elem,
    success: function(data) {
      if (data.status === 'success') {
        $(elem).text('').wrapInner('<span class="glyphicon glyphicon-pencil"></span>');
        elem.prevAll('.cancel-update-trigger').removeClass('cancel-update-trigger btn-default').addClass('destroy-trigger btn-danger').text('');
        $(elem).prevAll('button').wrapInner('<span class="glyphicon glyphicon-trash"></span>');
        elem.removeClass('update-trigger').addClass('edit-trigger');
        elem.closest('.panel-body').prepend(`<p class="panel-text" review-comment-id=${elem.closest('.flex-row').prevAll('textarea').attr('review-comment-id')}></p>`);
        elem.closest('.panel-body').find('p.panel-text').wrapInner(marked(data.body));
        elem.closest('.panel-body').find('textarea').remove();
        elem.closest('.panel').find('span.label-primary').remove();
        elem.prop('disabled', false);
      }
    }
  });
};
