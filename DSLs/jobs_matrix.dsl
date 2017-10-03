
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
        script(
'''if [ -d "${JENKINS_HOME}" ]; then
  # or [ "${NODE_NAME}" = "master" ]
  # Jenkins master
  NODE_HOME=${JENKINS_HOME}
else
  # Jenkins build slave
  NODE_HOME=${WORKSPACE%%/workspace*}
fi
PATH=${PATH}:${NODE_HOME}/bin
dirTmp='tmp'
envVars="${dirTmp}/env.properties"
mkdir -p ${dirTmp}
echo "NODE_HOME=${NODE_HOME}" > ${envVars}
echo "HOME=${WORKSPACE}" >> ${envVars}
echo "PATH=${PATH}" >> ${envVars}''')
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
  def jobM = matrixJob('Jenkins_Tools') {
    description('Setup tools (scripts, configs, ...) on all nodes')
    axes {
      configure { axes ->
        axes << 'org.jenkinsci.plugins.elasticaxisplugin.ElasticAxis'() {
          name 'label'
          label 'All'
          ignoreOffline 'true'
        }
      }
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
    triggers {
      scm('H/10 * * * *')
    }
    steps {
      environmentVariables {
        propertiesFile('tmp/env.properties')
      }
      shell('set +x && ./update-tools.sh')
      conditionalSteps {
        condition {
          //and {
            //cause()
            //status('SUCCESS')
          shell('changed-file-git.sh tool-python-setup-new.sh')
        }
        runner('DontRun')
        steps {
          downstreamParameterized {
            trigger('Tool-Python-Setup-Nodes') { }
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
    }
  }
  genInjectHome(jobM)
  genLogRotator(jobM,10,5)
  genPragmaticProgrammer(jobM)
}

def genMatrixPython() {
  def jobM = matrixJob('Tool-Python-Setup-Nodes') {
    description('Setup Python virtual environments on all nodes')
    quietPeriod(15)
    axes {
      configure { axes ->
        axes << 'org.jenkinsci.plugins.elasticaxisplugin.ElasticAxis'() {
          name 'label'
          label 'Linux'
          ignoreOffline 'true'
        }
      }
      // TODO: change to just version and env name. Use a mapping file to get packages for the env. Fixing issue with short length of axis
      text('VirtEnv', [
        '2.7.14 analysis_2.7.14 hacking bandit tox flake8-junit-report pep8-naming',
        '2.7.14 aws boto3',
        '2.7.14 aws-cli awscli',
        '2.7.8 jjb jenkins-job-builder',
        //'2.7.11 gitlab python-gitlab',
        //'3.3.0 pytest-3.3.0 beautifulsoup4 lxml requests xmlrunner',
        //'2.6.9 ptest-2.6.9 beautifulsoup4 crypto lxml MySQL-python paramiko pycurl pymssql requests xmltodict',
        //'3.4.0 pytest-3.4.0 pytest pytest-html requests',
        '3.6.2 pytest-3.6.2 pytest pytest-html requests bzt locustio==0.8.1'
        // Needs:
        // TODO: Add ptest 2.x env
        // Need to change script to support multiple package args
        // , failed
        // " failed"
      ])
    }
    properties {
      customIcon('tools.png')
    }
    triggers {
      cron('H 1 * * *')
    }
    steps {
      environmentVariables {
        propertiesFile('tmp/env.properties')
      }
      shell('''#set +x
# FIX: This method limits the number of packages due to file name length (axes)
envArr=( ${VirtEnv} )
propFile='tmp/job.properties'
echo "python_ver=${envArr[0]}" > ${propFile}
echo "LabelName=python-${envArr[1]}" >> ${propFile}
#echo "pkgs=${envArr[@]:2}" >> ${propFile}
pkgArgs=''
pkgs="${envArr[@]:2}"
for pkg in $pkgs; do
  pkgArgs="${pkgArgs} -p ${pkg}"
done
#env | sort
tool-python-setup-new.sh -v ${envArr[0]} -e ${envArr[1]} ${pkgArgs} ''')
      environmentVariables {
        propertiesFile('tmp/job.properties')
      }
      systemGroovyScriptFile('${NODE_HOME}/bin/label-updater.groovy') {
        // Plugin doesn't support build env variables
        binding('NodeToUpdate', 'ENV')
        binding('LabelName', 'ENV')
        binding('DesiredState', 'true')
      }
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
//
// MAIN
//
genMatrixPython()
genMatrixTools()
