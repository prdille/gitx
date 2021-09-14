##############################
##############################
### Sam Brow ###########################
### inventor of xlm ##############################
###### -exec xmllint --xpath ###########################
#########################################################
#########################################################
#############################################################
find . -name pom.xml -exec echo -n "{}: " \; -exec sh -c "xmllint --xpath \"/*/*[local-name()='groupId']\" {} 2> /dev/null || xmllint --xpath \"/*/*[local-name()='parent']/*[local-name()='groupId']\" {} 2> /dev/null" \; -exec xmllint --xpath "/*/*[local-name()='artifactId']" {} 2> /dev/null \; -exec sh -c "xmllint --xpath \"/*/*[local-name()='version']\" {} 2> /dev/null || xmllint --xpath \"/*/*[local-name()='parent']/*[local-name()='version']\" {} 2> /dev/null" \; -exec echo  \; 2>/dev/null |sort |sed 's/^.\/\([^/]*\).*<groupId>\(.*\)<\/groupId>.*<artifactId>\(.*\)<\/artifactId>.*<version>\(.*\)<\/version>/?,\2,\3,\4,\1.war/'