$('.update-pull-button').on('click', function(e) {
  $(this).attr('disabled', true)
  $.ajax({
    type: 'PUT',
    url: `/reviewees/pulls/${$(this).attr('pull-id')}`,
    dataType: 'JSON',
    data: {
      status: true
    },
    element: $(this),
    success: function(data) {
      $(this.element).attr('disabled', false)
    }
  });
});

$('.update-repo-analysis-button').on('click', function(e) {
  $(this).attr('disabled', true)
  destroy = $(this).attr('repo-analysis-id')
  if (destroy) {
    type = 'DELETE'
    url = `/reviewees/repo_analyses/${$(this).attr('repo-analysis-id')}`
  } else {
    type = 'POST'
    url = `/reviewees/repos/${$(this).attr('repo-id')}/repo_analyses`
  }
  $.ajax({
    type: type,
    url: url,
    dataType: 'JSON',
    data: {
      search_name: $(this).attr('search-name')
    },
    element: $(this),
    success: function(data) {
      $(this.element).attr('disabled', false)
      if (destroy) {
        $(this.element).prop('checked', false)
        $(this.element).attr('repo-analysis-id', '')
      } else {
        $(this.element).prop('checked', true)
        $(this.element).attr('repo-analysis-id', data.id)
      }
    }
  });
});