nestedView('Jenkins-DSL') {
  description('Everything related to Jenkins itself')
  views {
    listView('Jenkins') {
      description('Jenkins Maintenance Jobs')
      jobs {
        regex('Jenkins_.*')
      }
      columns {
        status ()
        weather ()
        name ()
        lastSuccess ()
        lastFailure ()
        lastDuration ()
        buildButton ()
      }
    }
    nestedView('Metrics') {
      description('Jenkins Metrics')
      views {
      }
    }
  }
}
