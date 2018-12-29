$(document).on('ajax:success', '#feedback-form', function(e) {
  $('#feedbackModal').modal('hide')
  $('#feedback-body').val('')
});