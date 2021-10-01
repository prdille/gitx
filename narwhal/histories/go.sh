$ go mod download github.com/aws/aws-sdk-go  
$ go mod download github.com/gruntwork-io/terratest  
$ go mod init test  
$ go mod tidy   
$ go test -v -timeout 40m gke_test.go
