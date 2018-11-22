hljs.initHighlightingOnLoad();
$(document).ready(function () {
  repoId = $('.page-header').attr('repo-id')
  setContents(repoId)
});
$(document).on('click', '.file, .dir', function (e) {
  e.preventDefault()
  $('img').removeClass('hidden')
  $('.table').empty()
  fileType = $(this).attr('class')
  repoId = $('.page-header').attr('repo-id')
  path = $(this).attr('data-path')
  $.ajax({
    type: 'GET',
    url: `/reviewers/github/contents/get_contents`,
    dataType: 'JSON',
    data: {
      repo_id: repoId,
      path: path,
      file_type: fileType
    },
  }).done(function (data) {
    if (data.type == 'file') {
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
          <tbody class='file'>
            <tr>
              <td class='index'>${i}</td>
              <td class='file-code'>${code}</td>
            </tr>
          </tbody>
				`)
				$('.path').text(data.path)
				$('.panel-title').text(data.name)
        tbody.appendTo('table')
      }
    } else {
      names = data.names
      for (i = 0; i < names.length; i++) {
        tbody = $(`
				<tbody>
					<td>
						<a href='#' data-path='${data.paths[i]}' class='${data.types[i]}'>
							${data.names[i]}
						</a>
					</td>
				</tbody>
			`)
        tbody.appendTo('table')
      }
    }
    $('img').addClass('hidden')
    $('.panel').removeClass('hidden')
  }).fail(function (data) {
    issueList.text('issueの取得に失敗しました')
    $('#loader').addClass('hidden')
  });
})

function setContents(repoId) {
  $.ajax({
    type: 'GET',
    url: `/reviewers/github/contents/get_contents`,
    dataType: 'JSON',
    data: {
      repo_id: repoId
    },
  }).done(function (data) {
    names = data.names
    for (i = 0; i < names.length; i++) {
      tbody = $(`
				<tbody>
					<td>
						<a href='#' data-path='${data.paths[i]}' class='${data.types[i]}'>
							${data.names[i]}
						</a>
					</td>
				</tbody>
			`)
      tbody.appendTo('table')
    }
    $('img').addClass('hidden')
    $('.panel').removeClass('hidden')
  }).fail(function (data) {
    issueList.text('issueの取得に失敗しました')
    $('#loader').addClass('hidden')
  });
}