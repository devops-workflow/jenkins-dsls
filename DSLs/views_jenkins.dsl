nestedView('Jenkins') {
  description('Everything related to Jenkins itself and maintaining the environments')
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
    listView('Templates') {
      description('Generic Templates')
      jobs {
        regex('Template[-_].*')
      }
      columns {
        name ()
      }
    }
    listView('Tools') {
      description('Jobs for installing tools')
      jobs {
        regex('(Test-)?Tools?-.*')
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
  }
  columns {
    status ()
    weather ()
  }
}
