hljs.initHighlightingOnLoad();
$(document).ready(function () {
  codeButtons = $('.code-button')
  // 配列membersを順に処理
  $.each(codeButtons, function (index, codeButton) {
    thead = $(codeButton).closest('.panel-footer').nextAll('.code-wrapper').find('thead')
    repoId = $(codeButton).attr('repo-id')
    changedFileId = $(codeButton).attr('changed-file-id')
    $.ajax({
      type: 'GET',
      url: `/reviewers/github/contents`,
      dataTypr: 'JSON',
      data: {
        repo_id: repoId,
        changed_file_id: changedFileId
      },
    }).done(function (data) {
      highlightContent = data.content
      for (i = 0; i < highlightContent.length + 1; i++) {
        if (i == 0) {
          continue;
        } // 最初はundefinedになる
        // DOMエレメント生成
        var code = highlightContent[highlightContent.length - i]
        // jQueryオブジェクトに変換
        code = $(`<pre><code>${highlightContent[highlightContent.length - i]}</code></pre>`)
        // DOMエレメントに変換
        var code = code[0]
        // DOMエレメント出ないとハイライトしない
        hljs.highlightBlock(code);
        // 文字列で取得
        code = code.outerHTML
        tbody = $(`
						<tbody>
							<tr>
								<td class='index'>${(highlightContent.length + 1) - i}</td>
								<td class='file-code'>${code}</td>
							</tr>
						</tbody>
					`)
        targetElement = $(`#code${index}`)
        $(tbody).insertAfter(targetElement)
      }
    }).fail(function (data) {
      issueList.text('issueの取得に失敗しました')
      $('#loader').addClass('hidden')
    });
  });
});
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