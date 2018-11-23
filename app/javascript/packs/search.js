$(document).on('input', '.search-input', function (e) {
	$('.loader').removeClass('hidden')
	$('.results-wrapper').addClass('hidden')
	$('.search-results-count').addClass('hidden')
	$('.results-wrapper').empty()
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
		total_count = data.total_count
		indices = data.indices
		highlightContent = data.highlight_contents
		names = data.names
		// 検索結果一覧要素の作成
		for (i = 0; i < total_count; i++) {
			// コード要素の生成
			codeWrapper = $(`
				<div class='code-wrapper'>
					<p class='filename'>${names[i]}</p>
					<div class='panel panel-default'>
					  <table class='table${i}'></table>
					</div>
				</div>
			`)
			codeWrapper.appendTo('.results-wrapper')
			for (t = 0; t < highlightContent[i].length; t++) {
				// DOMエレメント生成
				for (k = 0; k < highlightContent[i][t].length; k++) {
					border = ''
					if (t > 0 && (highlightContent[i].length == t + 1) && (k == 0)) {
						border = `
							<tbody class='file'>
								<tr>
									<td class='border'>•••</td>
									<td class='border'></td>
								</tr>
							</tbody>
						`
					}
					var code = highlightContent[i][t][k]
					// jQueryオブジェクトに変換
					code = $(`<pre><code>${code}</code></pre>`)
					// DOMエレメントに変換
					var code = code[0]
					// DOMエレメント出ないとハイライトしない
					hljs.highlightBlock(code);
					// 文字列で取得
					code = code.outerHTML
					tbody = $(`
					  ${border}
						<tbody class='file'>
							<tr>
								<td class='index'>#</td>
								<td class='file-code'>${code}</td>
							</tr>
						</tbody>
					`)
					tbody.appendTo(`.table${i}`)
				}
			}
		}
		$('.search-results-count').text(`検索結果: ${total_count} 件`)
		$('.loader').addClass('hidden')
		$('.results-wrapper').removeClass('hidden')
		$('.search-results-count').removeClass('hidden')
	}).fail(function (data) {
		// issueList.text('取得に失敗しました')
		// $('#loader').addClass('hidden')
	});
})