// Defines maven jobs for project EX1
//
// This is an sample maven job setup

/*
 * TODO: Figure out how to include a seperate script and have the DSL
 * parse it correctly. Would like to keep all routine in seperate files.
 * Then just have project files that have the data set and a call to the
 * build wrapper. This would be much easier to automate.
 */

// 1 failing to convert to string ?? Preset why?
def genCheckmarx(jobInst, project, repo, teamID, preset, exclDirs, addFilters) {
  jobInst.with {
    configure { node ->
      node / 'builders' / 'com.checkmarx.jenkins.CxScanBuilder' {
        useOwnServerCredentials 'false'
        projectName "${project}-${repo}"
        groupId "${teamID}"
        projectId '0'
        preset "${preset}"
        presetSpecified 'false'
        excludeFolders "test${exclDirs}"
        filterPattern '''
!**/_cvs/**/*, !**/.svn/**/*,   !**/.hg/**/*,   !**/.git/**/*,  !**/.bzr/**/*, !**/bin/**/*,
!**/obj/**/*,  !**/backup/**/*, !**/.idea/**/*, !**/*.DS_Store, !**/*.ipr,     !**/*.iws,
!**/*.bak,     !**/*.tmp,       !**/*.aac,      !**/*.aif,      !**/*.iff,     !**/*.m3u, !**/*.mid, !**/*.mp3,
!**/*.mpa,     !**/*.ra,        !**/*.wav,      !**/*.wma,      !**/*.3g2,     !**/*.3gp, !**/*.asf, !**/*.asx,
!**/*.avi,     !**/*.flv,       !**/*.mov,      !**/*.mp4,      !**/*.mpg,     !**/*.rm,  !**/*.swf, !**/*.vob,
!**/*.wmv,     !**/*.bmp,       !**/*.gif,      !**/*.jpg,      !**/*.png,     !**/*.psd, !**/*.tif, !**/*.swf,
!**/*.jar,     !**/*.zip,       !**/*.rar,      !**/*.exe,      !**/*.dll,     !**/*.pdb, !**/*.7z,  !**/*.gz,
!**/*.tar.gz,  !**/*.tar,       !**/*.gz,       !**/*.ahtm,     !**/*.ahtml,   !**/*.fhtml, !**/*.hdm,
!**/*.hdml,    !**/*.hsql,      !**/*.ht,       !**/*.hta,      !**/*.htc,     !**/*.htd,
!**/*.htmls,   !**/*.ihtml,     !**/*.mht,      !**/*.mhtm,     !**/*.mhtml,   !**/*.ssi, !**/*.stm,
!**/*.stml,    !**/*.ttml,      !**/*.txn,      !**/*.xhtm,     !**/*.xhtml,   !**/*.class, !**/*.iml,
!**/*.cfg,     !**/*.dat,       !**/*.ini,      !**/*.md,       !**/*.pyc,  !flake8*, !bandit*
'''
        incremental 'false'
        fullScansScheduled 'false'
        isThisBuildIncremental 'false'
        comment 'Scan run from $BUILD_TAG'
        waitForResultsEnabled 'true'
        generatePdfReport 'true'
        jobStatusOnError 'GLOBAL'
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
def genProperties(jobInst, githubUrl, githubOrg, repo, icon, artPerm) {
  jobInst.with {
    properties {
      customIcon(icon)
      githubProjectUrl("${githubUrl}/${githubOrg}/${repo}/")
      // TODO: Add sidebar links: Java, Maven
      //sidebarLinks { link('url', 'text', 'icon path')}
      if ( artPerm != '') {
        configure { node ->
          node / 'properties' / 'hudson.plugins.copyartifact.CopyArtifactPermissionProperty' {
            projectNameList { string "${artPerm}" }
          }
        }
      }
    }
  }
}
def genReporters(jobInst) {
  jobInst.with {
    configure { node ->
      node / 'reporters' / 'hudson.plugins.checkstyle.CheckStyleReporter' {
        canRunOnFailed 'true'
      }
      node / 'reporters' / 'hudson.plugins.findbugs.FindBugsReporter' {
        canRunOnFailed 'true'
      }
      node / 'reporters' / 'hudson.plugins.pmd.PmdReporter' {
        canRunOnFailed 'true'
      }
      node / 'reporters' / 'hudson.plugins.dry.DryReporter' {
        canRunOnFailed 'true'
      }
      node / 'reporters' / 'com.blackducksoftware.integration.freemium.jenkins.maven.VulnerabilityReportMavenReporter' {
        userScopesToInclude 'compile, runtime, provided, system, test'
      }
      // Disable - Crashing build job
      // node / 'reporters' / 'hudson.plugins.violations.hudson.maven.ViolationsMavenReporter' {}
    }
  }
}
def genSCM(jobInst, urlStr, cred) {
  jobInst.with {
    scm {
      git {
        remote {
          url(urlStr)
          credentials(cred)
        }
        branches('*/master')
      }
    }
  }
}
def genTriggers(jobInst, jobType) {
  jobInst.with {
    triggers {
      snapshotDependencies(true)
      if (jobType == 'analysis') {
        scm('H/10 * * * *')
      }
    }
  }
}
//def genJobValidate {}
// make both Analysis and Package call same routine with some diff args
//  Diffs: desc, goals, publishers, trigger, copy artifact setup
def genMavenJob(Map args){
  def projData = [
    //publishers:'', triggers:'',
    jobType:'analysis',
    project:'', repo:'', label:'', icon:'',
    githubUrl:'', githubOrg:'', githubCred:'',
    jdkVer:'Sun Java SE DK 8u66', mavenVer:'Maven 3.3.3'
  ]
  def jobName, downstreamJob
  def requiredValues = ['project', 'repo']
  args.each{k,v->
    projData["$k"] = "$v"
  }
  if ( projData['jobType'] == 'analysis' ) {
    projData['desc'] = 'Java Code analysis'
    projData['downstreamType'] = 'package'
    projData['goals'] = 'clean checkstyle:checkstyle findbugs:findbugs pmd:pmd pmd:cpd test'
    projData['pubWarnings'] = ['Java Compiler (javac)', 'Maven', 'JavaDoc Tool']
    artifactJobsAllowed = ''
  } else { // package
    projData['desc'] = 'Java Code build and package'
    projData['downstreamType'] = 'validate'
    projData['goals'] = 'clean package'
    projData['pubWarnings'] = ['Java Compiler (javac)', 'Maven', 'JavaDoc Tool', 'Custom-RPMLint']
    artifactJobsAllowed = "${projData['project']}-${projData['repo']}*"
  }
  jobName = "${projData['project']}-${projData['repo']}_${projData['jobType']}_MavenJava"
  downstreamJob = "${projData['project']}-${projData['repo']}_${projData['downstreamType']}_MavenJava"
  def jobM = mavenJob(jobName) {
    description("${projData['desc']}\nlint:ignore:HardcodedScriptChecker")
    jdk(projData['jdkVer'])
    label(projData['label'])
    quietPeriod(10)
    mavenInstallation(projData['mavenVer'])
    rootPOM('pom.xml')
    goals(projData['goals'])
    if (projData['jobType'] == 'package') {
      postBuildSteps('SUCCESS') {
        shell('''
# Cleanup - build script should handle this
rm -rf pkg/*.rpm
''')
        shell('''
#!/bin/bash

chmod +x $WORKSPACE/pkg/rpmbuilder.sh
$WORKSPACE/pkg/rpmbuilder.sh

''')
        shell('''#!/bin/bash
#
# Get RPM version from rpm filename
#
dir_rpms='pkg'
file_version='version.properties'

file=$(ls -1 ${dir_rpms}/*.rpm | head -1)
if [[ $file =~ ([0-9]+[.][0-9]+[.][0-9]+-[0-9]+) ]]; then
   version_full=${BASH_REMATCH[1]}
   version_app=${version_full%-*}
else
  echo "ERROR: No version found from: $file"
  exit 1
fi

echo "app_version=${version_full}" > ${file_version}
''')
      }
    }
    publishers {
      warnings(projData['pubWarnings'], [:]) {
        canRunOnFailed(true)
      }
      if (projData['jobType'] == 'analysis') {
        analysisCollector {
          canRunOnFailed(true)
          checkstyle()
          dry()
          findbugs()
          pmd()
          tasks()
          warnings()
        }
        // Moved to reporters section - These shouldn't be needed for a maven job
        //checkstyle('**/checkstyle-result.xml') {
        //  canRunOnFailed(true)
        //  shouldDetectModules(true)
        //}
        //dry('**/cpd.xml', 80, 20) {
        //  canRunOnFailed(true)
        //  shouldDetectModules(true)
        //}
        //findbugs('**/findbugsXml.xml', false) {
        //  canRunOnFailed(true)
        //  shouldDetectModules(true)
        //}
        //pmd('**/*.pmd') {
        //  canRunOnFailed(true)
        //  shouldDetectModules(true)
        //}
        //violations {
          //checkstyle
          //cpd
          //findbugs
          //pmd
        //}
      } else {
        // Package
        archiveArtifacts {
          pattern('pkg/*.rpm,pkg/*rpmlint.config,rpmlint')
          fingerprint(true)
          onlyIfSuccessful(true)
        }
      }
      downstreamParameterized {
        trigger(downstreamJob) {
          condition('SUCCESS')
          if (projData['downstreamType'] == 'validate') {
            parameters {
              propertiesFile('version.properties', true)
            }
          } else {
            triggerWithNoParameters(true)
          }
        }
      }
      extendedEmail {
        //recipentList('$DEFAULT_RECIPENTS')
        //replyToList('$DEFAULT_REPLYTO')
        //contentType('default')
        //defaultSubject('$DEFAULT_SUBJECT')
        //defaultContent('$DEFAULT_CONTENT')
        triggers {
          if (projData['recipients'] != '') {
            always {
              recipientList(projData['recipients'])
            }
          }
          failure {
            sendTo {
              culprits()
              developers()
            }
          }
        }
      }
    }
    wrappers {
      //credentialsBinding{
        // hipChat token
      //}
      timeout {
        absolute(60)
        failBuild()
      }
      timestamps()
    }
  }
  genLogRotator(jobM,10,5)
  genProperties(jobM,projData['githubUrl'],projData['githubOrg'],projData['repo'],projData['icon'],"${artifactJobsAllowed}")
  genSCM(jobM,"${projData['githubUrl']}/${projData['githubOrg']}/${projData['repo']}", projData['githubCred'])
  genTriggers(jobM, projData['jobType'])
  genPragmaticProgrammer(jobM)
  if (projData['jobType'] == 'analysis') {
    genReporters(jobM)
    // Using WTP Team ID
    // genCheckmarx(jobM, projData['project'], projData['repo'], '93d7f25b-b895-4c34-9419-6332b321520d', '1', '', '')
  }
}

def genJobs(projects = []) {
  projects.each { projectData ->
    if (projectData['repo'] != null && ! (projectData['repos'] instanceof List)) {
      projectData['jobType'] = 'analysis'
      genMavenJob(projectData)
      projectData['jobType'] = 'package'
      genMavenJob(projectData)
    }
    else if (projectData['repos'] instanceof List && projectData['repo'] == null) {
      projectData['repos'].each { repo ->
        projectData['repo'] = repo
        projectData['jobType'] = 'analysis'
        genMavenJob(projectData)
        projectData['jobType'] = 'package'
        genMavenJob(projectData)
      }
    } else {
      println "ERROR: Cannot define both repo and repos"
    }
  }
}

def projectSets = [
// Example of a single repo
//[ project:'TEST', repo:'repo', label:'master', icon:'button-test.png',
//  githubUrl:'https://github.com',githubOrg:'devops-workflow',githubCred:'',
//  recipients:'person1@example.com' ],
// Example of setting up multiple repos in an organization at once
[ project:'EX1', label:'ex1', icon:'button-test.png',
  githubUrl:'https://github.com',
  githubOrg:'ex1', githubCred:'050a7019-29fd-4204-baff-2708a28cfe00',
  recipients:'person1@example.com,person2@example.com',
  repos:['application-1', 'application-2',
   'application-3'] ],
]

genJobs(projectSets)
