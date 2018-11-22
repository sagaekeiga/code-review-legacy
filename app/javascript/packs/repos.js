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
  name = $(this).attr('data-name')
  $.ajax({
    type: 'GET',
    url: `/reviewers/github/contents/get_contents`,
    dataType: 'JSON',
    data: {
      repo_id: repoId,
      path: path,
			file_type: fileType,
			name: name
    },
	}).done(function (data) {
		console.log(data.breadcrumbs)
    console.log(data.breadcrumb_paths)
    // 第二階層以下であれば
    if (data.breadcrumbs.length > 0) {
      breadcrumbElem = $('.breadcrumbs')
      breadcrumbElem.empty()
      repoName = $('.path').attr('repo-name')
      topBreadcrumb = $(`<a href='/reviewers/repos/${$('.page-header').attr('repo-id')}'>${repoName}</a><span> / </span>`)
      topBreadcrumb.appendTo(breadcrumbElem)
      for (i = 0; i < data.breadcrumbs.length; i++) {
        first_is_file = data.breadcrumbs.length == 1 && data.type == 'file'
        last_is_dir = data.breadcrumbs[i] == data.breadcrumbs[data.breadcrumbs.length - 1] && data.type == 'dir'
        except = first_is_file || last_is_dir
        console.log(data.breadcrumbs.size)
        console.log(data.type)
        console.log(data.type == 'file')
        if (except) {
          continue;
        }
        breadcrumb = $(`
          <span>
            <a href='#' data-path='${data.breadcrumb_paths[i]}'>${data.breadcrumbs[i]}</a>
            <span> / </span>
          </span>
        `)
        breadcrumb.appendTo(breadcrumbElem)
      }
    }
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
				$('.panel-title').text(data.name)
				tbody.appendTo('table.main')
      }
      breadcrumb = $(`
        <span>${data.name}</span>
      `)
      breadcrumb.appendTo(breadcrumbElem)
    } else {
      names = data.names
      for (i = 0; i < names.length; i++) {
        tbody = $(`
				<tbody>
					<td>
						<a href='#' data-path='${data.paths[i]}' data-name='${data.names[i]}' class='${data.types[i]}'>
							${data.names[i]}
						</a>
					</td>
				</tbody>
			`)
				tbody.appendTo('table.main')
      }
      breadcrumb = $(`
        <span>${data.breadcrumbs[data.breadcrumbs.length - 1]}</span>
      `)
      breadcrumb.appendTo(breadcrumbElem)
    }
    $('img').addClass('hidden')
    $('.panel.main').removeClass('hidden')
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
			tbody.appendTo('table.main')
    }
    $('img').addClass('hidden')
		$('.panel.main').removeClass('hidden')
  }).fail(function (data) {
    issueList.text('issueの取得に失敗しました')
    $('#loader').addClass('hidden')
  });
}