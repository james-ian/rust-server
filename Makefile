#out/ip: out/terraform.log

out: terraform.tfstate
	mkdir -p out
	jq --raw-output ' .resources | map(select(.type == "aws_instance"))[0].instances[0].attributes.public_ip' terraform.tfstate > out/ip
	jq --raw-output '.resources | map(select(.type == "aws_instance")) | .[0].instances[0].attributes.id' terraform.tfstate > out/id

terraform.tfstate:
	terraform init
	terraform apply -auto-approve


destroy: clean
	terraform destroy -auto-approve

clean:
	rm -rf out

cleanall: clean
	rm -rf .terraform terraform.tfstate *.stackdump

ssh:
	ssh \
		-oStrictHostKeyChecking=false \
		-oUserKnownHostsFile=/dev/null \
		-l ec2-user \
		`cat out/ip`

tail:
	ssh \
		-oStrictHostKeyChecking=false \
		-oUserKnownHostsFile=/dev/null \
		-l ec2-user \
		`cat out/ip` \
		sudo tail -n 100 -f /home/rust/rustserver/nohup.out

start: out
	aws ec2 start-instances --instance-ids `cat out/id`

stop: out
	aws ec2 stop-instances --instance-ids `cat out/id`
