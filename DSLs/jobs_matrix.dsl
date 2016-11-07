
//
// Matrix jobs:
//
// Jenkins-Tools
// Tool-Python-Setup-Nodes

//
// General library routines
//
// TODO:
//  routine for ElasticAxis

def genInjectHome(jobInst) {
  jobInst.with {
    wrappers {
      environmentVariables {
        script('''
if [ -d "${JENKINS_HOME}" ]; then
  # or [ "${NODE_NAME}" = "master" ]
  # Jenkins master
  HOME=${JENKINS_HOME}
else
  # Jenkins build slave
  HOME=${WORKSPACE%%/workspace*}
fi
PATH=${PATH}:${HOME}/bin''')
      }
    }
  }
}
def genLogRotator(jobInst, numKeep, artifactKeep) {
  jobInst.with {
    logRotator {
      numToKeep(numKeep)
      artifactNumToKeep(artifactKeep)
    }
  }
}
def genPragmaticProgrammer(jobInst) {
  jobInst.with {
    configure { node ->
      node / 'publishers' / 'jenkins.plugins.pragprog.PragprogBuildStep' {
        displayLanguageCode 'en'
        indicateBuildResults 'true'
      }
    }
  }
}

//
// Jobs
//
/*
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
*/
def genMatrixTools() {
  def jobM = matrixJob('Jenkins-Tools-TEST') {
    description('Setup tools on all nodes')
    axes {
      configure { axes ->
        axes << 'org.jenkinsci.plugins.elasticaxisplugin.ElasticAxis'() {
          name 'label'
          label 'All'
          ignoreOffline 'true'
        }
      }
      text('VirtEnv', '2.7.11 analysis_2.7.11 hacking bandit tox flake8-junit-report pep8-naming,2.7.11 aws boto3,2.7.11 jjb jenkins-job-builder')
    }
    properties {
      customIcon('jenkins.png')
      githubProjectUrl('https://github.com/devops-workflow/jenkins-tools')
    }
    scm {
      git {
        remote {
          url('https://github.com/devops-workflow/jenkins-tools.git')
        }
        branches('*/master')
      }
    }
    //triggers {
    //  scm('H/10 * * * *')
    //}
    steps {
      shell('set +x && ./update-tools.sh')
    }
    wrappers {
      timeout {
        absolute(60)
        failBuild()
      }
      timestamps()
    }
  }
  genInjectHome(jobM)
  genLogRotator(jobM,10,5)
  genPragmaticProgrammer(jobM)
}

def genMatrixPython() {
  def jobM = matrixJob('Tool-Python-Setup-Nodes-TEST') {
    description('Setup Python virtual environments on all nodes')
    axes {
      configure { axes ->
        axes << 'org.jenkinsci.plugins.elasticaxisplugin.ElasticAxis'() {
          name 'label'
          label '!master'
          ignoreOffline 'true'
        }
      }
      text('VirtEnv',
'''2.7.11 analysis_2.7.11 hacking bandit tox flake8-junit-report pep8-naming
2.7.11 aws boto3
2.7.11 jjb jenkins-job-builder
''')
    }
    properties {
      customIcon('tools.png')
    }
    //triggers {}
    steps {
      // TODO: ?? move Python setup into this job
      shell('''
set +x
# Setup property file are parameters
# FIX: This method limits the number of packages due to file name length
propFile=parameters.properties
echo "node=${label}" > ${propFile}
#echo "python_ver=${PythonVer}" >> ${propFile}
envArr=( ${VirtEnv} )
echo "python_ver=${envArr[0]}" >> ${propFile}
echo "venv=${envArr[1]}" >> ${propFile}
echo "pkgs=${envArr[@]:2}" >> ${propFile}''')
      downstreamParameterized {
        trigger('Tool-Python') {
          block {
            buildStepFailure('FAILURE')
            failure('FAILURE')
            unstable('UNSTABLE')
          }
          parameters {
            propertiesFile('parameters.properties', true)
          }
        }
      }
    }
    wrappers {
      timeout {
        absolute(60)
        failBuild()
      }
      timestamps()
      // inject-home ?
    }
  }
  genInjectHome(jobM)
  genLogRotator(jobM,10,5)
  genPragmaticProgrammer(jobM)
}
//
// MAIN
//
genMatrixPython()
genMatrixTools()
