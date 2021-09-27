pipeline {
    agent { label 'jenkins-dynamic-slave' }
    stages {
        stage('Build') {
            when {
              expression { env.BRANCH_NAME == "main" }
            }
            steps {
              script {
                env.VERSION = readFile(file: '.version')
              }
              withCredentials([gitUsernamePassword(credentialsId: 'sf-reference-arch-devops',
                 gitToolName: 'git-tool')]) {
                 sh('''
                      git config user.name 'sfdevops'
                      git config user.email 'sfdevops@sourcefuse'
                      git tag -a \$VERSION -m \$VERSION
                      git push origin \$VERSION
                  ''')
              }
            }
        }
        stage('Deploy') {
            steps {
              withCredentials([[
                  $class: 'AmazonWebServicesCredentialsBinding',
                  credentialsId: "sf_ref_arch_aws_creds",
                  accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                  secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
              ]]) {
                  sh "echo ${env.BRANCH_NAME}"
                  sh "tfenv install"
                  sh "terraform -v"
                  sh "terraform init"
                  sh "terraform workspace select dev"
                  sh "terraform plan -var-file=dev.tfvars"
                  sh "terraform apply -auto-approve -var-file=dev.tfvars"
              }
            }
        }
    }
}
