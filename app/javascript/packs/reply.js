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
    url: `/reviewers/review_comments`,
    dataType: 'JSON',
    data: {
      root_id: elem.nextAll('.root_id').val(),
      path: elem.nextAll('.path').val(),
      position: elem.nextAll('.position').val(),
      changed_file_id: elem.nextAll('.changed_file_id').val(),
      body: elem.closest('.text-right').prevAll('textarea').val(),
      reviewer_id: elem.nextAll('.reviewer_id').val(),
      commit_id: elem.nextAll('.commit_id').val(),
      status: 'commented',
      remote_id: elem.nextAll('.remote_id').val(),
      reply: true
    },
    element: elem,
    success: function(data) {
      if (data.status === 'success') {
        replyWrapper = elem.closest('.reply-wrapper');
        $(`<div class="col-xs-1 comment-img"><img class="review-comment-img avatar img-responsive rounded-circle" src="${data.img}"></div>`).insertAfter(replyWrapper.prev('.comment-body'));
        $(`<div class="col-xs-11 comment-body">
            <div class="nickname">${data.name}</div>
            <small class="text-muted">${data.time}</small>
            <div class="col-xs-12">
              <p>
                ${data.body}
              </p>
            </div>
          </div>`).insertAfter(replyWrapper.prev('.comment-img'));
        replyWrapper.find('.reply-hidden-target-element').removeClass('hidden');
        replyWrapper.find('.reply-show-target-element').addClass('hidden')
        replyWrapper.find('.reply-show-target-element').find('textarea').val('');
        replyWrapper.find('.reply-show-target-element').find('.remote_id').val(data.remote_id);
      }
      elem.prop('disabled', false);
    }
  });
};
