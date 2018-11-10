var listen;

listen = function (el, event, handler) {
    if (el.addEventListener) {
        el.addEventListener(event, handler);
    } else {
        el.attachEvent('on' + event, function () {
            return handler.call(el);
        });
    }
    $('html').css('overflow', 'auto');
    return $('#sidebar').simpleSidebar({
        opener: '#button',
        wrapper: '#wrapper',
        sidebar: {
            align: 'left',
            width: 200,
            closingLinks: '.close-sidebar'
        }
    });
};
