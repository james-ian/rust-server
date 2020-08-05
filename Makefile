#out/ip: out/terraform.log
ip:
	terraform init
	terraform apply -auto-approve
	jq --raw-output ' .resources | map(select(.type == "aws_instance"))[0].instances[0].attributes.public_ip' terraform.tfstate > ip

#out/terraform.log:
#	mkdir -p out
#	terraform init
#	terraform apply -no-color -auto-approve | tee out/terraform.log

destroy: clean
	terraform destroy -auto-approve

clean:
	rm -rf ip

distclean:
	rm -rf .terraform terraform.*

ssh:
	ssh \
		-oStrictHostKeyChecking=false \
		-oUserKnownHostsFile=/dev/null \
		-l ec2-user \
		$(shell cat ip)

tail:
	ssh \
		-oStrictHostKeyChecking=false \
		-oUserKnownHostsFile=/dev/null \
		-l ec2-user \
		$(shell cat ip) \
		sudo tail -n 100 -f /home/rust/rustserver/nohup.out
