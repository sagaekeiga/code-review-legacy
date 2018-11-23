$(document).on('input', '.search-input', function (e) {
	keyword = $(this).val()
	repoId = $('.page-header').attr('repo-id')
	$.ajax({
		type: 'GET',
		url: `/reviewers/repos/${repoId}/contents`,
		dataType: 'JSON',
		data: {
			keyword: keyword
		},
	}).done(function (data) {
		// $('img').addClass('hidden')
		// $('.panel-heading').removeClass('hidden')
		// $('.code-wrapper').removeClass('hidden')
	}).fail(function (data) {
		// issueList.text('取得に失敗しました')
		// $('#loader').addClass('hidden')
	});
})