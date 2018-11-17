$(document).on('click', '.input-reply', function () {
  switchTextarea($(this));
})

$(document).on('click', '.reply-cancel-btn', function () {
  cancelReply($(this));
})

$(document).on('click', '.reply-submit-btn', function () {
  submitReply($(this));
})

$(document).on('click', '.thread-button', function () {
  var menu = $(this)
  var repliesWrapper = $(this).closest('.panel-footer').nextAll('.replies-wrapper')
  var menuIcon = $(this).find('i')
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

function switchTextarea(elem) {
  replyWrapper = elem.closest('.reply-wrapper');
  replyWrapper.find('.reply-hidden-target-element').addClass('hidden');
  replyWrapper.find('.reply-show-target-element').removeClass('hidden');
};

function cancelReply(elem) {
  replyWrapper = elem.closest('.reply-wrapper');
  replyWrapper.find('.reply-hidden-target-element').removeClass('hidden');
  replyWrapper.find('.reply-show-target-element').addClass('hidden').val('');
};

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
      body: elem.closest('.submit').prevAll('.input').find('input').val(),
      commit_id: elem.nextAll('.commit_id').val()
    },
    element: elem,
    success: function (data) {
      if (data.status === 'success') {
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
              <div class='body md-wrapper'>${data.body}</div>
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
        replyInput = elem.closest('.submit').prevAll('.input').find('input')
        replyInput.val('')
      }
      elem.prop('disabled', false);
    }
  });
};
