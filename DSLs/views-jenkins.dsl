nestedView('Jenkins-DSL') {
  description('Everything related to Jenkins itself')
  views {
    listView('Jenkins') {
      description('Jenkins Maintenance Jobs')
      jobs {
        regex('Jenkins_.*')
      }
    }
    nestedView('Metrics') {
      description('Jenkins Metrics')
      views {
      }
    }
  }
}
