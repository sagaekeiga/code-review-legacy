var stack = [];
document.getElementById('searchInput').addEventListener('keyup', function () {
	stack.push(1);
	setTimeout($.proxy(function () {
		stack.pop();
		if (stack.length == 0) {
			Search($(this))
			stack = [];
		}
	}, this), 300);
});

function Search(elem) {
	$('.loader').removeClass('hidden')
	$('.results-wrapper').addClass('hidden')
	$('.search-results-count').addClass('hidden')
	$('.results-wrapper').empty()
	keyword = elem.val()
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
		paths = data.paths
		// 検索結果一覧要素の作成
		for (i = 0; i < total_count; i++) {
			// コード要素の生成
			codeWrapper = $(`
				<div class='code-wrapper'>
					<p class='filename'>${names[i]}</p>
					<div class='panel panel-default' data-path=${paths[i]} data-name=${names[i]}>
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
}
$(document).on('click', '.panel', function () {
  $('.search-results-count').text('')
  $('.results-wrapper').empty()
  $('.loader').removeClass('hidden')
  repoId = $('.page-header').attr('repo-id')
  path = $(this).attr('data-path')
  name = $(this).attr('data-name')
  $.ajax({
    type: 'GET',
    url: `/reviewers/github/contents/get_contents`,
    dataType: 'JSON',
    data: {
      repo_id: repoId,
      path: path,
      file_type: 'file',
      name: name
    },
  }).done(function (data) {
    highlightContent = data.content
    codeWrapper = $(`
      <div class='code-wrapper'>
        <p class='filename'>${data.name}</p>
        <div class='panel panel-default' data-path=${data.path} data-name=${data.name}>
          <table class='table${i}'></table>
        </div>
      </div>
    `)
    codeWrapper.appendTo('.results-wrapper')
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
        <tbody class='file'>
          <tr>
            <td class='index'>${i}</td>
            <td class='file-code'>${code}</td>
          </tr>
        </tbody>
      `)
      $('.panel-title').text(data.name)
      tbody.appendTo('table')
    }
    $('.loader').addClass('hidden')
    $('.panel-heading').removeClass('hidden')
    $('.code-wrapper').removeClass('hidden')
  }).fail(function (data) {
		issueList.text('取得に失敗しました')
    $('#loader').addClass('hidden')
  });
})