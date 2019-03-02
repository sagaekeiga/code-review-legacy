$(document).off('click', '.reply-submit-btn')
$(document).on('click', '.reply-submit-btn', function () {
  submitReply($(this));
})

$(document).off('click', '.update-comment-btn')
$(document).on('click', '.update-comment-btn', function () {
  updateComment($(this));
})

$(document).on('click', '.comment-edit', function (e) {
  e.preventDefault()
  addUpdateForm($(this));
})

$(document).on('click', '.thread-button', function () {
  menu = $(this)
  repliesWrapper = $(this).closest('.panel-footer').nextAll('.replies-wrapper')
  menuIcon = $(this).find('i')
  if (repliesWrapper.hasClass('hidden')) {
    menu.addClass('active')
    menuIcon.addClass('active')
    repliesWrapper.removeClass('hidden')
  } else {
    menu.removeClass('active')
    menuIcon.removeClass('active')
    repliesWrapper.addClass('hidden')
  }
})

function submitReply(elem) {
  elem.prop('disabled', true);
  $.ajax({
    type: 'POST',
    url: `/reviewers/pulls/${elem.nextAll('.pull_token').val()}/reviews/${elem.nextAll('.review_id').val()}/replies`,
    dataType: 'JSON',
    data: {
      review_comment_id: elem.nextAll('.review_comment_id').val(),
      path: elem.nextAll('.path').val(),
      position: elem.nextAll('.position').val(),
      changed_file_id: elem.nextAll('.changed_file_id').val(),
      body: elem.closest('.submit').prevAll('.input').find('textarea').val(),
      commit_id: elem.nextAll('.commit_id').val()
    },
    element: elem,
    success: function (data) {
      lastReply = elem.closest('.panel-footer').prevAll('.panel-body').find('.panel-text').filter(':last').find('.replies-line')
      lastReply.removeClass('last')
      replyWrapper = elem.closest('.panel-footer').prevAll('.panel-body');
      reply = $(`
        <div class='panel-text'>
          <div class='image'>
            <img class='img-responsive img-circle' src="${data.avatar}">
          </div>
          <div class='nickname'>
            ${data.nickname}
          </div>
          <div class='date'>
            <div class='text-muted'>${data.time}</div>
          </div>
          <div class='replies-line last'>
            <div class='body md-wrapper'>${marked(data.body)}</div>
          </div>
        </div>
      `)
      if (replyWrapper.hasClass('hidden')) {
        reply.appendTo(replyWrapper);
        replyWrapper.removeClass('hidden')
      } else {
        lastPanelText = replyWrapper.find('.panel-text').filter(':last')
        reply.insertAfter(lastPanelText)
      }
      replyInput = elem.closest('.submit').prevAll('.input').find('textarea')
      replyInput.val('')
      elem.prop('disabled', false);
    }
  });
};

function updateComment(elem) {
  elem.prop('disabled', true);
  commentId = elem.attr('comment-id')
  body = elem.attr('body')
  $.ajax({
    type: 'PUT',
    url: `/reviewers/github/review_comments/${commentId}`,
    dataType: 'JSON',
    element: elem,
    data: {
      reviewe_comment_id: commentId,
      body: body
    },
    success: function (data) {
    }
  });
};

function addUpdateForm(elem) {
  commentId = elem.attr('comment-id')
  body_class = elem.closest('.panel-text').find('.body')
  body = body_class.find('.md-wrapper').find('p').text()
  console.log(body)
  textarea = $(`
    <div class='text-right'>
      <textarea class='form-control'>${body}</textarea>
      <button class='btn btn-primary update-comment-btn' 'data-comment-id'=${commentId}>更新する</button>
      <input name='comment_id' type='hidden' value=${commentId} class='comment-id'></input>
    </div>
  `)
  body_class.empty()
  body_class.wrapInner(textarea)
};

function updateComment(elem) {
  elem.prop('disabled', true);
  commentId = elem.nextAll('.comment-id').val()
  body = elem.prevAll('textarea').val()
  $.ajax({
    type: 'PUT',
    url: `/reviewers/github/review_comments/${commentId}`,
    dataType: 'JSON',
    element: elem,
    data: {
      review_comment_id: commentId,
      body: body
    },
    success: function (data) {
      body = elem.closest('.panel-text').find('.body')
      if (data.success) {
        body.empty()
        marked.setOptions({ breaks : true });
        body.wrapInner(`<div class='md-wrapper'>${marked(data.body)}</div>`);
      } else {
        body.prepend('コメントに失敗しました。');
      }
    }
  });
};