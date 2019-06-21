// const { _, pages } = require('@/util')
const header = require('./header/main')
// const footer = require('./footer/main')
// const pagesReq = require.context('.', true, /\.\/[^/]+Page\/main\.js$/)
// const pageComponents = {}
// pagesReq.keys().forEach(key => {
//   const k = key.split('/')[1]
//   pageComponents[k.slice(0, k.length - 4)] = pagesReq(key)
// })
// const modalsReq = require.context('./modals', true, /\.js$/)
// const modals = {}
// modalsReq.keys().forEach(key => {
//   modals[_.last(key.split('/')).split('.')[0]] = modalsReq(key)
// })
// const noticesReq = require.context('./notices', true, /\.js$/)
// const notices = {}
// noticesReq.keys().forEach(key => {
//   notices[_.last(key.split('/')).split('.')[0]] = noticesReq(key)
// })
module.exports = s => {
  // const modal = s.modal ? [modals[s.modal.type](s)] : []
  // const notice = s.notice ? [notices[s.notice.type](s)] : []
  let main = []
  // for (const [k, v] of Object.entries(pages)) {
  //   if (s.page === v.path) {
  //     if ((!v.loginRequired && !v.logoutRequired) || s.login.checked) {
  //       main = [pageComponents[v.component || k](s)]
  //     }
  //     break
  //   }
  // }
  return [header(s), ...main]
}
