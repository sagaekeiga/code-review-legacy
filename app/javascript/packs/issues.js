$(document).ready(function () {
  repoId = $('#issueTab').find('.page-header').attr('repo-id')
  issueNumbers = $('#issueTab').find('.page-header').attr('issue-numbers')
  issueList = $('#issueList')
  if (issueNumbers < 1) {
    issueList.text('issueはありません')
    exit;
  }
  $.ajax({
    type: 'GET',
    url: `/reviewers/repos/${repoId}/issues/remote`,
    dataTypr: 'JSON',
    data: { issue_numbers: issueNumbers },
  }).done(function (data) {
    $.each(data.titles, function (i, title) {
      issue = $(`
        <div class='panel'>
          <div class='page-header'>
            <h4>
              ${title}
              <span class='text-muted'>#${data.issue_numbers[i]}</span>
            </h4>
          </div>
          <div class='panel-body'>
            <div class='md-wrapper'>${marked(data.bodies[i])}</div>
          </div>
        </div>
      `)
      issue.appendTo(issueList)
    });
  }).fail(function (data) {
    issueList.text('issueの取得に失敗しました')
  });
});


marked.setOptions({
  // Githubっぽいmd形式にするか
  gfm: true,
  // Githubっぽいmdの表にするか
  tables: true,
  // Githubっぽいmdの改行形式にするか
  breaks: true,
  // Markdownのバグを修正する？（よく分からなかったので、とりあえずdefaultのfalseで）
  pedantic: false,
  // HTML文字をエスケープするか
  sanitize: true,
  // スマートなリストにするか。pedanticと関わりがあるようなので、こちらもdefaultのtrueで。
  smartLists: true,
  // クオートやダッシュの使い方。
  smartypants: true,
});