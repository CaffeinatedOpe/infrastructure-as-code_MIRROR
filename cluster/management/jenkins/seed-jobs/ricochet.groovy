#!/usr/bin/env groovy

pipelineJob('ricochet') {
    displayName('ricochet builds')

    logRotator {
        numToKeep(100)
        daysToKeep(90)
    }

		properties {
        pipelineTriggers {
            triggers {
                pollSCM {
    							scmpoll_spec('H/5 * * * *')
								} 
            }
        }
    }

    configure { project ->
        project / 'properties' / 'org.jenkinsci.plugins.workflow.job.properties.DurabilityHintJobProperty' {
            hint('PERFORMANCE_OPTIMIZED')
        }
    }

    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('https://codeberg.org/CaffeinatedOpe/ricochet')
                    }
                    branches('*/master')
                }
            }
            scriptPath('ci/Jenkinsfile')
        }
    }
}