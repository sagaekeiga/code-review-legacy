$(document).off('click', '.reply-submit-btn')
$(document).on('click', '.reply-submit-btn', function () {
  submitReply($(this));
})

$(document).on('click', '.read-btn', function () {
  updateRead($(this));
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

function updateRead(elem) {
  elem.prop('disabled', true);
  $.ajax({
    type: 'PUT',
    url: `/reviewers/replies/${elem.attr('reply-id')}`,
    dataType: 'JSON',
    element: elem,
    success: function (data) {
      elem.addClass('hidden')
      readLabel = elem.closest('.pull-right').prevAll('.label')
      readLabel.addClass('hidden')
      readMessage = $(`<div class='update-read'><i class='fas fa-check'></i>&nbsp;対応済みにしました</div>`)
      readMessage.appendTo(elem.closest('.pull-right'))
      readMessage.delay(3000).fadeOut('slow');
      panelStep = elem.closest('.panel.step')
      panelStep.removeClass('unread')
      img = elem.closest('.comment-line').prevAll('img')
      img.attr('src', '/assets/checked.png')
      unread = elem.closest('.comment-line').prevAll('span.unread')
      unread.removeClass('unread').addClass('read').text('対応済み')
    }
  });
};
