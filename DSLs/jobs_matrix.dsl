matrixJob('TEST-Matrix-Elastic') {
  description('Test of matrix job with ElasticAxis')
  axes {
    configure { axes ->
      axes << 'org.jenkinsci.plugins.elasticaxisplugin.ElasticAxis'() {
        name 'label'
        label '!master'
        ignoreOffline 'true'
      }
    }
    text('VirtEnv', '2.7.11 analysis_2.7.11 hacking bandit tox flake8-junit-report pep8-naming,2.7.11 aws boto3,2.7.11 jjb jenkins-job-builder')
  }
  //scm {}
  //triggers {}
  //steps {}
  //publishers {}
}
