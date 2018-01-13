
listView('Favorites') {
  description('Personal favorite jobs')
  configure { view ->
    view / 'jobFilters' / 'hudson.views.AllJobsFilter' {}
    view / 'jobFilters' / 'hudson.plugins.favorite.filter.FavoriteFilter' {}
  }
  columns {
    status ()
    weather ()
    name ()
    lastSuccess ()
    lastFailure ()
    lastDuration ()
    lastBuildConsole()
    buildButton ()
    customIcon ()
  }
  configure { view ->
    view / 'columns' / 'hudson.plugins.favorite.column.FavoriteColumn' {}
    view / 'columns' / 'hudson.plugins.projectstats.column.NumBuildsColumn' {}
  }
}
