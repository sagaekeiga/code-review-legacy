$(document).on('click', '.code-button', function () {
	var menu = $(this)
	var repliesWrapper = $(this).closest('.panel-footer').nextAll('.code-wrapper')
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