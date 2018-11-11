$(document).on('click', '.check', function (e) {
	$('input:checkbox').each(function (index, element) {
		if (!$(element).prop('checked')) {
			exit;
		}
	})
	$('#submit_review_button').prop('disabled', false)
})