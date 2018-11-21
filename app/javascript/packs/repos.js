$(document).ready(function () {
	repoId = $(codeButton).attr('repo-id')
	$.ajax({
		type: 'GET',
		url: `/reviewers/github/contents/fetch_contents`,
		dataTypr: 'JSON',
		data: {
			repo_id: repoId
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