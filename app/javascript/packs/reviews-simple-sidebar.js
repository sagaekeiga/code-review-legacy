$(document).ready(function () {
    var sidebar = new StickySidebar('.sidebar', {
    topSpacing: 100,
    bottomSpacing: 20,
    containerSelector: '.main-content',
    innerWrapperSelector: '.sidebar__inner'
    });
});