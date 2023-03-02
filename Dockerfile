FROM jenkins/jenkins:lts-jdk11

COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/plugins.txt
# run the install-plugins script to install the plugins
RUN jenkins-plugin-cli -f /usr/share/jenkins/plugins.txt
#RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/plugins.txt

# disable the setup wizard as we will set up jenkins as code :)
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
COPY seedjob.groovy /usr/local/seedjob.groovy
# copy the config-as-code yaml file into the image
COPY jenkins-casc.yaml /usr/local/jenkins-casc.yaml
# tell the jenkins config-as-code plugin where to find the yaml file
ENV CASC_JENKINS_CONFIG /usr/local/jenkins-casc.yaml
