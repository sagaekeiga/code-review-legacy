// HighLight JS 初期化
hljs.initHighlightingOnLoad();
$(document).on('turbolinks:load', function () {
  repoId = $('.page-header').attr('repo-id')
  $('.panel-heading').addClass('hidden')
  setContents(repoId)
});
// イベントを削除（重複回避）
$(document).off('click', '.file, .dir');
$(document).on('click', '.file, .dir', function (e) {
  e.preventDefault()
  $('img').removeClass('hidden')
  $('.code-wrapper').addClass('hidden')
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
    // 第二階層以下であれば
    if (data.breadcrumbs.length > 0) {
      newBreadcrumbs(data)
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
        tbody.appendTo('table')
      }
      breadcrumb = $(`
        <span>${data.name}</span>
      `)
      breadcrumb.appendTo(breadcrumbElem)
    } else {
      names = data.names
      for (i = 0; i < names.length; i++) {
        if (data.types[i] == 'dir') {
          icon = `<i class='fa fa-folder'></i>`
        } else {
          icon = `<i class='fas fa-file'></i>`
        }
        tbody = $(`
          <tbody>
            <td>
              ${icon}
              <a href='#' data-path='${data.paths[i]}' data-name='${data.names[i]}' class='${data.types[i]}'>
                ${data.names[i]}
              </a>
            </td>
          </tbody>
        `)
        tbody.appendTo('table')
      }
      breadcrumb = $(`
        <span>${data.breadcrumbs[data.breadcrumbs.length - 1]}</span>
      `)
      breadcrumb.appendTo(breadcrumbElem)
      $('.panel-title').text(data.breadcrumbs[data.breadcrumbs.length - 1])
    }
    $('img').addClass('hidden')
    $('.panel-heading').removeClass('hidden')
    $('.code-wrapper').removeClass('hidden')
  }).fail(function (data) {
    issueList.text('取得に失敗しました')
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
      if (data.types[i] == 'dir') {
        icon = `<i class='fa fa-folder'></i>`
      } else {
        icon = `<i class='fas fa-file'></i>`
      }
      tbody = $(`
        <tbody>
          <td>
            ${icon}
            <a href='#' data-path='${data.paths[i]}' class='${data.types[i]}'>
              ${data.names[i]}
            </a>
          </td>
        </tbody>
      `)
      tbody.appendTo('table')
    }
    $('img').addClass('hidden')
    $('.code-wrapper').removeClass('hidden')
  }).fail(function (data) {
    issueList.text('issueの取得に失敗しました')
    $('#loader').addClass('hidden')
  });
}

function newBreadcrumbs(data) {
  breadcrumbElem = $('.breadcrumbs')
  breadcrumbElem.empty()
  repoName = $('.breadcrumbs').attr('repo-name')
  topBreadcrumb = $(`<a href='/reviewers/repos/${$('.page-header').attr('repo-id')}'>${repoName}</a><span> / </span>`)
  topBreadcrumb.appendTo(breadcrumbElem)
  for (i = 0; i < data.breadcrumbs.length; i++) {
    // 1. 第二階層がファイルかどうか
    first_is_file = data.breadcrumbs.length == 1 && data.type == 'file' && data.path && data.path.indexOf('/') == -1
    // 2. 最下層がディレクトリかどうか
    last_is_dir = data.breadcrumbs[i] == data.breadcrumbs[data.breadcrumbs.length - 1] && data.type == 'dir'
    // 1か2のどちらかが真であれば該当のパンくずを生成しない
    except = first_is_file || last_is_dir
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