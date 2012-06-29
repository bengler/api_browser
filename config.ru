require './lib/api_browser.rb'

ApiBrowser.config(
  name: "Underskog",
  url: "http://underskog.dev",
  oauth: {
    key: 'voqgUEUrvFt9nR4yYTtUvtMvlatrroLrXEhQ6jnK',
    secret: 'dr5tPcfiQEd5zKlIxg76Z0EZjnvBD6vJIsy3jHxP'
  },
  doc_path: '/Users/runeb/Projects/Underskog/app',
  session: {
    path: '/'
  }
)

run ApiBrowser::App

